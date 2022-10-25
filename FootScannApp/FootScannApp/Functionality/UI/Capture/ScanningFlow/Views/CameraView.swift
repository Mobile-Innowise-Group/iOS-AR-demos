import UIKit
import AVFoundation

/// used for background camera usage 
final class CustomCameraView: UIView {
    
    // MARK: - variables
    
    private var captureSession: AVCaptureSession?
    private var cameraLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - gui variables
    
    private lazy var cameraBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.opacity = 0.9
        return view
    }()
    
    // MARK: - initialization
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cameraBackgroundView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.disableActions()
        self.cameraLayer?.frame = self.bounds
        CATransaction.commit()
    }
    
    // MARK: - constraints
    
    override func updateConstraints() {
        super.updateConstraints()
        self.cameraBackgroundView.snp.updateConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - camera actions
    func start(completion: (() -> Void)? = nil) {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .hd1280x720
        
        guard let frontCamera = AVCaptureDevice.default(.builtInTrueDepthCamera,
                                                        for: .video,
                                                        position: .front) else { return }
        
        if let input = try? AVCaptureDeviceInput(device: frontCamera), captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        // Setup Live View
        
        let captureLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        captureLayer.videoGravity = .resizeAspectFill
        self.cameraLayer = captureLayer
        
        self.layer.insertSublayer(captureLayer, below: self.cameraBackgroundView.layer)
        
        self.captureSession = captureSession
        DispatchQueue.global().async {
            captureSession.startRunning()
            DispatchQueue.main.async {
                captureLayer.frame = self.bounds
                completion?()
            }
        }
    }
    
    func stop() {
        guard let captureSession = self.captureSession else { return }
        self.cameraLayer?.removeFromSuperlayer()
        captureSession.inputs.forEach { captureSession.removeInput($0) }
        captureSession.outputs.forEach { captureSession.removeOutput($0) }
    }
}
