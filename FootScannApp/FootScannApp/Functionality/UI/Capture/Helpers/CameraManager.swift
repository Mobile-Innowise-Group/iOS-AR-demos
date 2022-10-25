import ARKit
import AVFoundation
import UIKit
import Accelerate

protocol CameraManagerDelegate: AnyObject {
    func cameraDidOutput(colorBuffer: CVPixelBuffer,
                         depthBuffer: CVPixelBuffer,
                         depthCalibrationData: AVCameraCalibrationData)
    func cameraBrightnessOutput(value: Double?)
}
/** Interfaces with AVCaptureSession APIs to initiate and stream synchronized RGB + depth data.
 Also requests camera access and manages camera state in response to appplication state
 transitions and interruptions.
 */
final class CameraManager: NSObject, AVCaptureDataOutputSynchronizerDelegate {
    
    enum SessionSetupResult: Int {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    /** Returns true if a TrueDepth camera is available on the current device.
     Note that the rear-facing disparity camera in dual-lens iPhones is not
     considered TrueDepth, and it is not accurate enough to perform high
     quality 3D reconstruction.
     */
    var isDepthCameraAvailable: Bool {
        return ARFaceTrackingConfiguration.isSupported
    }
    
    var isCameraPermissionDenied: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .denied
    }
    
    /** The mechanism for clients of CameraManager to be provided with streaming camera and depth frames */
    weak var delegate: CameraManagerDelegate?
    
    /** Configures the minimum color camera shutter speed. Defaults to 1/60s */
    var minColorExposureDuration: TimeInterval = 1.0/60.0
    
    /** Configures the default color camera resolution. Defaults to 1280x720. Values larger than 1920x1280 are not recommended. */
    var colorCaptureSessionPreset: AVCaptureSession.Preset = .hd1280x720
    
    /** Returns true if currently streaming depth data */
    var isSessionRunning: Bool {
        get {
            var running = false
            sessionQueue.sync { running = self.sessionQueueIsSessionRunning }
            return running
        }
    }
    
    var isPaused: Bool = false {
        didSet {
            sessionQueue.sync {
                if let connection = depthDataOutput.connection(with: .depthData) {
                    connection.isEnabled = !isPaused
                }
            }
        }
    }
    
    // MARK: - Private properties
    
    private var allowedRange: Range<Float> {
        let nearest = (AppConstants.screenSize.height + AppConstants.screenSize.width) * AppConstants.footDistanceMultiplier
        let farest = nearest + 0.03
        return Float(nearest)..<Float(farest)
    }

