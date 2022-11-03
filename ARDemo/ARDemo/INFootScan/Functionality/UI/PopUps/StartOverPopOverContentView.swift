import UIKit

struct StartOverPopOverContentViewConfig {
    var mainLabelText: String
    var mainButtonTitle: String
    var secondaryButtonTitle: String
}

final class StartOverPopOverContentView: UIView {
    
    // MARK: - Variables
    
    var mainButtonAction: (() -> Void)?
    var secondaryButtonAction: (() -> Void)?
    
    var mainLabelText: String
    var mainButtonTitle: String
    var secondaryButtonTitle: String
    
    private let buttonOffset = 39
    private let secondaryButtonOffset = 24
    
    // MARK: - GUI variables
    
    private lazy var mainLabel = BaseLabel(config: .init(
        title: self.mainLabelText,
        font: CustomFonts.latoBold(size: 24)))
    
    private lazy var button: BaseButton = .init(config: .init(
        title: self.mainButtonTitle,
        action: { [weak self] in self?.mainButtonAction?() }))
    
    private lazy var secondaryButton = UnderlinedButton(text: self.secondaryButtonTitle,
                                                        action: { [weak self] in self?.secondaryButtonAction?()
    })
    
    // MARK: - Initialization
    
    init(config: StartOverPopOverContentViewConfig) {
        self.mainLabelText = config.mainLabelText
        self.mainButtonTitle = config.mainButtonTitle
        self.secondaryButtonTitle = config.secondaryButtonTitle
        super.init(frame: .zero)
        self.addViews()
        self.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Adding views
    
    private func addViews() {
        self.addSubviews([self.mainLabel,
                          self.button,
                          self.secondaryButton])
    }
    
    // MARK: - Constraints
    
    override func updateConstraints() {
        super.updateConstraints()
        mainLabel.snp.updateConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        button.snp.updateConstraints { make in
            make.top.equalTo(self.mainLabel.snp.bottom).offset(self.buttonOffset)
            make.leading.trailing.equalToSuperview()
        }
        secondaryButton.snp.updateConstraints { make in
            make.top.equalTo(self.button.snp.bottom).offset(self.secondaryButtonOffset)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.right.bottom.lessThanOrEqualToSuperview()
        }
    }
}
