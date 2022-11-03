
import UIKit

final class LoaderViewController: UIViewController {
    
    // MARK: - Variables
    private let loadingIndicatorSize = CGSize(width: 60, height: 60)
    
    // MARK: - GUI variables
    
    private lazy var loadingIndicator = TrailFadingLoader(config: .init(fromColor: UIColor.white,
                                                                        toColor: UIColor.clear))
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.view.backgroundColor = .clear
        self.view.addSubview(self.loadingIndicator)
        self.loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(self.loadingIndicatorSize)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIAccessibility.post(notification: .announcement, argument: "wait-title".accessibility)
        self.loadingIndicator.startAnimating()
    }
}
