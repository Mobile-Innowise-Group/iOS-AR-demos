import UIKit

final class ManualScanningFirstStepView: ManualScaningOverlayContainerView {
    
    // MARK: - variables
    
    var continueAction: (() -> Void)?
    private let imageSize: CGSize = .init(width: 101, height: 138)
    private let titleInsets: UIEdgeInsets = .init(top: 32, left: 38, bottom: 44, right: 38)
    private let descriptionInsets: UIEdgeInsets = .init(top: 44, left: 38, bottom: 0, right: 38)
    private let buttonInsets: UIEdgeInsets = .init(top: 44,
                                                   left: 0,
                                                   bottom: (AppConstants.screenSize.height / 10),
                                                   right: 0)
    
    // MARK: - gui variable
    
    private lazy var titleView: BaseLabel = .init(config: .init(title: "manualScan-firstStep-title",
                                                                font: .merriweatherBold(size: 24)))
    
    private lazy var imageView: ImageView = .init(imageName: "manualScanPreparationImage")
    
    private lazy var descriptionView: BaseLabel = .init(config: .init(title: "manualScan-firstStep-description",
                                                                      font: .lato(size: 20)))
    
    private lazy var continueButton: BaseButton = {
        let view: BaseButton = .init(config: .init(
            title: "continue",
            buttonStyle: .secondaryBordless,
            fontSize: 18,
            action: { [weak self] in
                self?.continueAction?() }))
        view.setUnderlinedText()
        return view
    }()
    
    // MARK: - initialization
    
    override func initView() {
        super.initView()
        self.contentView.addSubviews([self.titleView,
                                      self.imageView,
                                      self.descriptionView,
                                      self.continueButton])
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        self.titleView.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(self.titleInsets)
            make.left.greaterThanOrEqualToSuperview().inset(self.titleInsets)
            make.right.lessThanOrEqualToSuperview().inset(self.titleInsets)
            make.centerX.equalToSuperview()
        }
        
        self.imageView.snp.updateConstraints { make in
            make.top.equalTo(self.titleView.snp.bottom).offset(self.titleInsets.bottom)
            make.centerX.equalToSuperview()
            make.size.equalTo(self.imageSize)
        }
        
        self.descriptionView.snp.updateConstraints { make in
            make.top.equalTo(self.imageView.snp.bottom).offset(self.descriptionInsets.top)
            make.left.greaterThanOrEqualToSuperview().inset(self.descriptionInsets)
            make.right.lessThanOrEqualToSuperview().inset(self.descriptionInsets)
            make.centerX.equalToSuperview()
        }
        
        self.continueButton.snp.updateConstraints { make in
            make.top.greaterThanOrEqualTo(self.descriptionView.snp.bottom).offset(self.buttonInsets.top)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview().inset(self.buttonInsets)
        }
    }
}
