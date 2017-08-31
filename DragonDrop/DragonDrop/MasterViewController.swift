//
//  MasterViewController.swift
//  DragonDrop
//
//  Created by Rowan on 19/08/17.
//  Copyright © 2017 Rowan Livingstone. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    var dataSource: [(String, [DisplayItemConvertible])] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isSpringLoaded = true
        
        dataSource = [
            ("Simple collection", [
                SimpleModel(title: "Simple model 1", detail: "1", color: UIColor.purple.adjusted(withLightnessFactor: 1.8)!),
                SimpleModel(title: "Simple model 2", detail: "2", color: UIColor.cyan.adjusted(withLightnessFactor: 0.8)!),
                SimpleModel(title: "Simple model 3", detail: "3", color: .green)
                ]
            ),
            ("Image collection", [
                ImageModel(image: #imageLiteral(resourceName: "reddragon")),
                ImageModel(image: #imageLiteral(resourceName: "dragonite")),
                ImageModel(image: #imageLiteral(resourceName: "goofdragon"))
                ]
            ),
            ("Custom collection", [
                CustomModel(customString1: "Custom model 1", customString2: "Custom model 1 detail", customColor: UIColor.orange),
                CustomModel(customString1: "Custom model 2", customString2: "Custom model 2 detail", customColor: UIColor.orange),
                CustomModel(customString1: "Custom model 3", customString2: "Custom model 3 detail", customColor: UIColor.orange)
                ]
            )
        ]
        
        if let navigationController = splitViewController?.viewControllers[1] as? UINavigationController, let detailViewController = navigationController.topViewController as? DetailViewController, let detailDataSource = dataSource.first?.1 {
            detailViewController.delegate = self
            detailViewController.dataSource = detailDataSource
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController?.isCollapsed ?? true
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.delegate = self
                controller.dataSource = dataSource[indexPath.row].1
                
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true                
            }
        }
    }

    // MARK: - Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let collectionTitle = dataSource[indexPath.row].0
        cell.textLabel?.text = collectionTitle
        return cell
    }

}

extension MasterViewController: DetailViewControllerDelegate {
    
    func detailViewController(_: DetailViewController, didUpdate dataSource: [DisplayItemConvertible]) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        self.dataSource[selectedIndexPath.row].1 = dataSource
    }
    
}

