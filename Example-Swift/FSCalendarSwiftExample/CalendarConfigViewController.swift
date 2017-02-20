//
//  CalendarConfigViewController.swift
//  FSCalendarSwiftExample
//
//  Created by Wenchao Ding on 28/01/2017.
//  Copyright © 2017 wenchao. All rights reserved.
//

import UIKit

class CalendarConfigViewController: UITableViewController {

    var theme: Int = 0
    var lunar: Bool = false
    var firstWeekday: UInt = 1
    var scrollDirection: FSCalendarScrollDirection = .horizontal
    var selectedDate: Date?
    
    @IBOutlet
    weak var datePicker: UIDatePicker!
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        switch indexPath.section {
        case 0:
            cell.accessoryType = self.theme == indexPath.row ? .checkmark : .none;
        case 1:
            cell.accessoryType = self.lunar ? .checkmark : .none;
        case 2:
            cell.accessoryType = indexPath.row == 1 - Int(self.scrollDirection.rawValue) ? .checkmark : .none;
        case 4:
            cell.accessoryType = indexPath.row == Int(self.firstWeekday-1) ? .checkmark : .none;
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            self.theme = indexPath.row
        case 1:
            self.lunar = !self.lunar
        case 2:
            self.scrollDirection = FSCalendarScrollDirection(rawValue: UInt(1-indexPath.row))!
        case 3:
            self.selectedDate = self.datePicker.date;
        case 4:
            self.firstWeekday = UInt(indexPath.row + 1)
        default:
            break
        }
        tableView.reloadSections([indexPath.section] as IndexSet, with: .none)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
            self.performSegue(withIdentifier: "unwind2InterfaceBuilder", sender: self)
        }
        
    }

}
