//
//  DelegateAppearanceViewController.swift
//  FSCalendarSwiftExample
//
//  Created by dingwenchao on 30/12/2016.
//  Copyright © 2016 wenchao. All rights reserved.
//

import UIKit

class DelegateAppearanceViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    fileprivate weak var calendar: FSCalendar!
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    let fillSelectionColors = ["2015/10/08": UIColor.green, "2015/10/06": UIColor.purple, "2015/10/17": UIColor.gray, "2015/10/21": UIColor.cyan, "2015/11/08": UIColor.green, "2015/11/06": UIColor.purple, "2015/11/17": UIColor.gray, "2015/11/21": UIColor.cyan, "2015/12/08": UIColor.green, "2015/12/06": UIColor.purple, "2015/12/17": UIColor.gray, "2015/12/21": UIColor.cyan]

    
    let fillDefaultColors = ["2015/10/08": UIColor.purple, "2015/10/06": UIColor.green, "2015/10/18": UIColor.cyan, "2015/10/22": UIColor.yellow, "2015/11/08": UIColor.purple, "2015/11/06": UIColor.green, "2015/11/18": UIColor.cyan, "2015/11/22": UIColor.yellow, "2015/12/08": UIColor.purple, "2015/12/06": UIColor.green, "2015/12/18": UIColor.cyan, "2015/12/22": UIColor.magenta]
    
    let borderDefaultColors = ["2015/10/08": UIColor.brown, "2015/10/17": UIColor.magenta, "2015/10/21": UIColor.cyan, "2015/10/25": UIColor.black, "2015/11/08": UIColor.brown, "2015/11/17": UIColor.magenta, "2015/11/21": UIColor.cyan, "2015/11/25": UIColor.black, "2015/12/08": UIColor.brown, "2015/12/17": UIColor.magenta, "2015/12/21": UIColor.purple, "2015/12/25": UIColor.black]

    let borderSelectionColors = ["2015/10/08": UIColor.red, "2015/10/17": UIColor.purple, "2015/10/21": UIColor.cyan, "2015/10/25": UIColor.magenta, "2015/11/08": UIColor.red, "2015/11/17": UIColor.purple, "2015/11/21": UIColor.cyan, "2015/11/25": UIColor.purple, "2015/12/08": UIColor.red, "2015/12/17": UIColor.purple, "2015/12/21": UIColor.cyan, "2015/12/25": UIColor.magenta]
    
    var datesWithEvent = ["2015-10-03", "2015-10-06", "2015-10-12", "2015-10-25"]
    var datesWithMultipleEvents = ["2015-10-08", "2015-10-16", "2015-10-20", "2015-10-28"]
    
    
    override func loadView() {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.groupTableViewBackground
        self.view = view
        
        let height: CGFloat = UIDevice.current.model.hasPrefix("iPad") ? 450 : 300
        let calendar = FSCalendar(frame: CGRect(x:0, y:64, width:self.view.bounds.size.width, height:height))
        calendar.dataSource = self
        calendar.delegate = self
        calendar.allowsMultipleSelection = true
        calendar.swipeToChooseGesture.isEnabled = true
        calendar.backgroundColor = UIColor.white
        calendar.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesSingleUpperCase]
        self.view.addSubview(calendar)
        self.calendar = calendar
        calendar.select(self.dateFormatter1.date(from: "2015/10/03"))
        let todayItem = UIBarButtonItem(title: "TODAY", style: .plain, target: self, action: #selector(self.todayItemClicked(sender:)))
        self.navigationItem.rightBarButtonItem = todayItem
        
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
    }
    
    deinit {
        print("\(#function)")
    }
    
    @objc
    func todayItemClicked(sender: AnyObject) {
        self.calendar.setCurrentPage(Date(), animated: false)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = self.dateFormatter2.string(from: date)
        if self.datesWithEvent.contains(dateString) {
            return 1
        }
        if self.datesWithMultipleEvents.contains(dateString) {
            return 3
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventColorFor date: Date) -> UIColor? {
        let dateString = self.dateFormatter2.string(from: date)
        if self.datesWithEvent.contains(dateString) {
            return UIColor.purple
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let key = self.dateFormatter2.string(from: date)
        if self.datesWithMultipleEvents.contains(key) {
            return [UIColor.magenta, appearance.eventDefaultColor, UIColor.black]
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        let key = self.dateFormatter1.string(from: date)
        if let color = self.fillSelectionColors[key] {
            return color
        }
        return appearance.selectionColor
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let key = self.dateFormatter1.string(from: date)
        if let color = self.fillDefaultColors[key] {
            return color
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        let key = self.dateFormatter1.string(from: date)
        if let color = self.borderDefaultColors[key] {
            return color
        }
        return appearance.borderDefaultColor
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderSelectionColorFor date: Date) -> UIColor? {
        let key = self.dateFormatter1.string(from: date)
        if let color = self.borderSelectionColors[key] {
            return color
        }
        return appearance.borderSelectionColor
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderRadiusFor date: Date) -> CGFloat {
        if [8, 17, 21, 25].contains((self.gregorian.component(.day, from: date))) {
            return 0.0
        }
        return 1.0
    }
    
}
