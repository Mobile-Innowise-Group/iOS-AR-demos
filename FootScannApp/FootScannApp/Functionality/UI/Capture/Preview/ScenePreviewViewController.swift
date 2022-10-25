import SceneKit
import StandardCyborgFusion
import UIKit

final class ScenePreviewViewController: UIViewController, SCNSceneRendererDelegate {
    
    // MARK: - varaibles
    
    var leftButtonAction: (() -> Void)?
    var righButtonAction: (() -> Void)?
    
    private(set) var scScene: SCScene
    private let selectedFoot: FootSideType
    
    // MARK: - gui
    
    private lazy var previewView: ScenePreviewView = {
        let view: ScenePreviewView = .init(selectedFoot: self.selectedFoot)
        view.leftButton.config.action = { [weak self] in self?.leftButtonAction?() }
        view.rightButton.config.action = { [weak self] in
            self?.righButtonAction?()
            guard self?.selectedFoot == .left else { return }
            self?.previewView.rightButton.startLoading()
        }
        return view
    }()
    
    // MARK: - initialisation
    
    init(scScene: SCScene, selectedFoot: FootSideType) {
        self.scScene = scScene
        self.selectedFoot = selectedFoot
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = self.selectedFoot == .left
        self.view.backgroundColor = .white
        self.previewView.sceneView.delegate = self
        self.view.addSubview(self.previewView)
        
        self.previewView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.previewView.containerNode.addChildNode(self.scScene.rootNode)
    }
}
