import UIKit

/// Main app router for pushing, presenting, poping, dismissing
final class RouteHelper: NSObject {
    
    // MARK: - variables
    
    static let sh = RouteHelper()
    
    private weak var window: UIWindow?
    private var additionalWindow: UIWindow?
    private(set) var navController: UINavigationController?
    
    //MARK: - init
    
    private override init() {}
    
    // MARK: - setup

    func buildSetup(startVC: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController()
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        navigationController.navigationBar.isHidden = true
        self.navController = navigationController

        navigationController.viewControllers = [startVC]
        return navigationController
    }
    
    // MARK: - ActionMethods
    
    func pushVC(_ viewController: UIViewController, animated: Bool = false) {
        self.navController?.pushViewController(viewController, animated: animated)
    }
    
    func popVC() {
        self.navController?.popViewController(animated: false)
    }
    
    func popTo<T: UIViewController>(controllerType: T.Type, orPush vc: UIViewController) {
        let destinationVC = self.navController?.viewControllers
            .filter { $0 is T }
            .first
        
        if let destinationVC = destinationVC {
            self.popToVC(destinationVC)
        } else {
            self.pushVC(vc)
        }
    }
    
    func popToVC(_ vc: UIViewController, animated: Bool = true) {
        guard self.navController?.viewControllers.contains(vc) == true else {
            self.navController?.popToRootViewController(animated: animated)
            return
        }
        self.navController?.popToViewController(vc, animated: animated)
    }
    
    func presentVC(_ vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.navController?.present(vc, animated: animated, completion: completion)
    }
    
    func popToRoot(animated: Bool = true) {
        self.navController?.popToRootViewController(animated: animated)
    }
    
    func setVC(_ viewController: UIViewController, animated: Bool = false) {
        guard var currentViewControllers = self.navController?.viewControllers else { return }
        currentViewControllers.removeLast()
        currentViewControllers.append(viewController)
        self.navController?.setViewControllers(currentViewControllers, animated: animated)
    }
    
    /// used for presenting loader view controller
    func presentOnWindowVC(_ vc: UIViewController,
                           animated: Bool = false,
                           completionHanlder: (() -> Void)? = nil) {
        let safeAreaInsets = self.window?.safeAreaInsets ?? .zero
        let window = UIWindow(frame: CGRect(origin: UIScreen.main.bounds.origin,
                                            size: CGSize(width: AppConstants.screenSize.width + safeAreaInsets.left + safeAreaInsets.right,
                                                         height: AppConstants.screenSize.height + safeAreaInsets.bottom)))
        window.windowLevel = .alert
        window.rootViewController = UIViewController()
        
        self.additionalWindow = window
        window.makeKeyAndVisible()
        window.rootViewController?.present(vc, animated: animated, completion: { completionHanlder?() })
    }
    
    func dismissVC(animated: Bool = false, completion: (() -> Void)? = nil) {
        if let lastWindow = self.additionalWindow {
            lastWindow.rootViewController?.dismiss(animated: animated, completion: completion)
            self.additionalWindow = nil
        } else {
            self.navController?.dismiss(animated: animated, completion: { completion?() })
        }
    }

    func deInit() {
        navController = nil
    }
}
