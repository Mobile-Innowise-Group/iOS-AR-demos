import UIKit
import SnapKit

class SwitchView: UIView {
    
    // MARK: - variables
    private let switchmarkInsets: UIEdgeInsets = .init(top: 1.5, left: 1.5, bottom: 1.5, right: 1.5)
    private let disabledStateAlpha: Float = 0.5
    private let enabledStateAlpha: Float = 1

    private var switchmarkSize: CGSize {
        let sideSize = self.switchSize.height - (self.switchmarkInsets.left + self.switchmarkInsets.right)
        return CGSize(width: sideSize, height: sideSize)
    }
    
    private var leftConstraint: Constraint?

    private var leftOffset: CGFloat {
        get {
            self.isOn
            ? self.switchSize.width - self.switchmarkSize.width - self.switchmarkInsets.right
            : self.switchmarkInsets.left
        }
    }

    let switchSize = CGSize(width: 58, height: 38)

    // MARK: - properties

    var isOn: Bool = false {
        didSet { self.animateSwitch() }
    }

    var isEnabled: Bool = true {
        didSet { self.updateAlpha() }
    }

    var selectedColor: UIColor? = .init(named: "mainAcceptColor") {
        didSet { self.updateColor() }
    }
    
    var unSelectedColor: UIColor? = .red {
        didSet { self.updateColor() }
    }
    
    var borderWidth: CGFloat = 0.5
    var animationDuration: TimeInterval = 0.2

    // MARK: - gui


    private lazy var switchmarkView: UIView = {
        let view: UIView = .init(frame: .zero)
        view.backgroundColor = .white
        view.layer.cornerRadius = self.switchmarkSize.height / 2
        return view
    }()
    
    private lazy var colorView: UIView = {
        let view: UIView = .init(frame: .zero)
        view.layer.cornerRadius = self.switchSize.height / 2 - self.borderWidth * 2
        view.layer.borderWidth = self.borderWidth
        return view
    }()

    // MARK: - init
    
    init() {
        super.init(frame: .zero)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = self.switchSize.height / 2
        self.addSubviews([self.colorView,
                          self.switchmarkView])
        self.setNeedsUpdateConstraints()
        self.animateSwitch()
    }

    // MARK: - constraints
    
    override func updateConstraints() {
        super.updateConstraints()
        self.colorView.snp.updateConstraints { (make) in
            make.top.left.equalToSuperview().inset(self.borderWidth)
            make.size.equalTo(self.switchSize)
        }
        
        self.switchmarkView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().inset(self.switchmarkInsets)
            self.leftConstraint = make.left.equalToSuperview().inset(self.switchmarkInsets).constraint
            make.size.equalTo(self.switchmarkSize)
        }
    }

    // MARK: - animations

    private func animateSwitch() {
        self.leftConstraint?.update(offset: self.leftOffset)
        UIView.animate(withDuration: self.animationDuration,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { self.layoutIfNeeded() })
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateColor()
    }

    // MARK: - Gradient

    private func updateColor() {
        self.colorView.backgroundColor = self.isOn ? self.selectedColor : self.unSelectedColor
    }

    func updateAlpha() {
        self.layer.opacity = self.isEnabled ? self.enabledStateAlpha : self.disabledStateAlpha
    }
}
