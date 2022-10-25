import UIKit

final class InfoSwitchView: UIView {
    // MARK: - variables
    
    var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 15, left: 16, bottom: 15, right: 17) {
        didSet { self.setNeedsUpdateConstraints() }
    }
    
    var isOn: Bool {
        get { return self.switchButton.isOn }
        set { self.switchButton.isOn = newValue }
    }
    
    public var action: ((Bool) -> Void)?
    
    //MARK:- gui variable
    
    private lazy var titleLabel = BaseLabel(config: .init())
    
    private lazy var switchButton: UISwitch = {
        let switchButton = UISwitch()
        switchButton.onTintColor = UIColor(named: "mainAcceptColor") ?? UIColor.green
        switchButton.addTarget(self, action: #selector(self.fireToggle), for: .valueChanged)
        return switchButton
    }()
    
    //MARK:- initialization
    
    init() {
        super.init(frame: .zero)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.switchButton)
        self.setNeedsUpdateConstraints()
    }
    
    //MARK:- constraints
    
    override func updateConstraints() {
        super.updateConstraints()
        
        self.titleLabel.snp.updateConstraints { (make) in
            make.top.left.bottom.equalToSuperview().inset(self.contentInsets)
        }
        
        self.switchButton.snp.updateConstraints { (make) in
            make.right.equalToSuperview().inset(self.contentInsets)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    func set(title: String, isOn: Bool) {
        self.titleLabel.config?.title = title
        self.switchButton.isOn = isOn
        self.setNeedsUpdateConstraints()
    }
    
    @objc private func fireToggle() {
        self.action?(self.isOn)
    }
}

