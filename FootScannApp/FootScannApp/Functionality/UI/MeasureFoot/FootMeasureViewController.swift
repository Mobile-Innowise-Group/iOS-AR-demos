import UIKit
import SnapKit

final class FootMeasureViewController: UIViewController {
    
    enum MeasureType {
        case length
        case width
        
        func getRawValue() -> String {
            switch self {
            case .width:
                return "measureScreen-footWidth-title"
            case .length:
                return "measureScreen-footLength-title"
            }
        }
        
        func getTitle(for foot: FootSideType) -> String {
            switch self {
            case .width:
                return foot == .right
                ? "measureScreen-footWidth-right-description"
                : "measureScreen-footWidth-left-description"
            case .length:
                return foot == .right
                ? "measureScreen-footLength-right-description"
                : "measureScreen-footLength-left-description"
            }
        }
        
        func getPlaceholderText() -> String {
            switch self {
            case .width:
                return "measureScreen-footWidthPlaceholder-text"
            case .length:
                return "measureScreen-footLengthPlaceholder-text"
            }
        }
        
        func getImageName() -> String {
            switch self {
            case .width:
                return "footWidthImage"
            case .length:
                return "footLengthImage"
            }
        }
    }
    
    // MARK: - variables
    
    var continueButtonAction: (Double) -> Void
    var inAppRulerAction: () -> Void
    
    private let footSideType: FootSideType
    private let measureType: MeasureType
    private let topViewInsets = UIEdgeInsets(top: 60, left: 38, bottom: -12, right: 38)
    private let buttonEdgeInsets = UIEdgeInsets(top: 27, left: 38, bottom: 8, right: 38)
    private let inputEdgeInsets = UIEdgeInsets(top: 15, left: 38, bottom: 0, right: 38)
    private let footMeasuringImageEdgeInsets = UIEdgeInsets(top: 16, left: 38, bottom: 50, right: 38)
    private let backButtonInsets = UIEdgeInsets(top: 2, left: 28, bottom: 0, right: 28)
    private let unitsOfMesure: String = "cm"
    
    // MARK: - GUI variables

    private lazy var titleDescriptionView: TitleDescriptionView = .init(
        title: self.measureType.getTitle(for: self.footSideType),
        description: "measureScreen-description")
    
    private lazy var sizeInputView: InputView = {
        let view: InputView = .init(type: .measure)
        view.additionalTextPlaceholder = self.unitsOfMesure
        view.placeholderText = self.measureType.getPlaceholderText()
        view.textChangeAction = { [weak self, weak view] _ in
            self?.continueButton.isEnabled = view?.textDoubleValue != nil
        }
        return view
    }()
    
    private lazy var footMeasuringImage: ImageView = {
        let view: ImageView = .init(imageName: self.measureType.getImageName())
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        if self.footSideType == .left {
            view.image = view.image?.withHorizontallyFlippedOrientation()
        }
        return view
    }()
    
    private lazy var continueButton: BaseButton = {
        let button: BaseButton = .init(config: .init(title: "continue",
                                                     action: { [weak self] in self?.handleContinueButtonAction() }))
        button.isEnabled = false
        return button
    }()
    
    private lazy var inAppRulerButton: BaseButton = {
        let view: BaseButton = .init(config: .init(
            title: "measureScreen-inAppRulerButton-title",
            buttonStyle: .secondary,
            action: { [weak self] in self?.inAppRulerAction() }))
        return view
    }()
    
    // MARK: - initialization
    
    init(measureType: MeasureType = .length,
         footSideType: FootSideType = .right,
         continueButtonAction: @escaping (Double) -> Void,
         inAppRulerAction: @escaping () -> Void) {
        self.measureType = measureType
        self.footSideType = footSideType
        self.continueButtonAction = continueButtonAction
        self.inAppRulerAction = inAppRulerAction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configView()
        self.addConstraints()
    }
    
    // MARK: - configuration
    
    private func configView() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.titleDescriptionView)
        self.view.addSubview(self.sizeInputView)
        self.view.addSubview(self.continueButton)
        self.view.addSubview(self.inAppRulerButton)
        self.view.addSubview(self.footMeasuringImage)
    }
    
    // MARK: - constraints
    
    private func addConstraints() {
        self.titleDescriptionView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(self.topViewInsets)
        }
        
        self.sizeInputView.snp.makeConstraints { make in
            make.top.equalTo(self.titleDescriptionView.snp.bottom).offset(self.inputEdgeInsets.top)
            make.left.right.equalToSuperview().inset(self.inputEdgeInsets)
        }
        
        self.continueButton.snp.makeConstraints { make in
            make.top.equalTo(self.sizeInputView.snp.bottom).offset(self.buttonEdgeInsets.top)
            make.left.right.equalToSuperview().inset(self.buttonEdgeInsets)
            make.centerX.equalToSuperview()
        }
        
        if !self.inAppRulerButton.isHidden {
            self.inAppRulerButton.snp.makeConstraints { make in
                make.top.equalTo(self.continueButton.snp.bottom).offset(self.buttonEdgeInsets.bottom)
                make.left.right.equalToSuperview().inset(self.buttonEdgeInsets)
                make.centerX.equalToSuperview()
            }
        }
        
        self.footMeasuringImage.snp.makeConstraints { make in
            if self.inAppRulerButton.isHidden {
                make.top.equalTo(self.continueButton.snp.bottom).offset(self.footMeasuringImageEdgeInsets.top)
            } else {
                make.top.equalTo(self.inAppRulerButton.snp.bottom).offset(self.footMeasuringImageEdgeInsets.top)
            }
            
            make.left.greaterThanOrEqualToSuperview().inset(self.footMeasuringImageEdgeInsets)
            make.right.lessThanOrEqualToSuperview().inset(self.footMeasuringImageEdgeInsets)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().offset(-self.footMeasuringImageEdgeInsets.bottom)
        }
    }
    
    // MARK: - action
    
    private func handleContinueButtonAction() {
        guard let measureValue = self.sizeInputView.textDoubleValue else { return }
        self.continueButtonAction(measureValue)
    }
    
    // MARK: - setters
    
    func setMeasureValue(_ value: Double) {
        self.sizeInputView.setFirstResponder()
        self.sizeInputView.text = "\(value)"
        self.continueButton.isEnabled = true
    }
}
