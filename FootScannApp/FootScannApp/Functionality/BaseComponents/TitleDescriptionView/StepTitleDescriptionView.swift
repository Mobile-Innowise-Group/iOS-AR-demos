
import UIKit

final class StepTitleDescriptionView: UIView {
    
    struct Config {
        var title: String
        var description: String
        var stepNumber: Int
    }
    
    // MARK: - variables
    
    var config: Config {
        didSet { self.setConfigs() }
    }
    
    private let countLabelSize: CGSize = .init(width: 23, height: 23)
    private let lineViewHeight: CGFloat = 75
    private let lineViewTopOffset: CGFloat = 12
    private let titleLabelInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 14, right: 0)
    
    // MARK: - gui variables
    
    private lazy var titleLabel: BaseLabel = .init(config: .init(title: self.config.title,
                                                                 font: .latoBold(size: 18),
                                                                 textAlignment: .left))
    
    private lazy var descriptionLabel: BaseLabel = .init(config: .init(title: self.config.description,
                                                                       textAlignment: .left))
    
    private lazy var countNumberLabel: BaseLabel = {
        let view: BaseLabel = .init(config: .init(title: "\(self.config.stepNumber)",
                                                  font: .lato(size: 14),
                                                  textColor: .white))
        view.layer.cornerRadius = self.countLabelSize.height / 2
        view.clipsToBounds = true
        view.backgroundColor = UIColor(named: "mainAcceptColor")
        return view
    }()
    
    private lazy var lineView: LineView = {
        let view: LineView = .init()
        view.axis = .vertical
        view.heightOfLine = 2
        view.backgroundColor = UIColor(named: "secondaryMainColor")
        return view
    }()
    
    // MARK: - initialisation
    
    init(config: Config) {
        self.config = config
        super.init(frame: .zero)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.addSubview(self.countNumberLabel)
        self.addSubview(self.lineView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.descriptionLabel)
        
        self.setVoiceOver()
        self.setConfigs()
    }
    
    // MARK: - constraints
    
    override func updateConstraints() {
        super.updateConstraints()
        self.countNumberLabel.snp.updateConstraints { make in
            make.top.left.equalToSuperview()
            make.size.equalTo(self.countLabelSize)
        }
        
        self.titleLabel.snp.updateConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(self.countNumberLabel.snp.right).offset(self.titleLabelInsets.left)
            make.right.lessThanOrEqualToSuperview()
        }
        
        self.lineView.snp.updateConstraints { make in
            make.top.equalTo(self.countNumberLabel.snp.bottom).offset(self.lineViewTopOffset)
            make.left.greaterThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
            make.centerX.equalTo(self.countNumberLabel.snp.centerX)
            make.height.equalTo(self.lineViewHeight)
        }
        
        self.descriptionLabel.snp.updateConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.titleLabelInsets.bottom)
            make.left.equalTo(self.titleLabel.snp.left)
            make.right.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    // MARK: - setters
    
    
    private func setVoiceOver() {
        self.titleLabel.isAccessibilityElement = false
        self.descriptionLabel.isAccessibilityElement = false
        self.countNumberLabel.isAccessibilityElement = false
        self.isAccessibilityElement = true
    }
    
    private func setAccessibilityLabel() {
        self.accessibilityLabel = "Step \(self.config.stepNumber), \(self.config.title.localized), \(self.config.description.localized)"
    }
    
    private func setConfigs() {
        self.titleLabel.config?.title = self.config.title
        self.descriptionLabel.config?.title = self.config.description
        self.countNumberLabel.config?.title = "\(self.config.stepNumber)"
        self.countNumberLabel.sizeToFit()
        self.setAccessibilityLabel()
    }
}
