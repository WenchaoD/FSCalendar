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
        /*
        calendar.allowsMultipleSelection = true
        let date1 = NSDate().fs_dateByAddingDays(1)
        let date2 = NSDate().fs_dateByAddingDays(2)
        let date3 = NSDate().fs_dateByAddingDays(3)
        calendar.selectDate(date1)
        calendar.selectDate(date2)
        calendar.selectDate(date3)
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
    }
    
    func calendar(calendar: FSCalendar!, imageForDate date: NSDate!) -> UIImage! {
        return (date.fs_day == 13 || date.fs_day == 24) ? UIImage(named: "icon_cat") : nil
    }
    
}

