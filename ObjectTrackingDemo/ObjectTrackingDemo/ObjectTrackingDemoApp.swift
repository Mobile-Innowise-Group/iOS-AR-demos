////
////  ObjectTrackingDemoApp.swift
////  ObjectTrackingDemo
////
////  Created by Uladzislau Volchyk on 27/10/2022.
////

import SwiftUI

@main
struct ObjectTrackingDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainScreen()//ContentView()
            }
        }
    }
}


//import UIKit
//import ARKit
//import INObjectTracking
//
//@main
//class AppDelegate: UIResponder, UIApplicationDelegate {
//
//    var window: UIWindow?
//
//    func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
//    ) -> Bool {
////        guard ARObjectScanningConfiguration.isSupported, ARWorldTrackingConfiguration.isSupported else {
////            fatalError("""
////                ARKit is not available on this device. For apps that require ARKit
////                for core functionality, use the `arkit` key in the key in the
////                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
////                the app from installing. (If the app can't be installed, this error
////                can't be triggered in a production scenario.)
////                In apps where AR is an additive feature, use `isSupported` to
////                determine whether to show UI for launching AR experiences.
////            """) // For details, see https://developer.apple.com/documentation/arkit
////        }
//        let controller = ViewController()
//        let window = UIWindow(frame: UIScreen.main.bounds)
//        window.rootViewController = controller
//        self.window = window
//        window.makeKeyAndVisible()
//
//        return true
//    }
//
//    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        if let viewController = self.window?.rootViewController as? ViewController {
////            viewController.readFile(url)
//            return true
//        } else {
//            return false
//        }
//    }
//
//    func applicationWillEnterForeground(_ application: UIApplication) {
////        if let viewController = self.window?.rootViewController as? ObjectTrackingViewController {
////            viewController.backFromBackground()
////        }
//    }
//
//    func applicationWillResignActive(_ application: UIApplication) {
////        if let viewController = self.window?.rootViewController as? ObjectTrackingViewController {
////            viewController.blurView?.isHidden = false
////        }
//    }
//
//    func applicationDidBecomeActive(_ application: UIApplication) {
////        if let viewController = self.window?.rootViewController as? ObjectTrackingViewController {
////            viewController.blurView?.isHidden = true
////        }
//    }
//}
