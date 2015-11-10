//
//  ViewController.swift
//  SwiftExample
//
//  Created by Wenchao Ding on 9/3/15.
//  Copyright (c) 2015 wenchao. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.scrollDirection = .Vertical
        calendar.appearance.caseOptions = [.HeaderUsesUpperCase,.WeekdayUsesUpperCase]
        calendar.selectDate(NSDate())
//        calendar.allowsMultipleSelection = true
        
        // Uncomment this to test month->week and week->month transition
        /*
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.calendar.setScope(.Week, animated: true)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                self.calendar.setScope(.Month, animated: true)
            }
        }
        */

    }
    
    /*
    func minimumDateForCalendar(calendar: FSCalendar!) -> NSDate! {
        return NSDate().fs_firstDayOfMonth
    }
    
    func maximumDateForCalendar(calendar: FSCalendar!) -> NSDate! {
        return NSDate().fs_dateByAddingMonths(3).fs_lastDayOfMonth
    }
    */

    func calendar(calendar: FSCalendar!, hasEventForDate date: NSDate!) -> Bool {
        return date.fs_day == 5
    }

    func calendarCurrentPageDidChange(calendar: FSCalendar!) {
        NSLog("change page to \(calendar.currentPage.fs_string())")
    }
    
    func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
        NSLog("calendar did select date \(date.fs_string())")
    }
    
    func calendarCurrentScopeWillChange(calendar: FSCalendar!, animated: Bool) {
        calendarHeightConstraint.constant = calendar.sizeThatFits(CGSizeZero).height
        view.layoutIfNeeded()
    }
    
    func calendar(calendar: FSCalendar!, imageForDate date: NSDate!) -> UIImage! {
        return (date.fs_day == 13 || date.fs_day == 24) ? UIImage(named: "icon_cat") : nil
    }
    
}

