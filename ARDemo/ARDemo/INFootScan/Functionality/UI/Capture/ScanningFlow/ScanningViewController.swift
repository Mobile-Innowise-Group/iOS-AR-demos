import AVFoundation
import StandardCyborgFusion
import UIKit

enum ScanningViewControllerState: Equatable {
    case `default`
    case countdownSeconds(Int)
    case scanning
}

enum ScanningTerminationReason: Int {
    case canceled
    case finished
}

/// main scanning class for the app
final class ScanningViewController: UIViewController {
    
    // MARK: - variables
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    // MARK: - private variables
    private let longWaitingAction: () -> Void
    private let completionHandler: (SceneModel) -> Void
    private let selectedFoot: FootSideType
    private let withScanPreparing: Bool
    private let isAlertEnabled: Bool? = true
    private var screenshotImage: UIImage?
    
    /// Control brightness level
    private let customBrightness = 0.8
    private var userDefaultBrightness: CGFloat?
    
    /// FOR case when overaly of manual scanning presented
    private let audioSession = AVAudioSession.sharedInstance()

    // MARK: - mesh and camera variables
    private let minBrightnessValue: Double = 0
    private var scanningFinishDelay: CGFloat = 0.1
    private var currentPixelBuffer: CVPixelBuffer?

    // MARK: - state variables
    
    private var state: ScanningViewControllerState = .default {
        didSet {
            self.constructSceneHelper.state = self.state
        }
    }
    
    private var isFootDetected: Bool {
        set { self.scanningContainerView.isFootDetected = newValue }
        get { self.scanningContainerView.isFootDetected }
    }
    
    // MARK: - gui variables
    
    private lazy var speakHelper: SpeakHelper = .init()
    private lazy var cameraManager: CameraManager = .init()
    
    /// all mesh and scene creation here
    private lazy var constructSceneHelper: ConstructSceneHelper = .init(
        metalDevice: self.scanningContainerView.scanningView.metalDevice,
        resetSessionAction: { [weak self] in self?.resetSession() },
        stopScanningAction: { [weak self] reason in self?.stopScanning(reason: reason) })
    
    /// all object detection methods here
    private lazy var visionPredictionHelper: VisionPredictionHelper = .init { [weak self] in
        self?.footDetectedActionIfNeeded()
    }
    
    private lazy var scanningContainerView: ScanningUIContainerView = {
        let view: ScanningUIContainerView = .init(selectedFoot: self.selectedFoot,
                                                  withScanPreparing: self.withScanPreparing,
                                                  screenshotImage: self.screenshotImage)
        view.configureSessionAction = { [weak self] in self?.configureScanSession() }
        view.shutterButtonAction = { [weak self] in self?.shutterStarted() }
        view.showManualViewAction = { [weak self] in self?.prepareForManualScanning() }
        return view
    }()
    
    // MARK: - initialization
    
