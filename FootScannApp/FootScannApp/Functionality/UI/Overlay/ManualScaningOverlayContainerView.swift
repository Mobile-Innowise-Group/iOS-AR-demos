import UIKit

class ManualScaningOverlayContainerView: UIView {
    
    // MARK: - variables

    private let contentViewInsets: UIEdgeInsets = .init(top: 8, left: 38, bottom: 8, right: 38)
    private let viewCornerRadius: CGFloat = 24
    
    // MARK: - gui variables
    
    private(set) lazy var contentView: UIView = .init()
    
    // MARK: - initialisation
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.initView()
    }
    
    func initView() {
        self.backgroundColor = .white
        self.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: self.viewCornerRadius)
        self.addSubview(self.contentView)

        self.setNeedsUpdateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - constraints
    
    override func updateConstraints() {
        super.updateConstraints()
        self.contentView.snp.updateConstraints { make in
            make.edges.equalToSuperview().inset(self.contentViewInsets)
        }
    }
}
