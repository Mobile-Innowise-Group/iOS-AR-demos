import UIKit

final class ManualScanningSecondStepView: ManualScaningOverlayContainerView {
    
    // MARK: - variables
    
    var continueAction: (() -> Void)?
    private let titleInsets: UIEdgeInsets = .init(top: 8, left: 38, bottom: 22, right: 38)
    private let stepViewInsets: UIEdgeInsets = .init(top: 12, left: 20, bottom: 0, right: 20)
    private let buttonInsets: UIEdgeInsets = .init(top: 30,
                                                   left: 0,
                                                   bottom: (AppConstants.screenSize.height / 10),
                                                   right: 0)
    
    // MARK: - gui variable
    
    private lazy var titleView: BaseLabel = .init(config: .init(title: "manualScan-secondStep-title",
                                                                font: .merriweatherBold(size: 24)))
    
    private lazy var firstStepView: StepTitleDescriptionView = .init(config: .init(
        title: "manualScan-secondStep-firstRule-title",
        description: "manualScan-secondStep-firstRule-description",
        stepNumber: 1))
    
    private lazy var secondStepView: StepTitleDescriptionView = .init(config: .init(
        title: "manualScan-secondStep-secondRule-title",
        description: "manualScan-secondStep-secondRule-description",
        stepNumber: 2))
    
    private lazy var thirdStepView: StepTitleDescriptionView = .init(config: .init(
        title: "manualScan-secondStep-thirdRule-title",
        description: "manualScan-secondStep-thirdRule-description",
        stepNumber: 3))
    
    private lazy var continueButton: BaseButton = .init(config: .init(
        title: "manualScan-secondStep-button-title",
        action: { [weak self] in
            self?.continueAction?() }))
    
    // MARK: - initialization
    
    override func initView() {
        super.initView()
        self.contentView.addSubview(self.titleView)
        self.contentView.addSubview(self.firstStepView)
        self.contentView.addSubview(self.secondStepView)
        self.contentView.addSubview(self.thirdStepView)
        self.contentView.addSubview(self.continueButton)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        self.titleView.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(self.titleInsets)
            make.left.greaterThanOrEqualToSuperview().inset(self.titleInsets)
            make.right.lessThanOrEqualToSuperview().inset(self.titleInsets)
            make.centerX.equalToSuperview()
        }
        
        self.firstStepView.snp.updateConstraints { make in
            make.top.equalTo(self.titleView.snp.bottom).offset(self.titleInsets.bottom)
            make.left.greaterThanOrEqualToSuperview().inset(self.stepViewInsets)
            make.right.lessThanOrEqualToSuperview().inset(self.stepViewInsets)
            make.centerX.equalToSuperview()
        }
        
        self.secondStepView.snp.updateConstraints { make in
            make.top.equalTo(self.firstStepView.snp.bottom).offset(self.stepViewInsets.top)
            make.left.equalTo(self.firstStepView.snp.left)
            make.right.lessThanOrEqualToSuperview().inset(self.stepViewInsets)
        }
        
        self.thirdStepView.snp.updateConstraints { make in
            make.top.equalTo(self.secondStepView.snp.bottom).offset(self.stepViewInsets.top)
            make.left.equalTo(self.firstStepView.snp.left)
            make.right.lessThanOrEqualToSuperview().inset(self.stepViewInsets)
        }
        
        self.continueButton.snp.updateConstraints { make in
            make.top.greaterThanOrEqualTo(self.thirdStepView.snp.bottom).offset(self.buttonInsets.top)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview().inset(self.buttonInsets)
        }
    }
}
