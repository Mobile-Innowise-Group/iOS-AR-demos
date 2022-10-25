import UIKit

final class SplashScreenViewController: UIViewController {
    
    // MARK: - variables
    
    private let imageInsets: UIEdgeInsets = .init(top: 32, left: 100, bottom: 32, right: 100)
   
    // MARK: - GUI variables
    
    private lazy var appPresenter: AppPresenter = .init()
    private lazy var splashImage: ImageView = .init(imageName: "mainIcon")
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configView()
        self.addConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.appPresenter.startFlow()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - configuration
    
    private func configView() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.view.backgroundColor = .white
        self.view.addSubview(self.splashImage)
    }
    
    // MARK: - constraints
    
    private func addConstraints() {
        self.splashImage.snp.makeConstraints { make in
            make.top.left.greaterThanOrEqualToSuperview().inset(self.imageInsets)
            make.right.bottom.lessThanOrEqualToSuperview().inset(self.imageInsets)
            make.center.equalToSuperview()
        }
    }
}
