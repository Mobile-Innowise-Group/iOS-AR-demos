import UIKit

final class PaddedTextField: UITextField {
    
    // MARK: - Variables
    
    var textInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    convenience init() {
        self.init(frame: .zero)
        self.initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initView()
    }
    
    private func initView() {
        self.smartInsertDeleteType = .no
        self.textInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        self.textAlignment = .left
        self.font = CustomFonts.lato(size: 16).getFont()
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(named: "closeButtonDeepBlue")?.cgColor
        self.layer.cornerRadius = 8
    }
    
    // MARK: - Configure insets
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
}
