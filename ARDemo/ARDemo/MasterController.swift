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

    private let contents: Array<(title: String, builder: () -> UIViewController)> = [
        ("Foot scan", RouteHelper.sh.buildSetup),
        ("Object identifier", ViewController.init)
    ]

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
        showDetailViewController(
            contents[indexPath.row].builder(),
            sender: nil
        )
    }
}
