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

    func setup(window: UIWindow) {
        UIApplication.shared.isIdleTimerDisabled = true
        self.window = window
        let navigationController = UINavigationController()
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        navigationController.navigationBar.isHidden = true
        navController = navigationController
        let splashVC = HandScanViewController()

        navigationController.viewControllers = [splashVC]
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }

    // MARK: - ActionMethods

    func pushVC(_ viewController: UIViewController, animated: Bool = false) {
        navController?.pushViewController(viewController, animated: animated)
    }

    func popVC() {
        navController?.popViewController(animated: false)
    }

    func popTo<T: UIViewController>(controllerType: T.Type, orPush vc: UIViewController) {
        let destinationVC = navController?.viewControllers
            .filter { $0 is T }
            .first

        if let destinationVC = destinationVC {
            popToVC(destinationVC)
        } else {
            pushVC(vc)
        }
    }

    func popToVC(_ vc: UIViewController, animated: Bool = true) {
        guard navController?.viewControllers.contains(vc) == true else {
            navController?.popToRootViewController(animated: animated)
            return
        }
        navController?.popToViewController(vc, animated: animated)
    }

    func presentVC(_ vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        navController?.present(vc, animated: animated, completion: completion)
    }

    func popToRoot(animated: Bool = true) {
        navController?.popToRootViewController(animated: animated)
    }

    func setVC(_ viewController: UIViewController, animated: Bool = false) {
        guard var currentViewControllers = navController?.viewControllers else { return }
        currentViewControllers.removeLast()
        currentViewControllers.append(viewController)
        navController?.setViewControllers(currentViewControllers, animated: animated)
    }

    func dismissVC(animated: Bool = false, completion: (() -> Void)? = nil) {
        if let lastWindow = additionalWindow {
            lastWindow.rootViewController?.dismiss(animated: animated, completion: completion)
            additionalWindow = nil
        } else {
            navController?.dismiss(animated: animated, completion: { completion?() })
        }
    }
}
