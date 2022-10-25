import StandardCyborgFusion
import Vision

final class VisionPredictionHelper: NSObject {
    
    // MARK: - variables
    
    var canBeDetected = true
    var isBadLightning = false

    var request: VNCoreMLRequest?
    
    var footDetectedAction: () -> Void
    
    private var isInDetectableRange = false {
        didSet {
            if !self.isInDetectableRange { self.stopTimerIfNeeded() }
        }
    }
    private var isFootDetected = false
    private var timerInProcess = false
    private var timer: Timer?
    private var timerDelay: TimeInterval = 1
    
    /// your  coreML model which you teach
    private let objectDectectionModel = try? FootDetectionWithSocks(configuration: .init())
    
    // MARK: - initialization
    
    init(footDetectedAction: @escaping () -> Void) {
        self.footDetectedAction = footDetectedAction
        super.init()
    }
    
    // MARK: - actions
    
    /// setting up vision request model by teached model
    func setUpModel() {
        if let coreModel = self.objectDectectionModel?.model,
           let visionModel = try? VNCoreMLModel(for: coreModel) {
            self.request = VNCoreMLRequest(model: visionModel, completionHandler: self.visionRequestDidComplete)
            self.request?.imageCropAndScaleOption = .scaleFill
        } else {
            debugPrint("Error CoreML model creation")
        }
    }
    
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        guard let request = self.request else { return }
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])
    }
    
    /// check if object in right distance range(detectable)
    func updateDistanceToCenterObject(depthBuffer: CVPixelBuffer?, cameraManager: CameraManager) {
        guard let depthBuffer = depthBuffer else { return }
        cameraManager.getDepthDistanceToCenter(depthFrame: depthBuffer,
                                               completion: { [weak self] isInRightRange in
            self?.isInDetectableRange = isInRightRange
        })
    }
    
    private func visionRequestDidComplete(request: VNRequest, error: Error?) {
        guard let predictions = request.results as? [VNRecognizedObjectObservation] else { return }
        let isFoot = self.detectIfRecognizedObjectIsFoot(predictions: predictions)
        self.checkAndStartDetectionIfNeeded(isFoot)
    }
    
    private func checkAndStartDetectionIfNeeded(_ isFoot: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard self?.isInDetectableRange == true,
                  self?.canBeDetected == true,
                  self?.isFootDetected == false else { return }
            
            if isFoot {
                self?.footDetected()
            }
            
            if self?.timerInProcess == false {
                self?.startDetectionTimer()
            }
        }
    }
    
    private func footDetected() {
        self.isFootDetected = true
        self.stopTimerIfNeeded()
        self.footDetectedAction()
    }
    
    /// Detection timer actions
    private func startDetectionTimer() {
        self.timerInProcess = true
        self.timer = Timer.scheduledTimer(timeInterval: self.timerDelay,
                                     target: self,
                                     selector: #selector(self.timerAction),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    private func stopTimerIfNeeded() {
        guard timerInProcess == true else { return }
        self.timer?.invalidate()
        self.timerInProcess = false
    }
    
    @objc func timerAction() {
        self.timer?.invalidate()
        guard self.canBeDetected == true,
              self.isFootDetected == false else { return }
        self.footDetected()
    }
    
    private func detectIfRecognizedObjectIsFoot(predictions: [VNRecognizedObjectObservation]) -> Bool {
        let topClassifications = predictions.first.map { (confidence: $0.confidence, label: $0.labels) }
        guard let confidence = topClassifications?.confidence,
              let footLabel = topClassifications?.label.first(where: { $0.identifier == "Foot"}),
              let palmLabel = topClassifications?.label.first(where: { $0.identifier == "Palm"}),
              palmLabel.confidence < 0.01 else { return false }
        
        if self.isBadLightning {
            return (confidence > 0.2 && footLabel.confidence > 0.65 && palmLabel.confidence > 0.006)
        } else {
            return (confidence > 0.4 && footLabel.confidence > 0.75)
            || (palmLabel.confidence < 0.005 && footLabel.confidence > 0.9 && confidence > 0.25)
            || (palmLabel.confidence < 0.0001 && footLabel.confidence > 0.9)
        }
    }
    
    // MARK: - reset action
    
    func reset() {
        self.canBeDetected = true
        self.isFootDetected = false
        self.isInDetectableRange = false
    }
}
