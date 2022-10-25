import UIKit
import SnapKit

final class OverlayController: UIViewController {
    
    // MARK: - variables
    
    var closeAction: (() -> Void)?
    
    // MARK: - gui variables
    
    private lazy var contentView: UIView = .init()
    
    // MARK: - initialization
    
    init(view: UIView) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.setContent(view: view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - view life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.view.addSubview(self.contentView)
        
        self.contentView.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, delay: 0.3, animations: {
                self.view.backgroundColor = .black.withAlphaComponent(0.5)
            })
        }
    }
    
    // MARK: - actions
    
    private func setContent(view: UIView) {
        self.contentView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func closeVC(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.1, animations: {
            self.view.backgroundColor = .clear
        }) { (_) in
            RouteHelper.sh.dismissVC(animated: true, completion: { [weak self] in
                completion?()
                self?.closeAction?()
            })
        }
    }
}

