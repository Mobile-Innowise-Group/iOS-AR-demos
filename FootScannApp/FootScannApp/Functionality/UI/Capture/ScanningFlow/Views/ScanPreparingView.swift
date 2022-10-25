import UIKit

final class ScanPreparingView: UIView {
    
    // MARK: - variables
    
    private let preparingAction: () -> Void
    private let startScanningAction: () -> Void
    private let withScanPreparing: Bool
    private var pushNextScreenDelay: Double = 2.5
    
    private let selectedFoot: FootSideType
    private let imageSize: CGSize = .init(width: 140, height: 132)
    private let buttonInsets: UIEdgeInsets = .init(top: 16, left: 38, bottom: 60, right: 38)
    private let descriptionLabelInsets: UIEdgeInsets = .init(top: 32, left: 38, bottom: 100, right: 38)
    private let screenshotImageInsets: UIEdgeInsets = .init(top: 0, left: 52, bottom: 0, right: 52)
    
    private var screenshotImageSize: CGSize {
        return CGSize(width: AppConstants.screenSize.width * 0.75,
                      height: AppConstants.screenSize.height * 0.75)
    }
    
    // MARK: - gui variables
    
    private(set) lazy var cameraView: CustomCameraView = .init()

    private lazy var contentView: UIView = .init()
    
    private lazy var descriptionLabel: BaseLabel = .init(config: .init(title: "scanPreapringView-description",
                                                                       font: .latoBold(size: 24),
                                                                       textColor: UIColor(named: "scanningViewTextColor")))
    
    private lazy var imageView: ImageView = {
        let view = ImageView(imageName: "scanTrainImage",
                                               withRenderingMode: true)
        view.tintColor = UIColor(named: "mainAcceptColor")
        return view
    }()
    
    private lazy var oneSecondDescriptionLabel: BaseLabel = {
        let view: BaseLabel = .init(config: .init(
            title: self.selectedFoot.getDescriptionTitle(),
            font: .latoBold(size: 40),
            textColor: UIColor(named: "scanningViewTextColor")))
        view.isHidden = true
        return view
    }()
    
    private lazy var screenshotImageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.isHidden = true
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var startButton: BaseButton = .init(config: .init(title: "scanPreapringView-button-title",
                                                                   action: { [weak self] in self?.startScanPreviewActionIfNeeded() }))
    
    // MARK: - initialization
    
    init(selectedFoot: FootSideType,
         withScanPreparing: Bool,
         preparingAction: @escaping () -> Void,
         startScanningAction: @escaping () -> Void) {
        self.startScanningAction = startScanningAction
        self.preparingAction = preparingAction
        self.selectedFoot = selectedFoot
        self.withScanPreparing = withScanPreparing
        super.init(frame: .zero)
        self.initView()
        
        if self.selectedFoot == .left || !withScanPreparing { self.leftFootPreparingAction() }
    }
    
    private func initView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.addSubviews([self.cameraView,
                          self.contentView,
                          self.oneSecondDescriptionLabel,
                          self.screenshotImageView])
   
        self.contentView.addSubviews([self.descriptionLabel,
                                      self.imageView,
                                      self.startButton])
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
        
        self.contentView.snp.updateConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.screenshotImageView.snp.updateConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(self.screenshotImageSize)
        }
        
        self.oneSecondDescriptionLabel.snp.updateConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(self.descriptionLabelInsets)
        }
        
        self.imageView.snp.updateConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(self.imageSize)
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        self.descriptionLabel.snp.updateConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.left.right.equalToSuperview().inset(self.descriptionLabelInsets)
            make.bottom.equalTo(self.imageView.snp.top).offset(-self.descriptionLabelInsets.bottom)
        }
        
        self.startButton.snp.updateConstraints { make in
            make.top.greaterThanOrEqualTo(self.imageView.snp.bottom).offset(self.buttonInsets.top)
            make.left.right.bottom.equalToSuperview().inset(self.buttonInsets)
        }
    }
    
    // MARK: - actions
    
    func setImage(_ image: UIImage) {
        self.cameraView.start()
        self.screenshotImageView.image = image
        self.oneSecondDescriptionLabel.isHidden = true
        self.screenshotImageView.isHidden = false
    }
    
    func startScanPreviewActionIfNeeded() {
        guard self.selectedFoot == .right && self.withScanPreparing else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + (self.startButton.isHidden ?
                                                          self.pushNextScreenDelay : 0)) { [weak self] in
            guard let self = self else { return }
            self.preparingAction()
            self.contentView.animateHidingOrShowing(duration: 0.1) { [weak self] in
                self?.oneSecondDescriptionLabel.animateHidingOrShowing { [weak self] in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                        self?.startScanningAction()
                    }
                }
            }
        }
    }
    
    private func leftFootPreparingAction() {
        self.preparingAction()
        self.contentView.isHidden = true
        self.oneSecondDescriptionLabel.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.startScanningAction()
        }
    }
}
