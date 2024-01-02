//
//  WorkTypeVC.swift
//  FSCalendarSwiftExample
//
//  Created by Trinh Huu Tien on 5/6/22.
//  Copyright © 2022 wenchao. All rights reserved.
//

import UIKit

class WorkTypeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var delegate: CalendarShiftDelegate?
    weak var vc: UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        
        
    }

}

extension WorkTypeVC: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ManagerWorkType.shared.getAllWorkType().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = ManagerWorkType.shared.getAllWorkType()[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = model.name
        cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
}

extension WorkTypeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WorkGroupVC(nibName: "WorkGroupVC", bundle: nil)
        let model = ManagerWorkType.shared.getAllWorkType()[indexPath.row]
        vc.workGroups = model.groups
        vc.workTypeId = model.id
        vc.delegate = self.delegate
        vc.vc = self.vc
        
        vc.title = model.name
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
