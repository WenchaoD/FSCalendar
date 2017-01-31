//
//  TableViewController.swift
//  FSCalendarSwiftExample
//
//  Created by dingwenchao on 10/17/16.
//  Copyright © 2016 wenchao. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objects = [DIYExampleViewController.self, NSObject.self,DelegateAppearanceViewController.self, NSObject.self, LoadViewExampleViewController.self]
        if let ViewControllerClass = objects[indexPath.row] as? UIViewController.Type {
            self.navigationController?.pushViewController(ViewControllerClass.init(), animated: true)
        }
    }

}
