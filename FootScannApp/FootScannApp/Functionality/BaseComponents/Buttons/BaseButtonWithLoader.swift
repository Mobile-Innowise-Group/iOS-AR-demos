import UIKit

protocol BaseButtonWithLoaderDelegate: AnyObject {
    func buttonsLoaderStarted(_ button: BaseButtonWithLoader)
    func buttonsLoaderStopped(_ button: BaseButtonWithLoader)
}

extension BaseButtonWithLoaderDelegate {
    func buttonsLoaderStarted(_ button: BaseButtonWithLoader) {}
    func buttonsLoaderStopped(_ button: BaseButtonWithLoader) {}
}

final class BaseButtonWithLoader: BaseButton {
    
    // MARK: - Variables
    
    weak var delegate: BaseButtonWithLoaderDelegate?
    
    private let loaderViewSize = CGSize(width: 20, height: 20)
    private let loaderViewCenterOffset: CGFloat = 16
    private let leftLoaderOffset: CGFloat = 15
    
    // MARK: - GUI variables
    
    private lazy var loaderView: CustomLoader = .init(config: .init(color: UIColor.white,
                                                                    backgroundCircleColor: UIColor(named: "loaderBackground") ?? UIColor.white))
    
    // MARK: - Initialization
    
    required init(config: ButtonConfig) {
        super.init(config: config)
        self.addSubview(self.loaderView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.makeConstraints()
    }
    
    // MARK: - Actions
    
    func startLoading() {
        self.loaderView.startAnimating()
        self.setTitleColor(UIColor(named: "loaderBackground"), for: .normal)
        self.delegate?.buttonsLoaderStarted(self)
    }
    
    func stopLoading() {
        self.loaderView.stopAnimation()
        self.setTitleColor(.white, for: .normal)
        self.delegate?.buttonsLoaderStopped(self)
    }
    
    private func makeConstraints() {
        guard let titleLabel = self.titleLabel else { return }
        titleLabel.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
        
        self.loaderView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(self.leftLoaderOffset)
            make.right.equalTo(titleLabel.snp.left).offset(-self.loaderViewCenterOffset)
            make.size.equalTo(self.loaderViewSize)
        }
    }
}

