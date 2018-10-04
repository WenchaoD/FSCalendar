//
//  FSCalendarScopeViewController.swift
//  FSCalendarSwiftExample
//
//  Created by dingwenchao on 30/12/2016.
//  Copyright © 2016 wenchao. All rights reserved.
//

import UIKit

class FSCalendarScopeExampleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var animationSwitch: UISwitch!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    fileprivate var gregorian: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
    fileprivate var scope: FSCalendarScope = .month
    fileprivate var numberOfWeeks = 1
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
        
        self.calendar.select(Date())
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.calendar.placeholderType = .fillHeadTail
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0
        
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
        
    }
    
    deinit {
        print("\(#function)")
    }
    
    // MARK:- UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            }
        }
        return shouldBegin
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.dateFormatter.string(from: date))")
        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        print("selected dates is \(selectedDates)")
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        
        //Reload calendar header view
        calendar.calendarHeaderView.reloadData()
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    // MARK:- UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.scope == .month {
            return 2
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = ["cell_month", "cell_week", "cell_weeks_number"][indexPath.row]
        
        if indexPath.row == 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? FSWeeksSelectionCell else {
                return UITableViewCell()
            }
            
            cell.weeksLabel.text = "\(self.numberOfWeeks)"
            cell.delegate = self
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
        return cell
    }
    
    
    // MARK:- UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 && self.scope != .month {
                self.scope = .month
                self.calendar.setScope(self.scope, animated: self.animationSwitch.isOn)
                
                //
                tableView.beginUpdates()
                tableView.deleteRows(at: [IndexPath(row: 2, section: 0) ], with: .automatic)
                tableView.endUpdates()
                
            } else if indexPath.row == 1 && self.scope != .week {
                self.calendar.numberOfWeeks = self.numberOfWeeks
                self.scope = .week
                self.calendar.setScope(self.scope, animated: self.animationSwitch.isOn)
                
                //
                tableView.beginUpdates()
                tableView.insertRows(at: [IndexPath(row: 2, section: 0) ], with: .automatic)
                tableView.endUpdates()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    // MARK:- Target actions
    @IBAction func toggleClicked(sender: AnyObject) {
        if self.scope == .month {
            self.calendar.numberOfWeeks = self.numberOfWeeks
            self.scope = .week
            self.calendar.setScope(self.scope, animated: self.animationSwitch.isOn)
            
            //
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: 2, section: 0) ], with: .automatic)
            tableView.endUpdates()
        } else {
            self.scope = .month
            self.calendar.setScope(self.scope, animated: self.animationSwitch.isOn)
            
            //
            tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(row: 2, section: 0) ], with: .automatic)
            tableView.endUpdates()
        }
    }
}

extension FSCalendarScopeExampleViewController: FSWeeksSelectionCellDelegate {
    func increaseButtonPressed(cell: FSWeeksSelectionCell) {
        if self.numberOfWeeks < 4 {
            self.numberOfWeeks += 1
            cell.weeksLabel.text = "\(self.numberOfWeeks)"
            if self.numberOfWeeks == 1 {
                cell.decreaseButton.isEnabled = false
            } else {
                cell.decreaseButton.isEnabled = true
            }
            
            //
            self.calendar.numberOfWeeks = self.numberOfWeeks
        }
    }
    
    func decreaseButtonPressed(cell: FSWeeksSelectionCell) {
        if self.numberOfWeeks > 1 {
            self.numberOfWeeks -= 1
            cell.weeksLabel.text = "\(self.numberOfWeeks)"
            if self.numberOfWeeks == 1 {
                cell.decreaseButton.isEnabled = false
            } else {
                cell.decreaseButton.isEnabled = true
            }
            
            //
            self.calendar.numberOfWeeks = self.numberOfWeeks
            self.calendar.reloadData()
        }
    }
}
