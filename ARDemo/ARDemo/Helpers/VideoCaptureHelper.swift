
import UIKit
import AVFoundation
import CoreVideo

protocol VideoCaptureDelegate: AnyObject {
    func videoCapture(didCaptureVideoFrame: CVPixelBuffer?)
}

final class VideoCaptureHelper: NSObject {

    // MARK: - variables

    var fps = 15
    weak var delegate: VideoCaptureDelegate?
    private(set) var previewLayer: AVCaptureVideoPreviewLayer?

    private var lastTimestamp = CMTime()
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "com.uvolchyk.rickeriments-queue")

    // MARK: - actions

    func setUp(sessionPreset: AVCaptureSession.Preset = .vga640x480,
               completion: @escaping (Bool) -> Void) {
        self.setUpCamera(sessionPreset: sessionPreset, completion: completion)
    }

    func setUpCamera(sessionPreset: AVCaptureSession.Preset, completion: @escaping (Bool) -> Void) {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = sessionPreset

        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                          for: .video,
                                                          position: .back) else {
            print("Error: no video devices available")
            completion(false)
            return
        }

        guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Error: could not create AVCaptureDeviceInput")
            completion(false)
            return
        }

        if captureSession.canAddInput(videoInput) { captureSession.addInput(videoInput) }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        self.previewLayer = previewLayer

        let settings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value: kCVPixelFormatType_32BGRA)]

        videoOutput.videoSettings = settings
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        if captureSession.canAddOutput(videoOutput) { captureSession.addOutput(videoOutput) }

        // We want the buffers to be in portrait orientation otherwise they are
        // rotated by 90 degrees. Need to set this _after_ addOutput()!
        videoOutput.connection(with: AVMediaType.video)?.videoOrientation = .portrait

        captureSession.commitConfiguration()
        completion(true)
    }

    func start() {
        guard !captureSession.isRunning else { return }
        DispatchQueue.global().async { [weak self] in self?.captureSession.startRunning() }
    }

    func stop() {
        guard captureSession.isRunning else { return }
        DispatchQueue.global().async { [weak self] in self?.captureSession.stopRunning() }
    }
}

extension VideoCaptureHelper: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Because lowering the capture device's FPS looks ugly in the preview,
        // we capture at full speed but only call the delegate at its desired
        // framerate.
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let deltaTime = timestamp - lastTimestamp
        if deltaTime >= CMTimeMake(value: 1, timescale: Int32(fps)) {
            lastTimestamp = timestamp
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            delegate?.videoCapture(didCaptureVideoFrame: imageBuffer)
        }
    }
}


