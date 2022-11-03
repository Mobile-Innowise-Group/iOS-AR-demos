//
//  SceneDelegate.swift
//  ARDemo
//
//  Created by Uladzislau Volchyk on 31/10/2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        let masterController = MasterController()
        let masterNavigationController = masterController

        let splitViewController =  UISplitViewController()
        splitViewController.viewControllers = [masterNavigationController]
        splitViewController.delegate = self

        window?.rootViewController = splitViewController
        window?.makeKeyAndVisible()
        window?.makeKeyAndVisible()
    }
}

extension SceneDelegate: UISplitViewControllerDelegate {

    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController
    ) -> Bool {
        true
    }
}
