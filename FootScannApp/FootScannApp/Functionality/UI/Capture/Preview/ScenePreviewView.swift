import SceneKit
import StandardCyborgFusion
import UIKit

class ScenePreviewView: UIView {
    
    // MARK: - variables
    
    private let selectedFoot: FootSideType
    
    private let buttonStackInsets: UIEdgeInsets = .init(top: 0, left: 20, bottom: 60, right: 20)
    private let titleDescriptionViewInsets: UIEdgeInsets = .init(top: 60, left: 38, bottom: 12, right: 38)
    private let sceneViewInsets: UIEdgeInsets = .init(top: 12, left: 0, bottom: 12, right: 0)
    
    private var sceneViewSize: CGSize {
        return CGSize(width: AppConstants.screenSize.width,
                      height: AppConstants.screenSize.height * 0.6)
    }
    
    private(set) var initialPointOfView = SCNMatrix4Identity
    private(set) var containerNode = SCNNode()
    
    // MARK: - gui variables
    
    /// should be already created before setting scene
    let sceneView: SCNView = {
        guard let sceneURL = Bundle.main.url(forResource: "ScenePreviewViewController",
                                             withExtension: "scn"),
              let scene = try? SCNScene(url: sceneURL, options: nil) else { return SCNView() }
        scene.background.contents = UIColor.clear
        
        let sceneView = SCNView()
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = UIColor.clear
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.isAccessibilityElement = true
        sceneView.accessibilityLabel = "scanModelObject-title".accessibility
        return sceneView
    }()
    
    private lazy var titleDescriptionView: TitleDescriptionView = .init(description: "preview-description")
    
    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [self.leftButton, self.rightButton])
        view.spacing = 12
        view.distribution = .fillProportionally
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /** Owners may mutate this button to customize its appearance and respond to taps */
    lazy var leftButton = BaseButton(config: .init(title: "preview-retakeButton-title",
                                                   buttonStyle: .secondary,
                                                   color: UIColor(named: "textSecondaryColor")))
    
    /** Owners may mutate this button to customize its appearance and respond to taps */
    lazy var rightButton = BaseButtonWithLoader(config: .init(title: self.selectedFoot.getPreviewContinueButtonTitle()))
    
    // MARK: - initialisation
    
    init(selectedFoot: FootSideType) {
        self.selectedFoot = selectedFoot
        super.init(frame: .zero)
        self.initView()
    }
    
    private func initView() {
        self.containerNode.name = "Container"
        self.containerNode.position = SCNVector3Make(0, 0.001, -1.05)
        self.sceneView.scene?.rootNode.addChildNode(self.containerNode)
        
        guard let pointOfView = self.sceneView.pointOfView else { return }
        self.initialPointOfView = pointOfView.transform
        
        self.addSubviews([self.titleDescriptionView,
                          self.sceneView,
                          self.buttonStackView])
        
        self.rightButton.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - constraints
    
    override func updateConstraints() {
        super.updateConstraints()
        self.titleDescriptionView.snp.remakeConstraints { make in
            make.top.right.equalToSuperview().inset(self.titleDescriptionViewInsets)
            make.left.equalToSuperview().inset(self.titleDescriptionViewInsets)
        }
        
        self.sceneView.snp.updateConstraints { make in
            make.top.equalTo(self.titleDescriptionView.snp.bottom)
            make.left.right.equalToSuperview()
            make.size.equalTo(self.sceneViewSize)
        }
        
        self.buttonStackView.snp.updateConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(self.buttonStackInsets)
        }
    }
}

extension ScenePreviewView: BaseButtonWithLoaderDelegate {
    func buttonsLoaderStarted(_ button: BaseButtonWithLoader) {
        self.leftButton.isEnabled = false
    }
}
