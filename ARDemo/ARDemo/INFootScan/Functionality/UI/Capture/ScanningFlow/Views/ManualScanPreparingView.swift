import UIKit

final class ManualScanPreparingView: UIView {
    
    // MARK: - variables
    
    var startScanningAction: () -> Void
    var viewShouldAppearAction: () -> Void
    private var shutterButtonTimer: Timer?
    
    private let buttonInsets: UIEdgeInsets = .init(top: 16, left: 38, bottom: 50, right: 38)
    private let descriptionLabelInsets: UIEdgeInsets = .init(top: 32, left: 38, bottom: 100, right: 38)
    private let imageSize: CGSize = .init(width: 70, height: 70)
    private let buttonSize: CGSize = .init(width: 70, height: 70)
    private var shutterButtonShowingInterval: CGFloat = 10
   
    // MARK: - gui variables
    
    private(set) lazy var cameraView: CustomCameraView = .init()
    
    private(set) lazy var descriptionLabel: BaseLabel = .init(config: .init(title: "manualScan-description",
                                                                       font: .latoBold(size: 32),
                                                                       textColor: UIColor(named: "scanningViewTextColor")))
    
    private lazy var scanHandImage: ImageView = .init(imageName: "manualScanHandImage")
    
    private(set) lazy var shutterButton: ShutterButton = {
        let button = ShutterButton()
        button.addTarget(self, action: #selector(self.shutterTapped), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    // MARK: - initialisation
    
    init(viewShouldAppearAction: @escaping () -> Void, startScanningAction: @escaping () -> Void) {
        self.viewShouldAppearAction = viewShouldAppearAction
        self.startScanningAction = startScanningAction
        super.init(frame: .zero)
        self.initView()
    }
    
    private func initView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.addSubviews([self.cameraView,
                          self.descriptionLabel,
                          self.shutterButton,
                          self.scanHandImage])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - constraints
    
    override func updateConstraints() {
        super.updateConstraints()
        self.cameraView.snp.updateConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.descriptionLabel.snp.updateConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.left.right.equalToSuperview().inset(self.descriptionLabelInsets)
            make.bottom.lessThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
        }
        
        self.shutterButton.snp.updateConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.equalToSuperview().inset(self.buttonInsets)
            make.centerX.equalToSuperview()
            make.size.equalTo(self.buttonSize)
        }
        
        self.scanHandImage.snp.updateConstraints { make in
            make.left.equalTo(self.shutterButton.snp.right)
            make.top.equalTo(self.shutterButton.snp.top).offset(-self.imageSize.height / 2)
            make.right.bottom.lessThanOrEqualToSuperview()
            make.size.equalTo(self.imageSize)
        }
    }
    
    // MARK: - shutter button actions + timer
    
    func startShutterButtonTimer() {
        self.shutterButtonTimer = Timer.scheduledTimer(withTimeInterval: self.shutterButtonShowingInterval,
                                                       repeats: false) { [weak self] _ in
            self?.viewShouldAppearAction()
        }
    }
    
    func stopShutterButtonTimer() {
        self.shutterButtonTimer?.invalidate()
        self.shutterButtonTimer = nil
    }
    
    @objc private func shutterTapped() { self.startScanningAction() }
}
