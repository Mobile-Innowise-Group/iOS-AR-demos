/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view controller for the app's first screen that explains what to do.
*/

import UIKit

class OnboardingViewController: UIViewController {
    @IBOutlet var existingScanView: UIView!

    @IBAction func startScan(_ sender: UIButton) {
        if let viewController = self.storyboard?.instantiateViewController(
            withIdentifier: "RoomCaptureViewNavigationController") {
            viewController.modalPresentationStyle = .overFullScreen
            present(viewController, animated: true)
        }
    }

    @IBAction func backToMainMenu() {
        dismiss(animated: true)
    }

}
