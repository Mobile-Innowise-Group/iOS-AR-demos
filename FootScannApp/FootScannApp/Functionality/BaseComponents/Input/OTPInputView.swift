
import UIKit

final class OTPInputView: UIView {
    
    // MARK: - variables
    
    private var editingChangedAction: (String?) -> Void
    
    var otpText: String? {
        guard let firstText = self.firstTextField.text,
              let secondText = self.secondTextField.text,
              let thirdText = self.thirdTextField.text,
              let fourthText = self.fourthTextField.text else { return nil }
        return "\(firstText)\(secondText)\(thirdText)\(fourthText)"
    }
    
    private let descriptionTopOffset: CGFloat = 12
    private let textFieldSize: CGSize = .init(width: 47, height: 47)
    
    // MARK: - gui variables
    
    private lazy var textFieldsStackView: UIStackView = {
        let view: UIStackView = .init(arrangedSubviews: [
            self.firstTextField,
            self.secondTextField,
            self.thirdTextField,
            self.fourthTextField
        ])
        
        view.spacing = 19
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var firstTextField: OTPTextField = {
        return self.createTextField()
    }()
    
    private lazy var secondTextField: OTPTextField = {
        return self.createTextField()
    }()
    
    private lazy var thirdTextField: OTPTextField = {
        return self.createTextField()
    }()
    
    private lazy var fourthTextField: OTPTextField = {
        return self.createTextField()
    }()
    
    private lazy var descriptionLabel: BaseLabel = {
        let view: BaseLabel = .init(config: .init(title: "signIn-otpVerification-codeError-text",
                                                  font: .lato(size: 12),
                                                  textColor: .red,
                                                  textAlignment: .left))
        view.isHidden = true
        return view
    }()
    
    // MARK: - initialisation
    
    init(editingChangedAction: @escaping (String?) -> Void) {
        self.editingChangedAction = editingChangedAction
        super.init(frame: .zero)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.addSubview(self.textFieldsStackView)
        self.addSubview(self.descriptionLabel)
    }
    
    // MARK: - constraints
    
    override func updateConstraints() {
        super.updateConstraints()
        
        self.textFieldsStackView.snp.updateConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        self.firstTextField.snp.updateConstraints { make in
            make.size.equalTo(self.textFieldSize)
        }
        
        self.secondTextField.snp.updateConstraints { make in
            make.size.equalTo(self.textFieldSize)
        }
        
        self.thirdTextField.snp.updateConstraints { make in
            make.size.equalTo(self.textFieldSize)
        }
        
        self.fourthTextField.snp.updateConstraints { make in
            make.size.equalTo(self.textFieldSize)
        }
        
        self.descriptionLabel.snp.updateConstraints { make in
            make.top.equalTo(self.textFieldsStackView.snp.bottom).offset(self.descriptionTopOffset)
            make.left.bottom.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
    }
    
    // MARK: - setters
    
    func setErrorState(isError: Bool) {
        self.descriptionLabel.isHidden = !isError
        let borderColor = isError ? UIColor.red.cgColor : (UIColor(named: "secondaryMainColor")?.cgColor ?? UIColor.gray.cgColor)
        self.firstTextField.layer.borderColor = borderColor
        self.secondTextField.layer.borderColor = borderColor
        self.thirdTextField.layer.borderColor = borderColor
        self.fourthTextField.layer.borderColor = borderColor
    }
    
    func clearTextFields() {
        self.firstTextField.text = ""
        self.secondTextField.text = ""
        self.thirdTextField.text = ""
        self.fourthTextField.text = ""
        self.firstTextField.becomeFirstResponder()
    }
    
    private func setEnteredText(_ text: String) {
        var prefix = text.prefix(4)
        guard Int(prefix) != nil else { return }
        
        var focusedTextField: UITextField?
        if prefix.count > 0 {
            focusedTextField = self.firstTextField
            self.firstTextField.text = String(prefix.removeFirst())
        }
        
        if prefix.count > 0 {
            focusedTextField = self.secondTextField
            self.secondTextField.text = String(prefix.removeFirst())
        }
        if prefix.count > 0 {
            focusedTextField = self.thirdTextField
            self.thirdTextField.text = String(prefix.removeFirst())
        }
        
        if prefix.count > 0 {
            focusedTextField = self.fourthTextField
            self.fourthTextField.text = String(prefix.removeFirst())
        }
        
        focusedTextField?.becomeFirstResponder()
    }
    
    private func setFirstEmptyTextFieldAsResponder() {
        var focusedTextField: UITextField?
        switch true {
        case self.firstTextField.text?.isEmpty == true:
            focusedTextField = self.firstTextField
        case self.secondTextField.text?.isEmpty == true:
            focusedTextField = self.secondTextField
        case self.thirdTextField.text?.isEmpty == true:
            focusedTextField = self.thirdTextField
        case self.fourthTextField.text?.isEmpty == true:
            focusedTextField = self.fourthTextField
        default: break
        }
        
        DispatchQueue.main.async { [weak focusedTextField] in
            focusedTextField?.becomeFirstResponder()
        }
    }
    
    // MARK: - actions
    
    private func createTextField() -> OTPTextField {
        let textField = OTPTextField()
        textField.delegate = self
        textField.addTarget(self, action: #selector(self.changeCharacter), for: .editingChanged)
        textField.deleteButtonAction = { [weak self, weak textField] in
            guard let textField = textField else { return }
            self?.changeCharacter(textField: textField)
        }
        return textField
    }
    
    @objc func changeCharacter(textField : UITextField, withText: String? = nil) {
        var textFieldForResponding: UITextField?
        if textField.text?.utf8.count == 1 {
            switch textField {
            case self.firstTextField:
                textFieldForResponding = self.secondTextField
            case self.secondTextField:
                textFieldForResponding = self.thirdTextField
            case self.thirdTextField:
                textFieldForResponding = self.fourthTextField
            case self.fourthTextField:
                self.self.fourthTextField.endEditing(true)
            default:
                break
            }
        } else if textField.text?.isEmpty == true {
            switch textField {
            case self.fourthTextField:
                textFieldForResponding = self.thirdTextField
            case self.thirdTextField:
                textFieldForResponding = self.secondTextField
            case self.secondTextField:
                textFieldForResponding = self.firstTextField
            default:
                break
            }
        }
        
        textFieldForResponding?.becomeFirstResponder()
        if let text = withText { textFieldForResponding?.text = text }
        
        self.editingChangedAction(self.otpText)
    }
}

extension OTPInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.count == 1, !string.isEmpty {
            self.changeCharacter(textField: textField, withText: string)
            return false
        }
        
        if string.count > 1 {
            self.setEnteredText(string)
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField.text?.isEmpty == true else { return }
        self.setFirstEmptyTextFieldAsResponder()
    }
}
