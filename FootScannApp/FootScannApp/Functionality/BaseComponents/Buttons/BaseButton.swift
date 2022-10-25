import UIKit

class BaseButton: UIButton {
    
    enum ButtonStyle {
        case primary
        case secondary
        case secondaryBordless
        
        func getFont(fontSize: CGFloat) -> UIFont {
            switch self {
            case .primary:
                return CustomFonts.latoBlack(size: fontSize).getFont()
            case .secondary:
                return CustomFonts.latoBold(size: fontSize).getFont()
            case .secondaryBordless:
                return CustomFonts.lato(size: fontSize).getFont()
            }
        }
    }
    
    struct ButtonConfig {
        var title: String
        var buttonStyle: ButtonStyle = .primary
        var color: UIColor? = UIColor(named: "mainAcceptColor")
        var fontSize: CGFloat = 16
        var action: (() -> Void)? = nil
    }
    
    // MARK: - variables
    
    var config: ButtonConfig {
        didSet { self.setConfig() }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.setAccessebilityEnabledState()
            self.backgroundColor = self.isEnabled ? self.config.color : UIColor(named: "secondaryMainColor")
            self.setShadowIfNeeded()
        }
    }
    
    // MARK: - init

    required init(config: ButtonConfig) {
        self.config = config
        super.init(frame: .zero)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - actions
    
    @objc func buttonAction() {
        self.config.action?()
    }
    
    private func setupView() {
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.layer.cornerRadius = 4
        self.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.accessibilityLabel = self.config.title.accessibility
        self.contentEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
        self.setConfig()
    }
    
    // MARK: - setters
    
    func setUnderlinedText() {
        let textRange = NSMakeRange(0, self.config.title.count)
        let attributedText = NSMutableAttributedString(string: self.config.title)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
        self.titleLabel?.attributedText = attributedText
    }
    
    private func setConfig() {
        self.setTitle(self.config.title.localized, for: .normal)
        self.titleLabel?.font = self.config.buttonStyle.getFont(fontSize: self.config.fontSize)
        
        if self.config.buttonStyle == .primary {
            self.setShadowIfNeeded()
            self.setTitleColor(.white, for: .normal)
            self.backgroundColor = self.isEnabled ? self.config.color : UIColor(named: "secondaryMainColor")
        } else {
            self.setTitleColor(UIColor(named: "buttonTextSecondaryColor"), for: .normal)
            
            if self.config.buttonStyle == .secondary {
                self.layer.borderWidth = 1
                self.layer.borderColor = UIColor(named: "buttonTextSecondaryColor")?.cgColor
            }
        }
    }
    
    private func setShadowIfNeeded() {
        guard self.config.buttonStyle == .primary else { return }
        self.layer.shadowColor = self.config.color?.withAlphaComponent(0.4).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 16
        self.layer.shadowOpacity = self.isEnabled ? 1 : 0
    }
    
    private func setAccessebilityEnabledState() {
        if self.isEnabled {
            self.accessibilityTraits.remove(.notEnabled)
        } else {
            self.accessibilityTraits.insert(.notEnabled)
        }
    }
}
