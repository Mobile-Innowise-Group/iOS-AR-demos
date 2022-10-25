import UIKit

class BaseLabel: UILabel {
    
    struct Config {
        var title: String? = nil
        var font: CustomFonts = .lato(size: 16)
        var textColor: UIColor? = UIColor(named: "textColor")
        var textAlignment: NSTextAlignment = .center
    }
    
    // MARK: - variables
    
    var textContainerInset: UIEdgeInsets = .zero {
           didSet { self.setNeedsDisplay() }
       }
    
    var config: Config? {
        didSet { self.setup() }
    }
    
    // MARK: - initialization

    required init(config: Config?) {
        self.config = config
        super.init(frame: .zero)
        self.initView()
    }
    
    func initView() {
        self.setup()
        self.numberOfLines = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setters
    
    func setAttributedText(attributedText: NSMutableAttributedString) {
        self.attributedText = attributedText
        self.accessibilityLabel = attributedText.string
    }
    
    private func setup() {
        guard let config = self.config else { return }
        self.text = config.title?.localized
        self.font = config.font.getFont()
        self.textColor = config.textColor ?? .black
        self.textAlignment = config.textAlignment
        self.accessibilityLabel = config.title?.accessibility
    }
    
    // MARK: - UILabel methods
       override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
           let insetRect: CGRect = bounds.inset(by: self.textContainerInset)
           let textRect: CGRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
           let invertedInsets: UIEdgeInsets = UIEdgeInsets(
               top: -self.textContainerInset.top,
               left: -self.textContainerInset.left,
               bottom: -self.textContainerInset.bottom,
               right: -self.textContainerInset.right)
           return textRect.inset(by: invertedInsets)
       }

       override func drawText(in rect: CGRect) {
           super.drawText(in: rect.inset(by: self.textContainerInset))
       }
}
