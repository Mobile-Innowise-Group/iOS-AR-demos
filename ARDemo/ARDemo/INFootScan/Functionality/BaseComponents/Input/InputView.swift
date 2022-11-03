import UIKit

final class InputView: UIView {
    
    enum TextFieldType {
        case email
        case measure
        case phone
    }
    
    enum InputState {
        case error
        case common
    }
    
    // MARK: - variables
    
    var edgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 2, right: 0) {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    var iconAction: (() -> Void)?
    var textChangeAction: ((String?) -> Void)?
    
    var text: String {
        get {
            return self.textField.text ?? ""
        }
        set {
            self.textField.text = newValue
            self.textDidChange()
        }
    }
    
    var textDoubleValue: Double?
    var additionalTextPlaceholder: String? {
        didSet { self.setRightViewIfNeeded() }
    }
    
    var placeholderText: String? {
        didSet {
            self.setPlaceholderIfNeeded()
        }
    }
    
    var showClearIcon: Bool = true {
        didSet { self.iconTouchView.isHidden = !self.showClearIcon }
    }
    
    private var textFieldType: TextFieldType
    private var inputState: InputState = .common
    
    private let descriptionLabelOffset = 3
    private let textFieldHeight = 46
    
    private var textDescription: String? {
        didSet {
            self.descriptionLabel.text = self.textDescription?.localized
        }
    }
    
    private var textFieldTextColor: UIColor {
        return UIColor(named: "textColor") ?? .gray
    }
    
    private var placeholderColor: UIColor {
        return UIColor(named: "placeholderTextColor") ?? .gray
    }
    
    private var clearButtonColor: UIColor {
        return UIColor(named: "secondaryMainColor") ?? .gray
    }
    
    private let clearTapZoneSize = CGSize(width: 36, height: 36)
    private let clearImageSize = CGSize(width: 18, height: 18)
    
    private var placeholder: NSAttributedString? {
        guard let text = self.placeholderText?.localized else {
            return nil
        }
        return NSAttributedString(
            string: text,
            attributes: self.placeholderAttributes)
    }
    
    private var placeholderAttributes: [NSAttributedString.Key: Any] {
        [NSAttributedString.Key.foregroundColor: self.placeholderColor as Any,
         NSAttributedString.Key.font: CustomFonts.lato(size: 16).getFont()
        ]
    }
    
    // MARK: - gui variables
    
    private lazy var contentContainer: UIView = .init()
    
    private lazy var rightTextView: UILabel = {
        let label = UILabel()
        label.isAccessibilityElement = false
        label.text = self.additionalTextPlaceholder?.localized
        label.sizeToFit()
        return label
    }()

    private lazy var iconTouchView: UIView = {
        let view = UIView()
        view.addGestureRecognizer(TapGestureRecognizer(action: { [weak self] in
            self?.clearText()
        }))
        view.addSubview(self.iconView)
        view.isHidden = true

        return view
    }()
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "xmark.circle.fill"))
        view.tintColor = self.clearButtonColor
        return view
    }()
    
    private(set) lazy var textField: PaddedTextField = {
        var textField = PaddedTextField()
        textField.textColor = self.textFieldTextColor
        textField.delegate = self
        textField.addTarget(self, action: #selector(self.textDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var descriptionLabel: BaseLabel = .init(config: .init(font: .lato(size: 12),
                                                                           textColor: self.placeholderColor,
                                                                           textAlignment: .left))
    
    // MARK: - initialization
    
    init(type: TextFieldType) {
        self.textFieldType = type
        super.init(frame: .zero)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.addSubview(self.contentContainer)
        self.contentContainer.addSubview(self.textField)
        
        self.addSubview(self.descriptionLabel)
        self.addSubview(self.iconTouchView)
        
        switch self.textFieldType {
        case .email:
            self.textField.keyboardType = .emailAddress
            self.textField.textContentType = .emailAddress
        case .phone:
            self.textField.keyboardType = .phonePad
            self.addDoneButtonOnNumpad()
        case .measure:
            self.textField.keyboardType = .decimalPad
            self.addDoneButtonOnNumpad()
        }
        
        self.backgroundColor = .clear
        self.setPlaceholderIfNeeded()
        
        self.addGestureRecognizer(TapGestureRecognizer(action: { [weak self] in
            self?.setFirstResponder()
        }))
        
        self.setupVoiceOver()
    }
    
    // MARK: - voice over
    
    private func setupVoiceOver() {
        self.isAccessibilityElement = false
        self.contentContainer.isAccessibilityElement = true
        self.contentContainer.accessibilityHint = "textField-title".accessibility
        self.textField.isAccessibilityElement = false
        self.iconTouchView.accessibilityLabel = "clearTextFieldButton-title".accessibility
        self.iconTouchView.accessibilityTraits = .button
        self.iconTouchView.isAccessibilityElement = false
        self.accessibilityElements = [self.contentContainer, self.iconTouchView, self.descriptionLabel]
    }
    
    // MARK: - constraints
    override func updateConstraints() {
        super.updateConstraints()
        
        self.contentContainer.snp.remakeConstraints { make in
            make.top.left.equalToSuperview().inset(self.edgeInsets)
            if self.iconTouchView.isHidden  {
                make.right.equalToSuperview().inset(self.edgeInsets)
            } else {
                make.right.equalToSuperview().inset(self.clearImageSize.width + 5)
            }
        }
        
        self.textField.snp.updateConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(self.textFieldHeight)
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        self.descriptionLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self.contentContainer.snp.bottom).offset(self.descriptionLabelOffset)
            make.left.greaterThanOrEqualToSuperview().inset(self.edgeInsets)
            make.right.equalToSuperview().inset(self.edgeInsets)
            make.bottom.equalToSuperview().inset(self.edgeInsets)
        }
        
        self.iconTouchView.snp.updateConstraints { (make) in
            make.centerY.equalTo(self.textField.snp.centerY)
            make.size.equalTo(self.clearTapZoneSize)
            make.right.equalToSuperview().inset(self.clearImageSize.width / 2)
        }
        
        self.iconView.snp.updateConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(self.clearImageSize)
        }
    }
    
    
    // MARK: - actions
    
    @objc private func textDidChange() {
        self.upateUIByTextChanging()
        
        if self.textFieldType == .measure {
            self.textDoubleValue = Double(self.textField.text ?? "")
            self.setMeasureAccessibilityValue()
        } else {
            self.contentContainer.accessibilityValue = self.textField.text
        }
        
        self.textChangeAction?(self.textField.text)
    }
    
    @objc private func viewTapped() {
        self.becomeFirstResponder()
    }
    
    private func setPlaceholderIfNeeded() {
        guard (self.textField.text ?? "").isEmpty, self.placeholder != nil else { return }
        if self.textFieldType == .measure && self.textField.isFirstResponder {
            self.textField.attributedPlaceholder = nil
        } else {
            self.textField.attributedPlaceholder = self.placeholder
            self.contentContainer.accessibilityValue = self.placeholderText?.accessibility
        }
    }
    
    private func showClearButtonIfNeeded() {
        guard self.showClearIcon else { return }
        let isButtonHidden = (self.textField.text ?? "").isEmpty
        self.iconTouchView.isAccessibilityElement = !isButtonHidden
        self.iconTouchView.isHidden = (self.textField.text ?? "").isEmpty
    }
    
    private func clearText() {
        self.textDoubleValue = nil
        self.text = ""
        self.textChangeAction?(nil)
        self.textField.rightViewMode = .whileEditing
    }
    
    private func upateUIByTextChanging() {
        self.removeErrorIfNeeded()
        self.showClearButtonIfNeeded()
        self.setPlaceholderIfNeeded()
    }
    
    @objc func doneButtonAction() {
        self.textField.rightViewMode = self.text.isEmpty ? .whileEditing : .always
        self.endEditing(true)
        self.setPlaceholderIfNeeded()
        
        self.setReturnAccessibilityFocus()
    }
    
    // MARK: - setters
    
    func setError(description: String) {
        self.textDescription = description
        self.inputState = .error
        self.textField.layer.borderColor = UIColor.red.cgColor
        self.descriptionLabel.textColor = .red
    }

    func setFirstResponder() {
        if self.textFieldType == .measure {
            self.textField.attributedPlaceholder = nil
        }
        self.textField.becomeFirstResponder()
    }
    
    private func setReturnAccessibilityFocus() {
        let viewToFocusAfterReturn: UIView
        if self.inputState == .error {
            viewToFocusAfterReturn = self.descriptionLabel
        } else if self.text.isEmpty {
            viewToFocusAfterReturn = self.contentContainer
        } else {
            viewToFocusAfterReturn = self.iconTouchView
        }
        UIAccessibility.post(notification: .layoutChanged,
                             argument: viewToFocusAfterReturn)
    }
    
    private func setMeasureAccessibilityValue() {
        let textValueForAccessibility = (self.textField.text ?? "")
        + (self.textDoubleValue == 1 ? "centimiter-title".accessibility : "centimiters-title".accessibility)
        self.contentContainer.accessibilityValue = textValueForAccessibility
    }
    
    private func removeErrorIfNeeded() {
        guard self.inputState == .error else { return }
        self.inputState = .common
        self.textDescription = ""
        self.textField.layer.borderColor = UIColor(named: "closeButtonDeepBlue")?.cgColor
        self.descriptionLabel.textColor = self.placeholderColor
    }
    
    private func setRightViewIfNeeded() {
        guard self.additionalTextPlaceholder != nil else { return }
        self.textField.rightView = self.rightTextView
        self.textField.rightViewMode = .whileEditing
    }
    
    private func addDoneButtonOnNumpad() {
        let keypadToolbar: UIToolbar = UIToolbar(frame: CGRect(origin: .zero,
                                                               size: CGSize(width: AppConstants.screenSize.width,
                                                                            height: 44.0)))
        keypadToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                            target: self,
                            action: nil),
            UIBarButtonItem(title: "doneButton-title".localized,
                            style: .done,
                            target: self,
                            action: #selector(self.doneButtonAction))
        ]
        keypadToolbar.sizeToFit()

        self.textField.inputAccessoryView = keypadToolbar
    }
    
    private func maskInputPhoneNumber(for insertedText: String) {
        let code = String(insertedText.prefix(3))
        let startIndex = insertedText.index(after: insertedText.startIndex)
        let firstNumberIndex = insertedText.index(startIndex, offsetBy: 2)
        let number = String(insertedText[firstNumberIndex...])
        self.textField.text = "\(code)-\(number)"
        self.textDidChange()
    }
}

extension InputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.doneButtonAction()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.setPlaceholderIfNeeded()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.textFieldType == .measure, string == ",", let text = textField.text {
            if text.contains(".") == true { return false }
            textField.text = text + "."
            return false
        }
        
        if self.textFieldType == .phone, let text = textField.text, text.count == 3, !string.isEmpty {
            textField.text = text + "-"
            return true
        }
        
        if self.textFieldType == .phone, let text = textField.text, text.count == 5, string.isEmpty {
            textField.text = text.replacingOccurrences(of: "-", with: "")
            return true
        }
        
        if self.textFieldType == .phone, string.count > 3, Int(string) != nil {
            self.maskInputPhoneNumber(for: string)
            return false
        }
    
        return true
    }
}
