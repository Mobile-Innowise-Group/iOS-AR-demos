
import UIKit
import Vision

class ObjectRecognitionViewController: UIViewController {

    // MARK: - UI Properties

    private lazy var videoPreview = UIView()
    private lazy var boxesView = DrawingBoundingBoxView()

    // MARK: - Vision Properties

    private var request: VNCoreMLRequest?
    private var visionModel: VNCoreMLModel?
    private var isInferencing = false

    /// USED for making 16:9 format for the picture
    private let previewSize: CGSize = .init(width: AppConstants.screenSize.width,
                                     height: AppConstants.screenSize.width * 1.7)
    private let objectDectectionModel: MLModel

    // MARK: - AV Property

    private lazy var videoCaptureHelper: VideoCaptureHelper = {
        let videoCaptureHelper: VideoCaptureHelper = .init()
        videoCaptureHelper.delegate = self
        videoCaptureHelper.fps = 30
        return videoCaptureHelper
    }()

    let semaphore = DispatchSemaphore(value: 1)

    // MARK: - initialization

    init(objectDectectionModel: MLModel) {
        self.objectDectectionModel = objectDectectionModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        // setup the model
        setUpModel()
        // setup camera
        setUpCamera()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoCaptureHelper.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoCaptureHelper.stop()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }

    // MARK: - lifecycle configuration actions

    private func configureView() {
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .black
        view.addSubview(videoPreview)
        view.addSubview(boxesView)

        videoPreview.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(previewSize)
        }

        boxesView.snp.makeConstraints { make in
            make.edges.size.equalTo(videoPreview)
        }
    }

    private func resizePreviewLayer() {
        videoCaptureHelper.previewLayer?.frame = videoPreview.bounds
    }

    // MARK: - Setup Core ML

    func setUpModel() {
        guard let visionModel = try? VNCoreMLModel(for: objectDectectionModel) else { return }
        self.visionModel = visionModel
        request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
        request?.imageCropAndScaleOption = .scaleFit
    }

    // MARK: - SetUp Video

    func setUpCamera() {
        videoCaptureHelper.setUp { [weak self] success in
            guard let self = self, success else { return }
            if let previewLayer = self.videoCaptureHelper.previewLayer {
                self.videoPreview.layer.addSublayer(previewLayer)
                self.resizePreviewLayer()
            }

            // start video preview when setup is done
            self.videoCaptureHelper.start()
        }
    }
}

// MARK: - VideoCaptureDelegate
extension ObjectRecognitionViewController: VideoCaptureDelegate {
    func videoCapture(didCaptureVideoFrame pixelBuffer: CVPixelBuffer?) {
        // the captured image from camera is contained on pixelBuffer
        guard !isInferencing, let pixelBuffer = pixelBuffer else { return }
        isInferencing = true
        // predict!
        predictUsingVision(pixelBuffer: pixelBuffer)
    }
}

extension ObjectRecognitionViewController {
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        guard let request = request else { return }
        // vision framework configures the input size of image following our model's input configuration automatically
        semaphore.wait()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])
    }

    // MARK: - Post-processing
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        if let predictions = request.results as? [VNRecognizedObjectObservation] {
            DispatchQueue.main.async { [weak self] in
                self?.boxesView.predictedObjects = predictions
                self?.isInferencing = false
            }
        } else {
            isInferencing = false
        }

        semaphore.signal()
    }
}
