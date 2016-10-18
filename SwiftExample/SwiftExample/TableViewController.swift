//
//  TableViewController.swift
//  SwiftExample
//
//  Created by dingwenchao on 10/17/16.
//  Copyright © 2016 wenchao. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        super.tableView(tableView, didSelectRowAt: indexPath)
        if indexPath.row == 1 {
            let viewController = LoadViewExampleViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    

}
