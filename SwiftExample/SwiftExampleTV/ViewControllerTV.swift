//
//  ViewController.swift
//  SwiftExampleTV
//
//  Created by asdfgh1 on 01/02/16.
//  Copyright © 2016 wenchao. All rights reserved.
//

import UIKit

class ViewControllerTV: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func swipeLeft(sender: AnyObject) {
        calendar.setCurrentPage(calendar.dateBySubstractingMonths(1, fromDate: calendar.currentPage), animated: true)
    }
    
    @IBAction func swipeRight(sender: AnyObject) {
        calendar.setCurrentPage(calendar.dateByAddingMonths(1, toDate: calendar.currentPage), animated: true)
    }
    
    @IBAction func todayTap(sender: AnyObject) {
        calendar.setCurrentPage(calendar.today, animated: true)
    }
    

}

extension ViewControllerTV: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(calendar: FSCalendar!, subtitleForDate date: NSDate!) -> String! {
        return "test"
    }
    
}
