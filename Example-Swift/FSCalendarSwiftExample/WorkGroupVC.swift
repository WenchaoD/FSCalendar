//
//  WorkGroupVC.swift
//  FSCalendarSwiftExample
//
//  Created by Trinh Huu Tien on 5/6/22.
//  Copyright © 2022 wenchao. All rights reserved.
//

import UIKit



class WorkGroupVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnApply: UIButton!
    weak var vc: UIViewController?
    var workGroups: [WorkGroupModel]!
    var workTypeId: String!
    var workGroupId: String = ""
    
    var delegate: CalendarShiftDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnApply.isEnabled = false
        if ManagerWorkType.shared.workTypeId == self.workTypeId {
            self.workGroupId = ManagerWorkType.shared.workGroupId
        }
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.btnApply.layer.cornerRadius = self.btnApply.frame.height / 2
        self.btnApply.layer.masksToBounds = true
        
    }
    
    @IBAction func applyClick(_ button: UIButton){
        if(self.workTypeId != ManagerWorkType.shared.workGroupId) {
            ManagerWorkType.saveConfigCalendarShift(worpTypeId: self.workTypeId, workGroupId: self.workGroupId)
            ManagerWorkType.setupConfigCalendarShift()
            self.delegate?.reloadCalendar()
        }
        if let _vc = self.vc {
            self.navigationController?.popToViewController(_vc, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
        
    }
    
    func isSelecteWorkType(workGroupId: String) -> Bool{
        return self.workGroupId == workGroupId
    }
    

}

extension WorkGroupVC: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.workGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.workGroups[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = model.name
        cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        cell.accessoryType = self.isSelecteWorkType(workGroupId: model.id) ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
}

extension WorkGroupVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.workGroupId = self.workGroups[indexPath.row].id
        self.btnApply.isEnabled = !(self.workGroupId == ManagerWorkType.shared.workGroupId && self.workTypeId == ManagerWorkType.shared.workTypeId)
//        var indexPaths = [indexPath]
//        if let _indexPathDeselect = self.tableView.indexPat {
//            indexPaths.append(_indexPathDeselect)
//        }
        self.tableView.reloadData()
    }
    
    
}
