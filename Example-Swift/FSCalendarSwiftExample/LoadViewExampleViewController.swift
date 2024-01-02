//
//  LoadViewExampleViewController.swift
//  FSCalendarSwiftExample
//
//  Created by dingwenchao on 10/17/16.
//  Copyright © 2016 wenchao. All rights reserved.
//

import UIKit

let kIdWorkTypeGroup = "kIdWorkTypeGroup"

let kWorkType6day = "kWorkType6day"
let kWorkType3day = "kWorkType3day"
let kWorkType21day = "kWorkType21day"
let kWorkType4day = "kWorkType4day"

let workListIdOne = "workListIdOne"
let workListIdTwo = "workListIdTwo"
let workListIdThree = "workListIdThree"
let workListIdFour = "workListIdFour"

class ManagerWorkType {
    
    static let listRepeat3Day =  ["당","비", "휴"]
    static let listRepeat6Day =  ["주", "주", "야", "야", "비", "휴"]
    static let listRepeat21Day =  ["주", "주", "주", "주", "주", "비", "비", "야", "비", "야", "비", "야", "비", "당", "비", "야", "비", "야", "비", "당", "비"]
    static let listRepeat4DayTime =  ["주", "야", "비", "휴"]
    
    static let shared = ManagerWorkType()
    var allWorkTypeModel: [WorkTypeModel] = []
    
    @objc var workTypeId: String = ""
    @objc var workGroupId: String = ""
    
    init(){}
    
    func getAllWorkType() -> [WorkTypeModel]{
        if self.allWorkTypeModel.count == 0 {
            self.allWorkTypeModel = self.buildWorkTypeModel()
        }
        return self.allWorkTypeModel
    }
    
    func buildWorkTypeModel()  -> [WorkTypeModel]{
        
        // repeat 3day - 당비휴
        let groupRepeat3Day1 = WorkGroupModel(id: workListIdOne, name: "1팀", start: 2, group: ManagerWorkType.listRepeat3Day)
        let groupRepeat3Day2 = WorkGroupModel(id: workListIdTwo, name: "2팀", start: 3, group: ManagerWorkType.listRepeat3Day)
        let groupRepeat3Day3 = WorkGroupModel(id: workListIdThree, name: "3팀", start: 4, group: ManagerWorkType.listRepeat3Day)
        let groupRepeat3Day:[WorkGroupModel] = [groupRepeat3Day1, groupRepeat3Day2, groupRepeat3Day3]
       
        let calRepeat3Day = WorkTypeModel(id: kWorkType3day, name: "당비휴", groups: groupRepeat3Day)
       
       
        // repeat 6day - 주주야야비휴
       
        let groupRepeat6Day1 = WorkGroupModel(id: workListIdOne, name: "1팀", start: 5, group: ManagerWorkType.listRepeat6Day)
        let groupRepeat6Day2 = WorkGroupModel(id: workListIdTwo, name: "2팀", start: 7, group: ManagerWorkType.listRepeat6Day)
        let groupRepeat6Day3 = WorkGroupModel(id: workListIdThree, name: "3팀", start: 9, group: ManagerWorkType.listRepeat6Day)
        let groupRepeat6Day:[WorkGroupModel] = [groupRepeat6Day1, groupRepeat6Day2, groupRepeat6Day3]
       
        let calRepeat6Day = WorkTypeModel(id: kWorkType6day, name: "주주야야비휴", groups: groupRepeat6Day)
       
       
        // repeat 21day - 21주기
        let groupRepeat21Day1 = WorkGroupModel(id: workListIdOne, name: "1팀", start: 17, group: ManagerWorkType.listRepeat21Day)
        let groupRepeat21Day2 = WorkGroupModel(id: workListIdTwo, name: "2팀", start: 3, group: ManagerWorkType.listRepeat21Day)
        let groupRepeat21Day3 = WorkGroupModel(id: workListIdThree, name: "3팀", start: 10, group: ManagerWorkType.listRepeat21Day)
        let groupRepeat21DayTime:[WorkGroupModel] = [groupRepeat21Day1, groupRepeat21Day2, groupRepeat21Day3]
       
        let calRepeat21Day = WorkTypeModel(id: kWorkType21day, name: "21주기", groups: groupRepeat21DayTime)
       
       
        // repeat 4day - 4조2교대(주야비휴)
        let groupRepeat4DayTime1 = WorkGroupModel(id: workListIdOne, name: "1팀", start: 1, group: ManagerWorkType.listRepeat4DayTime)
        let groupRepeat4DayTime2 = WorkGroupModel(id: workListIdTwo, name: "2팀", start: 2, group: ManagerWorkType.listRepeat4DayTime)
        let groupRepeat4DayTime3 = WorkGroupModel(id: workListIdThree, name: "3팀", start: 3, group: ManagerWorkType.listRepeat4DayTime)
        let groupRepeat4DayTime4 = WorkGroupModel(id: workListIdFour, name: "4팀", start: 4, group: ManagerWorkType.listRepeat4DayTime)
        let groupRepeat4DayTime:[WorkGroupModel] = [groupRepeat4DayTime1, groupRepeat4DayTime2, groupRepeat4DayTime3, groupRepeat4DayTime4]
       
        let calRepeat4Day = WorkTypeModel(id: kWorkType4day, name: "4조2교대(주야비휴)", groups: groupRepeat4DayTime)
       
       
        return [calRepeat3Day, calRepeat6Day, calRepeat21Day, calRepeat4Day]
   }
   
