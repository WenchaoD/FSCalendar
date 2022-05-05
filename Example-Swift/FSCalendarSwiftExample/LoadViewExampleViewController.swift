//
//  LoadViewExampleViewController.swift
//  FSCalendarSwiftExample
//
//  Created by dingwenchao on 10/17/16.
//  Copyright © 2016 wenchao. All rights reserved.
//

import UIKit
let kIdRepear6day = "kIdRepear6day"
let kIdRepear3day = "kIdRepear3day"
let kIdRepear21day = "kIdRepear21day"
let kIdRepear4day = "kIdRepear4day"

class CalendarShift {
    let id: String!
    let name: String!
    let groups: [CalendarModel]!
    static var allCalendarShift: [CalendarShift] = []
    
    static let listRepeat3Day =  ["당","비", "휴"]
    static let listRepeat6Day =  ["주", "주", "야", "야", "비", "휴"]
    static let listRepeat21Day =  ["주", "주", "주", "주", "주", "비", "비", "야", "비", "야", "비", "야", "비", "당", "비", "야", "비", "야", "비", "당", "비"]
    static let listRepeat4DayTime =  ["주", "야", "비", "휴"]
    
    init(id: String, name: String, groups: [CalendarModel]) {
        self.id = id
        self.name = name
        self.groups = groups
    }
    
    static func getAllCalendar() -> [CalendarShift]{
        if self.allCalendarShift.count == 0 {
            self.allCalendarShift = self.buildCalendarShift()
        }
        return self.allCalendarShift
    }
    
     static func buildCalendarShift()  -> [CalendarShift]{
        // repeat 6day - 당비휴
        
        let groupRepeat3Day1 = CalendarModel(name: "1", start: 2, group: listRepeat3Day)
        let groupRepeat3Day2 = CalendarModel(name: "2", start: 3, group: listRepeat3Day)
        let groupRepeat3Day3 = CalendarModel(name: "3", start: 4, group: listRepeat3Day)
        let groupRepeat3Day:[CalendarModel] = [groupRepeat3Day1, groupRepeat3Day2, groupRepeat3Day3]
        
        let calRepeat3Day = CalendarShift(id: kIdRepear3day, name: "당비휴", groups: groupRepeat3Day)
        
        
        // repeat 3day - 주주야야비휴
        
        let groupRepeat6Day1 = CalendarModel(name: "1", start: 5, group: listRepeat6Day)
        let groupRepeat6Day2 = CalendarModel(name: "2", start: 7, group: listRepeat6Day)
        let groupRepeat6Day3 = CalendarModel(name: "3", start: 9, group: listRepeat6Day)
        let groupRepeat6Day:[CalendarModel] = [groupRepeat6Day1, groupRepeat6Day2, groupRepeat6Day3]
        
        let calRepeat6Day = CalendarShift(id: kIdRepear6day, name: "주주야야비휴", groups: groupRepeat6Day)
        
        
        // repeat 21day - 21주기
        let groupRepeat21Day1 = CalendarModel(name: "1", start: 17, group: listRepeat21Day)
        let groupRepeat21Day2 = CalendarModel(name: "2", start: 3, group: listRepeat21Day)
        let groupRepeat21Day3 = CalendarModel(name: "3", start: 10, group: listRepeat21Day)
        let groupRepeat21DayTime:[CalendarModel] = [groupRepeat21Day1, groupRepeat21Day2, groupRepeat21Day3]
        
        let calRepeat21Day = CalendarShift(id: kIdRepear21day, name: "21주기", groups: groupRepeat21DayTime)
        
        
        // repeat 4day - 4조2교대(주야비휴)
        let groupRepeat4DayTime1 = CalendarModel(name: "1", start: 1, group: listRepeat4DayTime)
        let groupRepeat4DayTime2 = CalendarModel(name: "2", start: 2, group: listRepeat4DayTime)
        let groupRepeat4DayTime3 = CalendarModel(name: "3", start: 3, group: listRepeat4DayTime)
        let groupRepeat4DayTime4 = CalendarModel(name: "4", start: 4, group: listRepeat4DayTime)
        let groupRepeat4DayTime:[CalendarModel] = [groupRepeat4DayTime1, groupRepeat4DayTime2, groupRepeat4DayTime3, groupRepeat4DayTime4]
        
        let calRepeat4Day = CalendarShift(id: kIdRepear4day, name: "4조2교대(주야비휴)", groups: groupRepeat4DayTime)
        
        
        return [calRepeat3Day, calRepeat6Day, calRepeat21Day, calRepeat4Day]
    }
    
