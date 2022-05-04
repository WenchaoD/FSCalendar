//
//  LunarFormatter.swift
//  FSCalendarSwiftExample
//
//  Created by Wenchao Ding on 25/07/2017.
//  Copyright © 2017 wenchao. All rights reserved.
//

import UIKit

open class LunarFormatter: NSObject {
    
    fileprivate let chineseCalendar = Calendar(identifier: .chinese)
    fileprivate let formatter = DateFormatter()
    fileprivate let lunarDays = ["初二","初三","初四","初五","初六","初七","初八","初九","初十","十一","十二","十三","十四","十五","十六","十七","十八","十九","二十","二一","二二","二三","二四","二五","二六","二七","二八","二九","三十"]
    fileprivate let lunarMonths = ["正月","二月","三月","四月","五月","六月","七月","八月","九月","十月","冬月","腊月"]
    fileprivate let lunarKoreanday = ["비","휴","주","야"]
    
    override init() {
        self.formatter.calendar = self.chineseCalendar
        self.formatter.dateFormat = "M"
    }
    
    open func string(from date: Date) -> String {
        let day = self.chineseCalendar.component(.day, from: date)
        if day != 1 {
            return self.lunarDays[day-2]
        }
        // First day of month
        let monthString = self.formatter.string(from: date)
        if self.chineseCalendar.veryShortMonthSymbols.contains(monthString) {
            if let month = Int(monthString) {
                return self.lunarMonths[month-1]
            }
            return ""
        }
        // Leap month
        let month = self.chineseCalendar.component(.month, from: date)
        return "闰" + self.lunarMonths[month-1]
    }
    
    open func stringKorean(from toDate: Date) -> [AnyHashable : Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = dateFormatter.date(from: "1970-01-01")!
//        let startDate = dateFormatter.date(from: "2022-05-03")!
        let day = startDate.fullDistance(from: toDate, resultIn: .day)!
        let split = day % 4
        print("-------- \(String(describing: split))")
        var title = ""
        var color = ""
        var titleColor = ""
        if split == 1 {
            title = lunarKoreanday[0]
            color = "orange"
            titleColor = "brown"
        } else if split == 2 {
            title = lunarKoreanday[1]
            color = "red"
            titleColor = "white"
            
        } else if split == 3 {
            title = lunarKoreanday[2]
            color = "yellow"
            titleColor = "black"
        } else if split == 0 {
            title = lunarKoreanday[3]
            color = "black"
            titleColor = "white"
            
        }
        
        return ["title": title, "color": color, "titleColor": titleColor]
    }
}

extension Date {

    func fullDistance(from date: Date, resultIn component: Calendar.Component, calendar: Calendar = .current) -> Int? {
        calendar.dateComponents([component], from: self, to: date).value(for: component)
    }

    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        let days1 = calendar.component(component, from: self)
        let days2 = calendar.component(component, from: date)
        return days1 - days2
    }

    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        distance(from: date, only: component) == 0
    }
}

