import UIKit

final class CloseButton: ImageView {
    
    // MARK: - variables
    
    var btnAction: (() -> Void)?
    
    // MARK: - initialization
    init() {
        super.init(systemName: "xmark.circle.fill", withRenderingMode: true)
        setUpAccessibility()
        addGestureRecognizer()
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyCircleForm()
    }
    
    // MARK: - Configuration
    
    private func applyCircleForm() {
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = frame.height / 2
    }
    
    private func setUI() {
        tintColor = UIColor(named: "closeButtonDeepBlue")
    }
    
    private func setUpAccessibility() {
        self.isAccessibilityElement = true
        self.accessibilityLabel = "closeButton-title".accessibility
        self.accessibilityTraits = .button
    }
    
    // MARK: - Actions
    
    private func addGestureRecognizer() {
        let tap = UIGestureRecognizer(target: self, action: #selector(doAction))
        self.addGestureRecognizer(tap)
    }
    
    @objc private func doAction() {
        btnAction?()
    }
}
