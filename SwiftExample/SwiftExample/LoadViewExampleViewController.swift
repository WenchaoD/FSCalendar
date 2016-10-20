//
//  LoadViewExampleViewController.swift
//  SwiftExample
//
//  Created by dingwenchao on 10/17/16.
//  Copyright © 2016 wenchao. All rights reserved.
//

import UIKit

class LoadViewExampleViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    private weak var calendar: FSCalendar!
    
    override func loadView() {
        
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.groupTableViewBackground
        self.view = view
        
        let calendar = FSCalendar(frame: CGRect(x: 0, y: self.navigationController!.navigationBar.frame.maxY, width: self.view.bounds.width, height: 300))
        calendar.dataSource = self
        calendar.delegate = self
        calendar.backgroundColor = UIColor.white
        calendar.scopeGesture.isEnabled = true
        self.view.addSubview(calendar)
        self.calendar = calendar
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "FSCalendar"
    }
    
    // Update your frame
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.frame = CGRect(x: 0, y: self.navigationController!.navigationBar.frame.maxY, width: bounds.width, height: bounds.height)
    }

}
