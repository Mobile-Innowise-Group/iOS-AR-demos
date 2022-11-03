
import UIKit

final class TitleDescriptionView: UIStackView {
    
    // MARK: - variables
    
    var title: String? {
        didSet {
            self.titleLabel.config?.title = self.title?.localized
            self.accessibilityLabel = self.title?.accessibility
        }
    }
    
    var titleLabelConfig: BaseLabel.Config? {
        get { self.titleLabel.config }
        set { self.titleLabel.config = newValue }
    }
    
    var descriptionLabelConfig: BaseLabel.Config? {
        get { self.subtitleLabel.config }
        set { self.subtitleLabel.config = newValue }
    }
    
    var descriptionText: String? {
        didSet {
            self.subtitleLabel.config?.title = self.descriptionText?.localized
            self.accessibilityValue = self.descriptionText?.accessibility
        }
    }
    
    // MARK: - gui variables
    
    private lazy var titleLabel: BaseLabel = .init(config: .init(title: nil,
                                                                 font: .merriweather(size: 20)))
    
    private lazy var subtitleLabel: BaseLabel = .init(config: .init(title: nil,
                                                                    textColor: UIColor(named: "textSecondaryColor")))
    
    // MARK: - init
    
    init(title: String? = nil, description: String? = nil) {
        super.init(frame: .zero)
        self.initView()
        defer {
            self.title = title
            self.descriptionText = description
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.axis = .vertical
        self.spacing = 2
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addArrangedSubview(self.titleLabel)
        self.addArrangedSubview(self.subtitleLabel)
        self.setUpVoiceOver()
    }
    
    // MARK: - setters
    
    func setAttributedTitle(attributedText: NSMutableAttributedString) {
        self.titleLabel.setAttributedText(attributedText: attributedText)
    }
    
    func setAttributedDescription(attributedText: NSMutableAttributedString, accessibilityLabel: String) {
        self.subtitleLabel.setAttributedText(attributedText: attributedText)
    }
    
    private func setUpVoiceOver() {
        self.titleLabel.isAccessibilityElement = false
        self.subtitleLabel.isAccessibilityElement = false
        
        self.isAccessibilityElement = true
    }
}
