
import UIKit

final class OTPTextField: UITextField {
    
    // MARK: - variables
    
    var deleteButtonAction: (() -> Void)?
    
    // MARK: - initialization
    
    init() {
        super.init(frame: .zero)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.keyboardType = .numberPad
        self.textContentType = .oneTimeCode
        self.textAlignment = .center
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(named: "secondaryMainColor")?.cgColor ?? UIColor.gray.cgColor
        self.font = CustomFonts.lato(size: 24).getFont()
    }
    
    // MARK: - actions
    
    override func deleteBackward() {
        if self.text?.isEmpty == true { self.deleteButtonAction?() }
        super.deleteBackward()
    }
}