    static func getCalendarCurrent(id:String) -> CalendarShift? {
        return self.getAllCalendar().first { calenderShift in
            return calenderShift.id == id
        }
    }
}


class CalendarModel {
    let start: Int!
    let end: Int!
    let group: [String]!
    let groupReverse: [String]!
    let name: String!
    @objc init(name:String, start: Int, group: [String]) {
        self.name = name
        self.start = start
        self.group = group
        self.groupReverse = group.reversed()
        self.end = start + group.count - 1
    }
    
    open func stringKorean(from toDate: Date) -> [AnyHashable : Any] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = dateFormatter.date(from: "1970-01-01")!
        let day = startDate.fullDistance(from: toDate, resultIn: .day)!
        let split = day % 4
        
        var title = ""
        var color = ""
        var titleColor = ""
        if split == 1 || split == 4 || split == 7 {
            title = self.group[0]
            color = "orange"
            titleColor = "brown"
        } else if split == 2 || split == 5 || split == 8 {
            title = self.group[1]
            color = "red"
            titleColor = "white"
            
        } else if split == 3 || split == 6 {
            title = self.group[2]
            color = "yellow"
            titleColor = "black"
        } else if split == 0 {
            title = self.group[3]
            color = "black"
            titleColor = "white"
            
        }
        
        return ["title": title, "color": color, "titleColor": titleColor]
    }
    
    @objc func getDay(from date: Date) -> [AnyHashable : Any]? {
        
        let components = date.get(.day, .month, .year)
        var title = ""
        
        if let day = components.day {
            if day >= start {
                let index = (day - start) % self.group.count
                title = self.group[index]
            } else {
                let index = (end - day) % self.group.count
                title = self.groupReverse[index]
            }
        }
        
       let result = self.getColorTitleBackground(title: title)
        let titleColor = result.1
        let color = result.0
        
        return ["title": title, "color": color, "titleColor": titleColor]
    }
    
    func getColorTitleBackground(title: String) -> (String, String){
        
        if title == "휴" {
            return ("orange", "white")
        } else if title == "비" {
            return ("red", "white")
        }
        else if title == "당" {
            return ("yellow", "black")
        }
        else if title == "주" {
            return ("black", "white")
        }
        else if title == "야" {
            return ("blue", "white")
        }
        return ("","")
    }
}




class LoadViewExampleViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    private weak var calendar: FSCalendar!
    fileprivate let lunarFormatter = LunarFormatter()
    fileprivate let gregorian: NSCalendar! = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
    let currentCalendarType = kIdRepear21day
    let currentNameCalendarModel = "1"
    var calendarModel: CalendarModel?
    var calendarShiftCurrent:CalendarShift?
    override func loadView() {
        self.calendarShiftCurrent = CalendarShift.getCalendarCurrent(id: currentCalendarType)
        if let _calendarShift = self.calendarShiftCurrent {
            if let  _tempCalendarModel = _calendarShift.groups.first(where: { calendarModel in
                calendarModel.name == currentNameCalendarModel
            }) {
                self.calendarModel = _tempCalendarModel
            }
                
        }
        
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
        return self.calendarModel?.getDay(from: date)
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let day: Int! = self.gregorian.component(.day, from: date)
        return day % 5 == 0 ? day/5 : 0;
    }
}


extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