    func getCalendarCurrent(id:String) -> WorkTypeModel? {
       return self.getAllWorkType().first { calenderShift in
           return calenderShift.id == id
       }
   }
    
    static func saveConfigCalendarShift(worpTypeId: String, workGroupId: String){
        let value = "\(worpTypeId),\(workGroupId)"
        let userDefault = UserDefaults.standard
        userDefault.set(value, forKey: kIdWorkTypeGroup)
        userDefault.synchronize()
    }
    
    
    static func getConfigCalendarShift() -> String? {
        return UserDefaults.standard.string(forKey: kIdWorkTypeGroup)
    }
    
    static func setupConfigCalendarShift() {
        var haveConfig = false
        if let workTypeGroupId = self.getConfigCalendarShift(), workTypeGroupId != "" {
            let arr = workTypeGroupId.components(separatedBy: ",")
            if arr.count == 2 {
                ManagerWorkType.shared.workTypeId = arr[0]
                ManagerWorkType.shared.workGroupId = arr[1]
                haveConfig = true
            }
        }
        
        if !haveConfig {
            let firstWorkType = ManagerWorkType.shared.getAllWorkType().first! // make sure have data
            ManagerWorkType.shared.workTypeId = firstWorkType.id
            ManagerWorkType.shared.workGroupId = firstWorkType.groups.first!.id // make sure have data
            ManagerWorkType.saveConfigCalendarShift(worpTypeId: ManagerWorkType.shared.workTypeId, workGroupId: ManagerWorkType.shared.workGroupId)
        }
    }
}

class WorkTypeModel {
    let id: String!
    let name: String!
    let groups: [WorkGroupModel]!
    
    init(id: String, name: String, groups: [WorkGroupModel]) {
        self.id = id
        self.name = name
        self.groups = groups
    }
     
}


class WorkGroupModel {
    
    let id: String!
    let start: Int!
    let end: Int!
    let group: [String]!
    let groupReverse: [String]!
    let name: String!
    
    @objc init(id: String, name:String, start: Int, group: [String]) {
        self.id = id
        self.name = name
        self.start = start
        self.group = group
        self.groupReverse = group.reversed()
        self.end = start + group.count - 1
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



protocol CalendarShiftDelegate {
    func reloadCalendar()
}

class LoadViewExampleViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    private weak var calendar: FSCalendar!
    fileprivate let lunarFormatter = LunarFormatter()
    fileprivate let gregorian: NSCalendar! = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
    var workTypeId: String!
    var workGroupId: String!
    var workGroupModel: WorkGroupModel?
    var workTypeModelCurrent:WorkTypeModel?
    override func loadView() {
        
        ManagerWorkType.setupConfigCalendarShift()
        
        self.setupWorkTypeGroupid()
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
        
        let showWorkTypeBtn = UIBarButtonItem(title: "worktype", style: .done, target: self, action: #selector(showWorkType))
        self.navigationItem.rightBarButtonItem = showWorkTypeBtn
    }
    
    @objc func showWorkType() {
        let vc = WorkTypeVC.init(nibName: "WorkTypeVC", bundle: nil)
        vc.delegate = self
        vc.vc = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "FSCalendar"
    }
    
    func setupWorkTypeGroupid(){
        
        self.workTypeId = ManagerWorkType.shared.workTypeId
        self.workGroupId = ManagerWorkType.shared.workGroupId
        
        self.workTypeModelCurrent = ManagerWorkType.shared.getCalendarCurrent(id: self.workTypeId)
        if let _workTypeModel = self.workTypeModelCurrent {
            if let  _tempWorkGroupModel = _workTypeModel.groups.first(where: { workGroupModel in
                workGroupModel.id == workGroupId
            }) {
                self.workGroupModel = _tempWorkGroupModel
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendar(_ calendar: FSCalendar, subToptitleFor date: Date) -> [AnyHashable : Any]? {
        return self.workGroupModel?.getDay(from: date)
    }

//    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
//        let day: Int! = self.gregorian.component(.day, from: date)
//        return day % 5 == 0 ? day/5 : 0;
//    }
}

extension LoadViewExampleViewController: CalendarShiftDelegate {
    func reloadCalendar() {
        self.setupWorkTypeGroupid()
        self.calendar.reloadData()
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
