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
        calendar.selectDate(NSDate())
        calendar.scrollDirection = .Vertical
        calendar.scope = .Month
    }

    
    func calendar(calendar: FSCalendar!, hasEventForDate date: NSDate!) -> Bool {
        return date.fs_day == 5
    }


    func calendarCurrentPageDidChange(calendar: FSCalendar!) {
        println("change page to \(calendar.currentPage.fs_string())")
    }
    
    func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
        println("calendar did select date \(date.fs_string())")
    }
    
    func calendarCurrentScopeWillChange(calendar: FSCalendar!, animated: Bool) {
        calendarHeightConstraint.constant = calendar.sizeThatFits(CGSizeZero).height
    }
    
}

