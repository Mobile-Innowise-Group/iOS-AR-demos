import UIKit
import ARKit
import SnapKit

protocol ScanningViewControllerDelegate: AnyObject {
    var sceneView: ARSCNView { get }
    func setCompletion(model: LengthModel)
    func putSphere(at pos: SCNVector3)
    func drawLine(from: SCNVector3, to: SCNVector3, length: Float)
}

final class HandScanViewController: UIViewController {

    // MARK: - variables
    private let meshName = "ARPlaneMesh"
    private let handPoseRequest = VNDetectHumanHandPoseRequest()

    private let sceneViewSize: CGSize = .init(width: AppConstants.screenSize.width,
                                              height: AppConstants.screenSize.width)

    private lazy var distanceCalculator: DistanceCalculator = .init()
    private var arrayOfNodes: [SCNNode] = []

    // MARK: - gui variables

    private(set) lazy var sceneView: ARSCNView = {
        let view = ARSCNView(frame: CGRect.zero)
        view.delegate = self
        view.autoenablesDefaultLighting = true
        view.antialiasingMode = .multisampling4X
        return view
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .white
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.numberOfLines = 0
        label.backgroundColor = .black.withAlphaComponent(0.5)
        return label
    }()

    // MARK: - lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(sceneView)
        view.addSubview(statusLabel)
        handPoseRequest.maximumHandCount = 1
        distanceCalculator.delegate = self
        sceneView.delegate = self
        makeConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.session.run()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    // MARK: - constraint

    private func makeConstraints() {
        sceneView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(sceneViewSize)
        }

        statusLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(36)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualTo(sceneView.snp.top)
        }
    }

    // MARK: - actions

    private func capture() {
        guard let outputData = sceneView.session.currentFrame?.capturedImage else { return }
        clearNodes()
        captureOutput(output: outputData)
    }

    func setCompletion(model: LengthModel) {
        statusLabel.text = getTextOfLengthesForLabel(model: model)
    }

    private func getTextOfLengthesForLabel(model: LengthModel) -> String {
        return """
 Thumb length: \(model.thumbFingerLength ?? 0)cm
 Index length: \(model.indexFingerLength  ?? 0)cm
 Middle length: \(model.middleFingerLength ?? 0)cm
 Ring length: \(model.ringFingerLength ?? 0)cm
 Small length: \(model.smallFingerLength ?? 0)cm
 Palm length: \(model.palmLength ?? 0)cm
 """
    }

    private func clearNodes() {
        arrayOfNodes.forEach { $0.removeFromParentNode() }
        arrayOfNodes = []
    }

    // MARK: - vision output

    private func captureOutput(output sampleBuffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: sampleBuffer, orientation: .up)
        try? handler.perform([handPoseRequest])

        guard let observation = handPoseRequest.results?.first else { return }
        let allPoints = try? observation.recognizedPoints(.all)

        // Ignore low confidence points.
        guard let allPoints = allPoints,
              allPoints.filter({ $0.value.confidence < 0.3 }).count == 0 else { return }
        distanceCalculator.processPoints(for: allPoints)
    }
}

// MARK: - ARSCNViewDelegate
extension HandScanViewController: ARSCNViewDelegate {
    /// used for drawing line when you selected first dot and move your phone
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let frame = sceneView.session.currentFrame else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if frame.anchors.count == 0 {
                self.statusLabel.text = "Point the camera at a flat horizontal surface to start scanning. \nA green area will be drawn on the eligible surface area."
            } else {
                self.capture()
            }
        }
    }

    /// creating vertical and horizontal plane nodes to detect surfaces and measure content
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        planeAnchor.addPlaneNode(on: node, contents: UIColor.green.withAlphaComponent(0.5))
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        planeAnchor.updatePlaneNode(on: node)
    }
}

extension HandScanViewController: ScanningViewControllerDelegate {

    /// Used for putting rounded sphere on scene.
    func putSphere(at pos: SCNVector3) {
        let node = SCNNode.sphereNode(color: .red, position: pos)
        sceneView.scene.rootNode.addChildNode(node)
        arrayOfNodes.append(node)
    }

    func drawLine(from: SCNVector3, to: SCNVector3, length: Float) {
        guard let node = arrayOfNodes.last(where: { $0.position == from }) else { return }
        let lineNode = SCNNode.lineNode(length: CGFloat(length), color: .white)
        node.addChildNode(lineNode)
        lineNode.position = SCNVector3Make(0, 0, -length / 2)
        node.look(at: to)
    }
}