    init(selectedFoot: FootSideType,
         withScanPreparing: Bool = false,
         screenshotImage: UIImage? = nil,
         longWaitingAction: @escaping () -> Void,
         completionHandler: @escaping (SceneModel) -> Void) {
        self.selectedFoot = selectedFoot
        self.completionHandler = completionHandler
        self.withScanPreparing = withScanPreparing
        self.screenshotImage = screenshotImage
        self.longWaitingAction = longWaitingAction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.setUpSubviews()
        self.scanningContainerView.setScanViewIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard self.withScanPreparing, self.selectedFoot == .right else { return }
        self.speakHelper.voiceTheText("scanPreapringView-description".accessibility)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.listenVolumeButton()
        self.addAppLifecycleNotification()
        guard self.cameraManager.isDepthCameraAvailable else { return }
        self.startCameraSession()
        self.visionPredictionHelper.setUpModel()
        UIApplication.shared.isIdleTimerDisabled = true
        self.increaseBrightnessIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopAudioSessionObserving()
        self.removeAppLifecycleNotification()
        self.stopScanning()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func didReceiveMemoryWarning() {
        debugPrint("Received low memory warning; stopping scanning")
        self.stopScanning(reason: .finished)
    }

    deinit {
        
    }
    
    /// getting some accesses if stil not have for the scanning
    private func startCameraSession() {
        self.cameraManager.startSession { [weak self] result in
            switch result {
            case .success:
                break
            case .configurationFailed:
                debugPrint("Configuration failed for an unknown reason")
            case .notAuthorized:
                let message = "scan-cameraErrorMessage-notAuthorized"
                let alertController = UIAlertController(title: "Camera Access", message: message,
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
                alertController.addAction(UIAlertAction(title: "Open Settings", style: .`default`) { _ in
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                })
                self?.present(alertController, animated: true)
            }
        }
    }
    
    private func setUpSubviews() {
        view.addSubview(self.scanningContainerView)
        self.scanningContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureScanSession() {
        self.cameraManager.delegate = self
        self.cameraManager.configureCaptureSession()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.thermalStateChanged),
                                               name: ProcessInfo.thermalStateDidChangeNotification,
                                               object: nil)
    }
    
    // MARK: - thermal state control action
    
    @objc private func thermalStateChanged(notification: Notification) {
        guard let processInfo = notification.object as? ProcessInfo,
              processInfo.thermalState == .critical else { return }
        
        DispatchQueue.main.async { [weak self] in
            if self?.state == .scanning { self?.stopScanning(reason: .finished) }
        }
    }
    
    // MARK: - foot detected action
    
    private func footDetectedActionIfNeeded() {
        guard self.state == .default else { return }
        self.isFootDetected = true
        self.shutterStarted()
    }
    
    // MARK: - scanning button actions
    
    private func shutterStarted() {
        guard presentedViewController == nil, self.cameraManager.isSessionRunning else { return }
        switch state {
        case .default:
            self.handleDefaultShutteredState()
        case .countdownSeconds(let seconds):
            if seconds > 0 {
                ScanningHapticFeedbackEngine.shared.scanningCanceled()
                self.cancelCountdown()
            }
        case .scanning:
            ScanningHapticFeedbackEngine.shared.scanningFinished()
            self.stopScanning(reason: .finished)
        }
    }
    
    private func handleDefaultShutteredState() {
        self.speakHelper.voiceTheText("countdown-begins".accessibility) { [weak self] in
            self?.startCountdown { [weak self] in self?.startScanning() }
        }
    }
    
    /** Starts scanning immediately */
    private func startScanning() {
        ScanningHapticFeedbackEngine.shared.scanningBegan()
        self.state = .scanning
        self.constructSceneHelper.assimilatedFrameIndex = 0
        self.constructSceneHelper.meshTexturing.reset()
        DispatchQueue.main.asyncAfter(deadline: .now() + self.scanningFinishDelay) { [weak self] in
            guard self?.state == .scanning else { return }
            self?.scanningContainerView.scanningView.updateUI(withState: .scanningSuccess)
            ScanningHapticFeedbackEngine.shared.scanningFinished()
            self?.stopScanning(reason: .finished)
        }
    }
    
    /** Brightness ajusting methods */
    private func increaseBrightnessIfNeeded() {
        guard UIScreen.main.brightness < self.customBrightness else { return }
        self.userDefaultBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = self.customBrightness
    }
    
    private func decreaseBrightnessIfNeeded() {
        guard let defaultUserBrightness = self.userDefaultBrightness else { return }
        UIScreen.main.brightness = defaultUserBrightness
    }
    
    /** Stops scanning immediately */
    private func stopScanning(reason: ScanningTerminationReason) {
        guard self.state != .default else { return }
        self.state = .default
        self.constructSceneHelper.latestViewMatrix = matrix_identity_float4x4
        reason == .finished ? self.finishedScanningAction() : self.resetSession()
    }
    
    private func finishedScanningAction() {
        self.scanningContainerView.takeScreenshotOfMetalLayer()
        self.speakHelper.voiceTheText("scanning-finished".accessibility)
        self.cameraManager.stopSession()
        self.decreaseBrightnessIfNeeded()
        self.scanningContainerView.showLoader()
        self.constructSceneHelper.completionRenderingAction { [weak self] (pointCloud, mesh) in
            self?.handleCompletion(pointCloud: pointCloud,
                                   mesh: mesh)
        }
    }
    
    private func resetSession(withVibro: Bool = true, shouldBeRestarted: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isFootDetected = false
            self.visionPredictionHelper.reset()
            self.cancelCountdown(withVibro: withVibro)
            self.constructSceneHelper.reset()
            self.scanningContainerView.scanningView.updateUI(withState: .defaultState)
            self.scanningContainerView.hideLoaderIfNeeded()
            if shouldBeRestarted {
                self.cameraManager.startSession()
                self.scanningContainerView.startShutterButtonTimerIfNeeded()
            }
        }
    }
    
    // MARK: - countdown actions
    
    private func startCountdown(_ completion: @escaping () -> Void) {
        self.state = .countdownSeconds(self.scanningContainerView.scanningView.countdownStartCount)
        self.scanningContainerView.scanningView.startCountdown(changeAction: { [weak self] seconds in
            self?.speakHelper.voiceTheText("\(seconds)")
        }, completion: { [weak self] state in
            guard self?.state != .default else { return }
            self?.state = state
            completion()
        })
    }
    
    // MARK: - UI State Management
    
    func showManualScanningView() {
        self.scanningContainerView.showManualScanningView()
    }
    
    private func prepareForManualScanning() {
        self.visionPredictionHelper.canBeDetected = false
        self.longWaitingAction()
    }
    
    private func cancelCountdown(withVibro: Bool = true) {
        self.state = .default
        self.scanningContainerView.scanningView.stopCountdown()
        withVibro
        ? ScanningHapticFeedbackEngine.shared.scanningCanceled()
        : ScanningHapticFeedbackEngine.shared.stopScanningTimer()
    }
    
