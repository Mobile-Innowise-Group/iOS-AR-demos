import UIKit
import CoreML

enum ScanningViewStates {
    case defaultState
    case scanningSuccess
}

final class ScanningView: UIView {
    
    // MARK: - variables
    var isFootDetected: Bool = false
    
    private var isCountedDown: Bool = false
    private var selectedFoot: FootSideType
    
    private var footImageSize: CGSize {
        return CGSize(width: AppConstants.screenSize.width * AppConstants.footImageWidthCoef,
                      height: AppConstants.screenSize.height * AppConstants.footImageHeightCoef)
    }

    private let previousScanImageSize: CGSize = .init(width: 60, height: 120)
    private let countdownLabelSize: CGSize = .init(width: 123, height: 123)
    private let descriptionLabelInsets: UIEdgeInsets = .init(top: 87, left: 28, bottom: 42, right: 28)
    private let previousScanInsets: UIEdgeInsets = .init(top: 0, left: 28, bottom: 20, right: 28)
    private let checkmarkSize = CGSize(width: 100, height: 100)
    
    private let countdownPerSecondDuration = 0.75
    private(set) var countdownStartCount = 3
    
    // MARK: - gui variables
    
    private(set) lazy var metalDevice = MTLCreateSystemDefaultDevice()
    private(set) lazy var metalContainerView = UIView()
    
    /// used for  visualize mesh model 
    private(set) lazy var metalLayer: CAMetalLayer = {
        let layer = CAMetalLayer()
        layer.isOpaque = false
        layer.contentsScale = UIScreen.main.scale
        layer.device = self.metalDevice
        layer.backgroundColor = UIColor.white.cgColor
        layer.pixelFormat = MTLPixelFormat.bgra8Unorm
        layer.framebufferOnly = false
        return layer
    }()
    
    private lazy var checkmarkImageView: ImageView = {
        let view: ImageView = .init(imageName: "scanningSuccessImage", withRenderingMode: false)
        view.isHidden = true
        return view
    }()
    
    private(set) lazy var descriptionLabel: BaseLabel = {
        let label: BaseLabel = .init(config: .init(font: .latoBold(size: 40),
                                                   textColor: UIColor(named: "scanningViewTextColor")))
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private(set) lazy var countdownLabel: BaseLabel = {
        let label = BaseLabel(config: .init(
            title: nil,
            font: .merriweatherBold(size: 75),
            textColor: UIColor(named: "mainAcceptColor")))
        
        label.backgroundColor = .white
        label.clipsToBounds = true
        label.layer.cornerRadius = self.countdownLabelSize.width / 2
        label.isHidden = true
        return label
    }()
    
    private(set) lazy var footImageView: ImageView = {
        let imageView = ImageView(imageName: self.selectedFoot.getBaseImage(), withRenderingMode: true)
        imageView.tintColor = UIColor(named: "scanningViewTextColor")
        return imageView
    }()
    
    private lazy var previousScanImageView: ImageView = {
        let view: ImageView = .init()
        view.isHidden = true
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: - initialisation
    
    init(selectedFoot: FootSideType, screenshotImage: UIImage?) {
        self.selectedFoot = selectedFoot
        super.init(frame: .zero)
        self.initView()
        self.setPreviousImageIfNeeded(image: screenshotImage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.metalContainerView.layer.addSublayer(self.metalLayer)
        self.addSubviews([self.metalContainerView,
                          self.descriptionLabel,
                          self.footImageView,
                          self.countdownLabel,
                          self.previousScanImageView,
                          self.previousScanImageView,
                          self.checkmarkImageView])
    }
    
    // MARK: - lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.metalContainerView.frame = self.bounds
        CATransaction.begin()
        CATransaction.disableActions()
        self.metalLayer.frame = self.metalContainerView.bounds
        self.metalLayer.drawableSize = CGSize(width: self.metalLayer.frame.width * self.metalLayer.contentsScale,
                                              height: self.metalLayer.frame.height * self.metalLayer.contentsScale)
        CATransaction.commit()
    }
    
    // MARK: - constraints
    
    override func updateConstraints() {
        super.updateConstraints()
        self.metalContainerView.snp.updateConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.checkmarkImageView.snp.updateConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(self.checkmarkSize)
        }
        
        self.descriptionLabel.snp.updateConstraints { make in
            make.top.left.right.equalToSuperview().inset(self.descriptionLabelInsets)
        }
        
        self.footImageView.snp.updateConstraints { make in
            make.top.equalTo(self.descriptionLabel.snp.bottom).offset(self.descriptionLabelInsets.bottom)
            make.centerX.equalToSuperview()
            make.size.equalTo(self.footImageSize)
        }
        
        self.countdownLabel.snp.updateConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(self.countdownLabelSize)
        }
        
        self.previousScanImageView.snp.updateConstraints { make in
            make.left.bottom.equalToSuperview().inset(self.previousScanInsets)
            make.size.equalTo(self.previousScanImageSize)
        }
    }
    
    // MARK: - actions
    
    private func setPreviousImageIfNeeded(image: UIImage?) {
        self.previousScanImageView.image = image
        self.previousScanImageView.isHidden = false
    }
    
    func updateUI(withState: ScanningViewStates) {
        switch withState {
        case .defaultState:
            self.footImageView.isHidden = false
            self.footImageView.tintColor = UIColor(named: "scanningViewTextColor")
            self.checkmarkImageView.isHidden = true
            self.descriptionLabel.config?.title = self.selectedFoot.getDescriptionTitle().localized
            self.descriptionLabel.config?.textColor = UIColor(named: "scanningViewTextColor")
        case .scanningSuccess:
            self.footImageView.isHidden = true
            self.checkmarkImageView.isHidden = false
            self.descriptionLabel.config?.title = "scanning-finished".localized
            self.descriptionLabel.config?.textColor = UIColor(named: "scanningSuccessColor")
        }
    }
    
    private func setCountdown(seconds: Int) {
        self.countdownLabel.isHidden = seconds == 0
        self.countdownLabel.text = "\(seconds)"
        self.countdownLabel.sizeToFit()
    }
    
    // MARK: - timer actions for countdown
    
    func stopCountdown() {
        self.isCountedDown = false
    }
    
    func startCountdown(changeAction: @escaping (String) -> Void,
                        completion: @escaping (ScanningViewControllerState) -> Void) {
        let state: ScanningViewControllerState = .countdownSeconds(self.countdownStartCount)
        self.isCountedDown = true
        guard self.countdownStartCount > 0 else {
            completion(state)
            return
        }
        
        self.iterateCountdown(state: state,
                              changeAction: changeAction) { state in completion(state) }
    }
    
    private func iterateCountdown(state: ScanningViewControllerState,
                                  changeAction: @escaping (String) -> Void,
                                  completion: @escaping (ScanningViewControllerState) -> Void) {
        ScanningHapticFeedbackEngine.shared.countdownCountedDown()
        guard self.isCountedDown,
              case let ScanningViewControllerState.countdownSeconds(seconds) = state, seconds > 0 else {
            self.isCountedDown = false
            completion(state)
            return
        }
        
        self.setCountdown(seconds: seconds)
        changeAction("\(seconds)")
        
        self.countdownLabel.alpha = 1
        UIView.animate(withDuration: self.countdownPerSecondDuration, animations: {
            self.countdownLabel.alpha = 0
        }) { [weak self] finished in
            if finished, seconds > 0 {
                let newState = ScanningViewControllerState.countdownSeconds(seconds - 1)
                self?.iterateCountdown(state: newState, changeAction: changeAction, completion: completion)
            }
        }
    }
}
