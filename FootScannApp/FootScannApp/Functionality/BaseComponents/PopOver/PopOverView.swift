import UIKit

final class PopOverView: UIView {
    
    // MARK: - variables
    
    var completion: (() -> Void)? = nil
    var closeButtonAction: (() -> Void)? = nil
    
    var cornerRadius: CGFloat = 32 {
        didSet { self.setCornerRadius(self.cornerRadius) }
    }
    
    var closeButtonIsHidden: Bool = true {
        didSet { self.closeButton.isHidden = closeButtonIsHidden }
    }
    var backgroundViewIsHidden: Bool = true {
        didSet { self.backgroundView.isHidden = backgroundViewIsHidden }
    }
    var dismissByTap = false
    
    /**
     Automatically dismiss in time or not. Duration of dismiss can be changed by property `duration`.
     */
    var dismissInTime = false
    
    /**
     Duration for showing alert. If `dismissInTime` disabled, this property ignoring.
     */
    var duration: TimeInterval = 1.2
    
    var presentDismissDuration: TimeInterval = 1
    private var presentDismissScale: CGFloat = 0.8
    
    private weak var presentWindow: UIWindow?
    private let contentViewInsets = UIEdgeInsets(top: 27, left: 24, bottom: 47, right: 24)
    private let popOverViewInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
    private let doctorImageSize = CGSize(width: 60, height: 60)
    private let closeButtonSize = CGSize(width: 30, height: 30)
    private let closeButtonInset = 15
    
    // MARK: - gui
    
    private lazy var content = UIView()
    
    private lazy var doctorImageView = ImageView(imageName: "doctor")
    
    private lazy var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(named: "popOverBackgroundColor")
        backgroundView.alpha = 0
        backgroundView.isHidden = backgroundViewIsHidden
        return backgroundView
    }()
    
    private lazy var closeButton: CloseButton = {
        let closeBtn = CloseButton()
        closeBtn.action = { [weak self] in
            self?.dismiss()
        }
        closeBtn.isHidden = closeButtonIsHidden
        return closeBtn
    }()
    
    
    // MARK: - Init
    
    init(contentView: UIView) {
        super.init(frame: CGRect.zero)
        self.content = contentView
        self.initView()
        self.setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initView()
    }
    
    private func initView() {
        self.addSubviews([self.content,
                          self.doctorImageView,
                          self.closeButton])
    }
    
    
    // MARK: - constraints
    
    override func updateConstraints() {
        super.updateConstraints()
        self.doctorImageView.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(-(self.doctorImageSize.height / 2))
            make.centerX.equalToSuperview()
            make.size.equalTo(doctorImageSize)
        }
        self.content.snp.updateConstraints { make in
            make.top.equalTo(self.doctorImageView.snp.bottom).offset(contentViewInsets.top)
            make.leading.trailing.bottom.equalTo(self).inset(contentViewInsets)
        }
        self.closeButton.snp.updateConstraints { make in
            make.size.equalTo(closeButtonSize)
            make.top.trailing.equalToSuperview().inset(closeButtonInset)
        }
    }
    
    private func addViewsToWindowIfNeeded() {
        guard let window = self.presentWindow else { return }
        window.addSubview(backgroundView)
        window.addSubview(self)
        
        self.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(popOverViewInsets)
        }
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.doctorImageView.layer.cornerRadius = doctorImageView.frame.height / 2
    }
    
    // MARK: - Configure
    
    private func setCornerRadius(_ value: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = value
    }
    
    private func setUI() {
        self.backgroundColor = .white
        self.setCornerRadius(self.cornerRadius)
        self.layer.masksToBounds = false
        
        // Configure UI for doctorImageView
        doctorImageView.layer.cornerCurve = .continuous
        doctorImageView.layer.borderWidth = 3
        doctorImageView.layer.borderColor = UIColor.white.cgColor
    }
    
    // MARK: - Present
    
    func present(completion: (() -> Void)? = nil) {
        if self.presentWindow == nil {
            self.presentWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        }
        
        self.addViewsToWindowIfNeeded()
        
        // Prepare for present
        self.completion = completion
        self.alpha = 0
        self.transform = self.transform.scaledBy(x: self.presentDismissScale,
                                                 y: self.presentDismissScale)
        
        if self.dismissByTap {
            let tapGesterRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(self.dismiss))
            self.addGestureRecognizer(tapGesterRecognizer)
        }
        
        // Present
        UIView.animate(withDuration: self.presentDismissDuration,
                       animations: { [weak self] in
            self?.backgroundView.alpha = 1
            self?.alpha = 1
            self?.transform = CGAffineTransform.identity
        }, completion: { [weak self] finished in
            guard let self = self else { return }
            if self.dismissInTime {
                DispatchQueue.main.asyncAfter(deadline: .now() + self.duration) { self.dismiss() }
            }
        })
    }
    
    @objc func dismiss() {
        guard self.alpha == 1 else { return }
        UIView.animate(withDuration: self.presentDismissDuration,
                       animations: { [weak self] in
            guard let self = self else { return }
            self.backgroundView.alpha = 0
            self.alpha = 0
            self.transform = self.transform.scaledBy(x: self.presentDismissScale,
                                                     y: self.presentDismissScale)
        }, completion: { [weak self] finished in
            self?.removeFromSuperview()
            self?.completion?()
        })
    }
}
