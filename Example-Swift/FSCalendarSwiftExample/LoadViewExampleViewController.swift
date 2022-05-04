//
//  LoadViewExampleViewController.swift
//  FSCalendarSwiftExample
//
//  Created by dingwenchao on 10/17/16.
//  Copyright © 2016 wenchao. All rights reserved.
//

import UIKit

class LoadViewExampleViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    private weak var calendar: FSCalendar!
    fileprivate let lunarFormatter = LunarFormatter()
    fileprivate let gregorian: NSCalendar! = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
    override func loadView() {
        
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.groupTableViewBackground
        self.view = view
        
        let height: CGFloat = UIDevice.current.model.hasPrefix("iPad") ? 600 : 500
        let calendar = FSCalendar(frame: CGRect(x: 0, y: self.navigationController!.navigationBar.frame.maxY, width: self.view.bounds.width, height: height))
        calendar.dataSource = self
        calendar.delegate = self
        calendar.backgroundColor = UIColor.white
        self.view.addSubview(calendar)
        calendar.locale = Locale(identifier: "ko")
        self.calendar = calendar
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "FSCalendar"
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendar(_ calendar: FSCalendar, subToptitleFor date: Date) -> [AnyHashable : Any]? {
        return self.lunarFormatter.stringKorean(from: date)
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let day: Int! = self.gregorian.component(.day, from: date)
        return day % 5 == 0 ? day/5 : 0;
    }
}