    private var hasAddedObservers = false
    private var sessionQueueSetupResult: SessionSetupResult = .success
    private let captureSession = AVCaptureSession()
    private var sessionQueueIsSessionRunning = false
    private let sessionQueue = DispatchQueue(label: "Session",
                                             qos: DispatchQoS.userInitiated,
                                             attributes: [],
                                             autoreleaseFrequency: .workItem)
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera],
                                                                               mediaType: .video,
                                                                               position: .front)
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let dataOutputQueue = DispatchQueue(label: "Video data output",
                                                qos: .userInitiated,
                                                attributes: [],
                                                autoreleaseFrequency: .workItem)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let depthDataOutput = AVCaptureDepthDataOutput()
    private var outputSynchronizer: AVCaptureDataOutputSynchronizer?
    private var dataOutputQueueRenderingEnabled = true
    
    
    //MARK: - Deinit
    
    deinit {
        if hasAddedObservers {
            captureSession.removeObserver(self, forKeyPath: "running", context: &sessionRunningContext)
        }
    }
    
    // MARK: - Session setup
    
    /** Call this before calling startSession to request camera access and
     configure the AVCaptureSession for the desired resolution and framerate.
     Only necessary to call this once per instance of CameraManager.
     This does not start streaming, but prepares for it.
     */
    
    func configureCaptureSession(maxResolution: Int = 320, maxFramerate: Int = 30) {
        guard self.isDepthCameraAvailable else { return }
        
        // Check video authorization status, video access is required
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted { self.sessionQueueSetupResult = .notAuthorized }
                self.sessionQueue.resume()
            })
        default:
            sessionQueueSetupResult = .notAuthorized
        }
        
        sessionQueue.async {
            if self.sessionQueueSetupResult == .success {
                self.sessionQueueSetupResult = self.sessionQueueConfigureSession(maxResolution: maxResolution,
                                                                                 maxFramerate: maxFramerate)
            }
        }
    }
    
    /** After having called configureCaptureSession once, call this to start streaming
     color and depth data to the delegate
     */
    func startSession(_ completion: ((SessionSetupResult) -> Void)? = nil) {
        guard self.isDepthCameraAvailable else {
            DispatchQueue.main.async {
                completion?(.configurationFailed)
            }
            return
        }
        
        sessionQueue.async {
            let result = self.sessionQueueSetupResult
            switch result {
                // Only set up observers and start the session running if setup succeeded
            case .success:
                if self.sessionQueueIsSessionRunning == false {
                    self.addObservers()
                    self.dataOutputQueue.async {
                        self.dataOutputQueueRenderingEnabled = true
                    }
                    
                    self.captureSession.startRunning()
                    self.sessionQueueIsSessionRunning = self.captureSession.isRunning
                    NotificationCenter.default.post(name: .CameraManagerDidStartSession, object: nil)
                }
            default:
                break
            }
            
            DispatchQueue.main.async {
                completion?(result)
            }
        }
    }
    
    /** Stops streaming to the delegate */
    func stopSession( _ completion: (() -> Void)? = nil) {
        dataOutputQueue.async {
            self.dataOutputQueueRenderingEnabled = false
        }
        
        sessionQueue.async {
            if self.sessionQueueIsSessionRunning {
                self.captureSession.stopRunning()
                self.sessionQueueIsSessionRunning = self.captureSession.isRunning
            }
            
            DispatchQueue.main.async { completion?() }
        }
    }
    
    // MARK: - KVO and Notifications
    
    private var sessionRunningContext = 0
    
    private func addObservers() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: Notification.Name.AVCaptureSessionRuntimeError,
                                               object: captureSession)
        
        captureSession.addObserver(self, forKeyPath: "running", options: NSKeyValueObservingOptions.new, context: &sessionRunningContext)
        
        /*
         A session can only run when the app is full screen. It will be interrupted
         in a multi-app layout, introduced in iOS 9, see also the documentation of
         AVCaptureSessionInterruptionReason. Add observers to handle these session
         interruptions and show a preview is paused message. See the documentation
         of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
         */
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionWasInterrupted),
                                               name: .AVCaptureSessionWasInterrupted,
                                               object: captureSession)
        
        hasAddedObservers = true
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if context != &sessionRunningContext {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    @objc private func sessionWasInterrupted(notification: Notification) {
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
           let reasonIntegerValue = userInfoValue.integerValue,
           let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted with reason \(reason)")
        }
    }
    
    @objc private func sessionRuntimeError(notification: Notification) {
        guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else {
            return
        }
        
        let error = AVError(_nsError: errorValue)
        print("Capture session runtime error: \(error)")
        
        // Automatically try to restart the session running if media services were reset and the last start running succeeded.
        // Otherwise, enable the user to try to resume the session running.
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.sessionQueueIsSessionRunning {
                    self.captureSession.startRunning()
                    self.sessionQueueIsSessionRunning = self.captureSession.isRunning
                }
            }
        }
    }
    
    @objc private func didEnterBackground(notification: Notification) {
        // Free up resources
        dataOutputQueue.async {
            self.dataOutputQueueRenderingEnabled = false
        }
    }
    
    @objc private func willEnterForground(notification: Notification) {
        dataOutputQueue.async {
            self.dataOutputQueueRenderingEnabled = true
        }
    }
    
    // MARK: - AVCaptureDataOutputSynchronizerDelegate
    
    public func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer, didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection)
    {
        guard dataOutputQueueRenderingEnabled else { return }
        
        // Read all outputs
        guard let syncedDepthData: AVCaptureSynchronizedDepthData =
                synchronizedDataCollection.synchronizedData(for: depthDataOutput) as? AVCaptureSynchronizedDepthData,
              let syncedVideoData: AVCaptureSynchronizedSampleBufferData =
                synchronizedDataCollection.synchronizedData(for: videoDataOutput) as? AVCaptureSynchronizedSampleBufferData
        else { return /* Only work on synced pairs */ }
        
        guard !syncedDepthData.depthDataWasDropped &&
                !syncedVideoData.sampleBufferWasDropped
        else { return }
        
        let depthData = syncedDepthData.depthData
        let depthBuffer = depthData.depthDataMap
        let sampleBuffer = syncedVideoData.sampleBuffer
        guard let colorBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let depthCalibrationData = depthData.cameraCalibrationData
        else { return }
        
        self.delegate?.cameraBrightnessOutput(value: sampleBuffer.getBrightness())
        self.delegate?.cameraDidOutput(colorBuffer: colorBuffer,
                                       depthBuffer: depthBuffer,
                                       depthCalibrationData: depthCalibrationData)
    }
    
    func getImageFromBuffer(_ pixelBuffer: CVPixelBuffer) -> UIImage? {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let context = CGContext(data: baseAddress,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue),
              let cgImage = context.makeImage() else { return nil }
        
        let image = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return image
    }
    
    // MARK: - Private
    
    private func sessionQueueConfigureSession(maxResolution: Int, maxFramerate: Int) -> SessionSetupResult {
        guard let videoDevice = videoDeviceDiscoverySession.devices.first else {
            print("Could not find any video device")
            return .configurationFailed
        }
        
        // Adding video device input
        
        if let input = videoDeviceInput {
            captureSession.removeInput(input)
        }
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            print("Could not create video device input: \(error)")
            return .configurationFailed
        }
        guard let videoDeviceInput = videoDeviceInput,
              captureSession.canAddInput(videoDeviceInput) else {
            print("Could not add video device input to the session")
            return .configurationFailed
        }
        
        //Adding video device output
        
        guard captureSession.outputs.contains(videoDataOutput)
                || captureSession.canAddOutput(videoDataOutput)
        else {
            print("Could not add video data output to the session")
            return .configurationFailed
        }
        guard captureSession.outputs.contains(depthDataOutput)
                || captureSession.canAddOutput(depthDataOutput)
        else {
            print("Could not add depth data output to the session")
            return .configurationFailed
        }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = colorCaptureSessionPreset
        captureSession.addInput(videoDeviceInput)
        if !captureSession.outputs.contains(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
        if !captureSession.outputs.contains(depthDataOutput) {
            captureSession.addOutput(depthDataOutput)
        }
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        depthDataOutput.isFilteringEnabled = false
        depthDataOutput.alwaysDiscardsLateDepthData = true
        
        if let connection = depthDataOutput.connection(with: .depthData) {
            connection.isEnabled = true
        } else {
            print("No AVCaptureConnection")
        }
        
        // Search for the highest resolution with 32-bit depth values
        let depthFormats = videoDevice.activeFormat.supportedDepthDataFormats
        let selectedFormat = depthFormats.filter {
            CMFormatDescriptionGetMediaSubType($0.formatDescription) == kCVPixelFormatType_DepthFloat32
        }.filter {
            CMVideoFormatDescriptionGetDimensions($0.formatDescription).width <= maxResolution
        }.max { first, second in
            CMVideoFormatDescriptionGetDimensions(first.formatDescription).width
            < CMVideoFormatDescriptionGetDimensions(second.formatDescription).width
        }
        
        do {
            try videoDevice.lockForConfiguration()
            videoDevice.activeDepthDataFormat = selectedFormat
            videoDevice.activeDepthDataMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(maxFramerate))
            videoDevice.activeMaxExposureDuration = CMTimeMake(value: 1, timescale: Int32(minColorExposureDuration))
            videoDevice.isSubjectAreaChangeMonitoringEnabled = false
            videoDevice.unlockForConfiguration()
        } catch {
            print("Could not lock device for configuration: \(error)")
            captureSession.commitConfiguration()
            return .configurationFailed
        }
        
        // Use an AVCaptureDataOutputSynchronizer to synchronize the video data and depth data outputs.
        // The first output in the dataOutputs array, in this case the AVCaptureVideoDataOutput, is the "master" output.
        outputSynchronizer = AVCaptureDataOutputSynchronizer(dataOutputs: [videoDataOutput, depthDataOutput])
        guard let outputSynchronizer = outputSynchronizer else { return .configurationFailed }
        outputSynchronizer.setDelegate(self, queue: dataOutputQueue)
        captureSession.commitConfiguration()
        
        return .success
    }
    
    // MARK: - camera distance actions
    
    /// main function to convert depth data into real world distance. Current distance should be in range from 24 to 26 cm
    func getDepthDistanceToCenter(depthFrame: CVPixelBuffer,
                                  completion: @escaping (Bool) -> Void) {
        let depthPoint = CGPoint(x: CGFloat(CVPixelBufferGetWidth(depthFrame)) / 2,
                                 y: CGFloat(CVPixelBufferGetHeight(depthFrame)) / 2)
        let distance = depthFrame.getDepthDistanceToPoint(point: depthPoint)
        
        DispatchQueue.main.async {
            guard distance > 0 else { return }
            completion((self.allowedRange).contains(distance))
        }
    }
}
