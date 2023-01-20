//
//  MasterController.swift
//  ARDemo
//
//  Created by Uladzislau Volchyk on 31/10/2022.
//

import UIKit

final class MasterController: UITableViewController {

    private enum Constants {
        static let reuseIdentifier = "id"
    }

    private var contents: Array<(title: String, builder: () -> UIViewController)> = {
        if #available(iOS 16, *) {
            return [
                ("Foot scan", { RouteHelper.sh.buildSetup(startVC: SplashScreenViewController.init()) } ),
                ("Object identifier", ViewController.init),
                ("Hand scan", HandScanViewController.init),
                ("Object recognition with bounding boxes", {
                    ObjectRecognitionViewController(objectDectectionModel: (try! yolov5s(configuration: .init())).model) }),
                ("Create 3D Room Plan", {
                    UIStoryboard(name: "RoomPlanMain", bundle: .main).instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
                })
            ]
        } else {
            return [
                ("Foot scan", { RouteHelper.sh.buildSetup(startVC: SplashScreenViewController.init()) } ),
                ("Object identifier", ViewController.init),
                ("Hand scan", HandScanViewController.init),
                ("Object recognition with bounding boxes", {
                    ObjectRecognitionViewController(objectDectectionModel: (try! yolov5s(configuration: .init())).model) })
            ]
        }
    }()

    override func viewDidLoad() {
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.reuseIdentifier)
    }

    override func numberOfSections(
        in tableView: UITableView
    ) -> Int { 1 }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int { contents.count }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseIdentifier)!
        cell.textLabel?.text = contents[indexPath.row].title
        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        if let vc = contents[indexPath.row].builder() as? OnboardingViewController {
            vc.definesPresentationContext = true
            vc.modalPresentationStyle = .overFullScreen
            showDetailViewController(
                vc,
                sender: nil
            )
        } else {
            showDetailViewController(
                contents[indexPath.row].builder(),
                sender: nil
            )
        }
    }
}
