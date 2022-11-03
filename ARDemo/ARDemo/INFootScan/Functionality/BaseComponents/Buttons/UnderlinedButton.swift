
import UIKit

final class UnderlinedButton: UIView {
    
    var elementsColor: UIColor? = UIColor(named: "underlinedTextColor") {
        didSet {
            self.label.config?.textColor = self.elementsColor
            self.line.backgroundColor = self.elementsColor
        }
    }
    private let buttonText: String
    private let buttonAction: (() -> Void)
    private let lineOffset = CGFloat(2)
    
    private(set) lazy var label: BaseLabel = {
        let label = BaseLabel(config: .init(
            title: self.buttonText,
            textColor: self.elementsColor))
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var line: LineView = {
        let line = LineView()
        line.backgroundColor = self.elementsColor
        return line
    }()
    
    init(text: String, action: @escaping (() -> Void)) {
        self.buttonText = text
        self.buttonAction = action
        super.init(frame: .zero)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        addSubview(line)
        addSubview(label)
        isUserInteractionEnabled = true
        addGestureRecognizer(TapGestureRecognizer(action: { [weak self] in
            self?.buttonAction()
        }))
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        label.snp.updateConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        line.snp.updateConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(lineOffset)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}