    private func stopScanning() {
        self.cameraManager.stopSession()
        self.visionPredictionHelper.request = nil
        self.resetSession(withVibro: false, shouldBeRestarted: false)
    }
    
    private func handleCompletion(pointCloud: SCPointCloud, mesh: SCMesh) {
        guard let buffer = self.currentPixelBuffer,
              let photoImageData = self.cameraManager.getImageFromBuffer(buffer)?.jpegData(compressionQuality: 1)
        else {
            self.resetSession()
            return
        }
        self.stopScanning()
        self.showScreenshotIfNeededAndComplete(pointCloud: pointCloud, mesh: mesh, photoImageData: photoImageData)
    }
    
    private func showScreenshotIfNeededAndComplete(pointCloud: SCPointCloud, mesh: SCMesh, photoImageData:  Data) {
        self.scanningContainerView.dismissPoorLightAlertIfNeeded()
        let completionAction = { [weak self] in
            guard let self = self else { return }
            self.completionHandler(SceneModel(meshTexturing: self.constructSceneHelper.meshTexturing,
                                              mesh: mesh,
                                              pointCloud: pointCloud,
                                              screenshotImage: self.selectedFoot == .right
                                              ? self.scanningContainerView.screenshotPreviewImage : nil,
                                              photoImageData: photoImageData))
        }
        
        self.scanningContainerView.showScreenshotIfNeededAndComplete(completionAction: completionAction)
    }
}

// MARK: - CameraManagerDelegate
extension ScanningViewController: CameraManagerDelegate {
    func cameraBrightnessOutput(value: Double?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.visionPredictionHelper.isBadLightning = (value ?? 0) < self.minBrightnessValue
            guard self.visionPredictionHelper.canBeDetected else { return }
            guard self.isAlertEnabled == true else { return }
            self.visionPredictionHelper.isBadLightning ?
            self.scanningContainerView.presentPoorLightAlertIfNeeded() :
            self.scanningContainerView.dismissPoorLightAlertIfNeeded()
        }
    }
    
    /// handling camera output for creating mesh models and predicting screen objects(feet) on the screen
    func cameraDidOutput(colorBuffer: CVPixelBuffer,
                         depthBuffer: CVPixelBuffer,
                         depthCalibrationData: AVCameraCalibrationData) {
        guard let reconstructionManager = self.constructSceneHelper.reconstructionManager else { return }
        self.currentPixelBuffer = colorBuffer
        self.visionPredictionHelper.updateDistanceToCenterObject(depthBuffer: depthBuffer,
                                                                 cameraManager: self.cameraManager)
        let isScanning = self.state == .scanning
        let pointCloud: SCPointCloud
        
        self.visionPredictionHelper.predictUsingVision(pixelBuffer: colorBuffer)
        
        
        if isScanning {
            pointCloud = reconstructionManager.buildPointCloud()
        } else {
            pointCloud = reconstructionManager.reconstructSingleDepthBuffer(depthBuffer,
                                                                            colorBuffer: nil,
                                                                            with: depthCalibrationData,
                                                                            smoothingPoints: true)
        }
        
        self.constructSceneHelper.scanningViewRenderer?.draw(colorBuffer: colorBuffer,
                                                             pointCloud: pointCloud,
                                                             depthCameraCalibrationData: depthCalibrationData,
                                                             viewMatrix: self.constructSceneHelper.latestViewMatrix,
                                                             into: self.scanningContainerView.scanningView.metalLayer)
        if isScanning  {
            reconstructionManager.accumulate(depthBuffer: depthBuffer,
                                             colorBuffer: colorBuffer,
                                             calibrationData: depthCalibrationData)
        }
    }
}

// MARK: - lifecycle notification for handling state after suspending
extension ScanningViewController {
    private func addAppLifecycleNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.willResignActiveNotification),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    
    private func removeAppLifecycleNotification() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willResignActiveNotification,
                                                  object: nil)
    }
    
    @objc private func applicationDidBecomeActive() {
        guard !self.scanningContainerView.scanningView.isHidden,
              self.cameraManager.isSessionRunning else { return }
        self.scanningContainerView.startShutterButtonTimerIfNeeded()
        self.resetSession(withVibro: false, shouldBeRestarted: false)
        self.increaseBrightnessIfNeeded()
    }
    
    @objc private func willResignActiveNotification() {
        self.decreaseBrightnessIfNeeded()
    }
}

//MARK: - observe volume button to use as shutter button
extension ScanningViewController {
    private func listenVolumeButton() {
        try? self.audioSession.setActive(true)
        self.audioSession.addObserver(self,
                                      forKeyPath: "outputVolume",
                                      options: NSKeyValueObservingOptions.new,
                                      context: nil)
    }
    
    private func stopAudioSessionObserving() {
        try? self.audioSession.setActive(false)
        self.audioSession.removeObserver(self,
                                         forKeyPath: "outputVolume")
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "outputVolume" else { return }
        self.scanningContainerView.startManualScanningIfNeeded()
    }
}
