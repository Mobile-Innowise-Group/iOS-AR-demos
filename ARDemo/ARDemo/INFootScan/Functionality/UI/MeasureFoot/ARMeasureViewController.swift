import UIKit
import ARKit

final class ARMeasureViewController: UIViewController {
    
    // MARK: - variables
    
    var completeAction: (Double?) -> Void
    
    private let edgeInsets = UIEdgeInsets(top: 60, left: 32, bottom: 32, right: 32)
    private let imageSize = CGSize(width: 24, height: 24)
    private let backButtonSize = CGSize(width: 32, height: 32)
    private let meshName = "ARPlaneMesh"
    private var startNode: SCNNode?
    private var endNode: SCNNode?
    private var lineNode: SCNNode?
    private var distance: Double?
    
    // MARK: - gui variables
    
    private lazy var sceneView: ARSCNView = {
        let view = ARSCNView(frame: CGRect.zero)
        view.delegate = self
        view.autoenablesDefaultLighting = true
        view.antialiasingMode = .multisampling4X
        return view
    }()
    
    private lazy var statusLabel: BaseLabel = {
        let label: BaseLabel = .init(config: .init(textColor: .white))
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.backgroundColor = .black.withAlphaComponent(0.5)
        label.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return label
    }()
    
    private lazy var backImageButton: ImageView = {
        let view: ImageView = .init(systemName: "chevron.backward.square", withRenderingMode: true)
        view.tintColor = .white
        view.isUserInteractionEnabled = true
        view.action = { [weak self] in self?.backBtnTapped() }
        view.isAccessibilityElement = true
        view.accessibilityTraits = .button
        view.accessibilityLabel = "backButton-title".accessibility
        return view
    }()
    
    private lazy var addImage: ImageView = {
        let view: ImageView = .init(systemName: "plus.circle", withRenderingMode: true)
        view.tintColor = .white
        return view
    }()
    
    private lazy var addBtn: BaseButton = .init(config: .init(title: "arMeasureScreen-addPointButton-title",
                                                              action: { [weak self] in self?.addBtnTapped()}))
    
    private lazy var resetBtn: BaseButton = {
        let button: BaseButton = .init(config: .init(title: "resetButton-title",
                                                     buttonStyle: .secondary,
                                                     action: { [weak self] in self?.reset()}))
    
        button.setTitleColor(UIColor.red, for: .normal)
        return button
    }()
    
    // MARK: - initialization
    
    init(completeAction: @escaping (Double?) -> Void) {
        self.completeAction = completeAction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubviews([self.sceneView,
                         self.statusLabel,
                         self.backImageButton,
                         self.addImage,
                         self.resetBtn,
                         self.addBtn])
        
        self.sceneView.delegate = self
        self.reset()
        self.makeConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sceneView.session.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
    }
    
    // MARK: - constraint
    
    private func makeConstraints() {
        self.sceneView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.statusLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.edgeInsets.top)
            make.right.equalToSuperview().inset(self.edgeInsets)
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        self.backImageButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(self.edgeInsets)
            make.right.equalTo(self.statusLabel.snp.left).offset(-16)
            make.centerY.equalTo(self.statusLabel.snp.centerY)
            make.size.equalTo(self.backButtonSize)
        }
        
        self.addImage.snp.makeConstraints { make in
            make.center.equalTo(self.sceneView.snp.center)
            make.size.equalTo(self.imageSize)
        }
        
        self.addBtn.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.resetBtn.snp.top).offset(-8)
        }
        
        self.resetBtn.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-self.edgeInsets.bottom)
        }
    }
    
    // MARK: - draw actions
    
    private func putSphere(at pos: SCNVector3, color: UIColor) -> SCNNode {
        let node = SCNNode.sphereNode(color: color, position: pos)
        self.sceneView.scene.rootNode.addChildNode(node)
        return node
    }
    
    private func drawLine(from: SCNNode, to: SCNVector3, color: UIColor = .white, length: Float) -> SCNNode {
        let lineNode = SCNNode.lineNode(length: CGFloat(length), color: color)
        from.addChildNode(lineNode)
        lineNode.position = SCNVector3Make(0, 0, -length / 2)
        from.look(at: to)
        return lineNode
    }
    
    /// Calculate real world position 
    private func getCenterPosition() -> SCNVector3? {
        guard let query = self.sceneView.raycastQuery(from: self.sceneView.center,
                                                      allowing: .estimatedPlane,
                                                      alignment: .any) else { return nil }
        let result = self.sceneView.session.raycast(query)
        guard let hitResult = result.first?.worldTransform.columns.3 else { return nil }
        return SCNVector3(hitResult.x, hitResult.y, hitResult.z)
        
    }
    
    /// adding center dot and measure if needed
    private func centerChangeAction(_ pos: CGPoint, isCanBeFinal: Bool = true) {
        guard let hitPos = self.getCenterPosition() else { return }
        if let startNode = self.startNode {
            let distance = (hitPos - startNode.position).length()
            self.lineNode?.removeFromParentNode()
            
            let valueInCm = Double(distance * 100).rounded(toPlaces: 2)
            self.distance = valueInCm
            self.lineNode = drawLine(from: startNode,
                                     to: hitPos,
                                     color: isCanBeFinal ? .white : .gray,
                                     length: distance)
            let measureUnit = valueInCm == 1 ? "centimiter-title".accessibility : "centimiters-title".accessibility
            let newValueTitle = "\(valueInCm) \(measureUnit)"
            self.statusLabel.config?.title = newValueTitle
            
            if isCanBeFinal {
                let endNode = self.putSphere(at: hitPos, color: .white)
                self.endNode = endNode
                UIAccessibility.post(notification: .layoutChanged, argument: self.statusLabel)
            }
            
        } else {
            self.startNode = putSphere(at: hitPos, color: .white)
            self.resetBtn.isHidden = false
            self.statusLabel.config?.title = "arMeasureScreen-statusLabelEnd-title"
        }
    }
    
    // MARK: - Actions
    
    private func backBtnTapped() {
        self.completeAction(self.distance)
        RouteHelper.sh.popVC()
    }
    
    private func addBtnTapped() {
        guard let frame = self.sceneView.session.currentFrame,
              frame.anchors.count > 0 else { return }
        
        if self.endNode != nil { self.reset() }
        self.centerChangeAction(self.sceneView.center)
    }
    
    private func reset() {
        self.distance = nil
        self.startNode?.removeFromParentNode()
        self.startNode = nil
        self.endNode?.removeFromParentNode()
        self.endNode = nil
        self.resetBtn.isHidden = true
    }
}

// MARK: - ARSCNViewDelegate
extension ARMeasureViewController: ARSCNViewDelegate {
    /// used for drawing line when you selected first dot and move your phone
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let frame = self.sceneView.session.currentFrame else {return}
        DispatchQueue.main.async(execute: { [weak self] in
            guard let self = self else { return }
            if self.startNode == nil {
                self.statusLabel.config?.title = (frame.anchors.count > 0)
                ? "arMeasureScreen-statusLabelStart-title" : "arMeasureScreen-statusLabelError-title"
            } else if self.startNode != nil, self.endNode == nil {
                self.centerChangeAction(self.sceneView.center, isCanBeFinal: false)
            }
        })
    }
    
    /// creating vertical and horizontal plane nodes to detect surfaces and measure content
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let color = UIColor.green
        planeAnchor.addPlaneNode(on: node, contents: color.withAlphaComponent(0.1))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        planeAnchor.updatePlaneNode(on: node)
    }
}
