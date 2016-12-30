//
//  TableViewController.swift
//  SwiftExample
//
//  Created by dingwenchao on 10/17/16.
//  Copyright © 2016 wenchao. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objects = [DIYExampleViewController(), NSObject(),DelegateAppearanceViewController(),LoadViewExampleViewController()]
        if let viewController = objects[indexPath.row] as? UIViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
