//
//  DIVViewController.swift
//  SwiftExample
//
//  Created by dingwenchao on 06/11/2016.
//  Copyright © 2016 wenchao. All rights reserved.
//

import Foundation

enum SelectionType : Int {
    case none
    case single
    case leftBorder
    case middle
    case rightBorder
}

class DIVExampleViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    private let gregorian = NSCalendar(calendarIdentifier: .gregorian)!
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private weak var calendar: FSCalendar!
    private weak var eventLabel: UILabel!
    
    override func loadView() {
        
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.groupTableViewBackground
        self.view = view
        
        let height: CGFloat = UIDevice.current.model.hasPrefix("iPad") ? 450 : 300
        let calendar = FSCalendar(frame: CGRect(x: 0, y: self.navigationController!.navigationBar.frame.maxY, width: view.frame.size.width, height: height))
        calendar.dataSource = self
        calendar.delegate = self
        calendar.scopeGesture.isEnabled = true
        calendar.allowsMultipleSelection = true
        //    calendar.backgroundColor = [UIColor whiteColor];
        view.addSubview(calendar)
        self.calendar = calendar
        
        calendar.calendarHeaderView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        calendar.calendarWeekdayView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        calendar.appearance.eventSelectionColor = UIColor.white
        calendar.appearance.eventOffset = CGPoint(x: 0, y: -7)
        calendar.today = nil // Hide the today circle
        calendar.register(DIVCalendarCell.self, forCellReuseIdentifier: "cell")
        
        calendar.clipsToBounds = true // Remove top/bottom line
        
        let label = UILabel(frame: CGRect(x: 0, y: calendar.frame.maxY + 10, width: self.view.frame.size.width, height: 50))
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        self.view.addSubview(label)
        self.eventLabel = label
        
        let attributedText = NSMutableAttributedString(string: "")
        let attatchment = NSTextAttachment()
        attatchment.image = UIImage(named: "icon_cat")!
        attatchment.bounds = CGRect(x: 0, y: -3, width: attatchment.image!.size.width, height: attatchment.image!.size.height)
        attributedText.append(NSAttributedString(attachment: attatchment))
        attributedText.append(NSAttributedString(string: "  Hey Daily Event  "))
        attributedText.append(NSAttributedString(attachment: attatchment))
        self.eventLabel.attributedText = attributedText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "FSCalendar"
        //    [self.calendar selectDate:[self.gregorian dateByAddingUnit:NSCalendarUnitDay value:1 toDate:[NSDate date] options:0]];
        // Uncomment this to perform an 'initial-week-scope'
        // self.calendar.scope = FSCalendarScopeWeek;
    }
    
    deinit {
        print("\(#function)")
    }
    
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        return cell
    }
    
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let divCell = (cell as! DIVCalendarCell)
        // Custom today circle
        divCell.circleImageView.isHidden = !self.gregorian.isDateInToday(date)
        // Configure selection layer
        if position == .current || calendar.scope == .week {
            
            divCell.eventIndicator.isHidden = false
            
            var selectionType = SelectionType.none
            
            if calendar.selectedDates.contains(date) {
                let previousDate = self.gregorian.date(byAdding: .day, value: -1, to: date, options: NSCalendar.Options(rawValue: 0))!
                let nextDate = self.gregorian.date(byAdding: .day, value: 1, to: date, options: NSCalendar.Options(rawValue: 0))!
                if calendar.selectedDates.contains(date) {
                    if calendar.selectedDates.contains(previousDate) && calendar.selectedDates.contains(nextDate) {
                        selectionType = .middle
                    }
                    else if calendar.selectedDates.contains(previousDate) && calendar.selectedDates.contains(date) {
                        selectionType = .rightBorder
                    }
                    else if calendar.selectedDates.contains(nextDate) {
                        selectionType = .leftBorder
                    }
                    else {
                        selectionType = .single
                    }
                }
            }
            else {
                selectionType = .none
            }
            if selectionType == .none {
                divCell.selectionLayer.isHidden = true
                return
            }
            
            divCell.selectionLayer.isHidden = false
            if selectionType == .middle {
                divCell.selectionLayer.path = UIBezierPath(rect: divCell.selectionLayer.bounds).cgPath
            }
            else if selectionType == .leftBorder {
                divCell.selectionLayer.path = UIBezierPath(roundedRect: divCell.selectionLayer.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: divCell.selectionLayer.frame.width / 2, height: divCell.selectionLayer.frame.width / 2)).cgPath
            }
            else if selectionType == .rightBorder {
                divCell.selectionLayer.path = UIBezierPath(roundedRect: divCell.selectionLayer.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: divCell.selectionLayer.frame.width / 2, height: divCell.selectionLayer.frame.width / 2)).cgPath
            }
            else if selectionType == .single {
                let diameter: CGFloat = min(divCell.selectionLayer.frame.height, divCell.selectionLayer.frame.width)
                divCell.selectionLayer.path = UIBezierPath(ovalIn: CGRect(x: divCell.contentView.frame.width / 2 - diameter / 2, y: divCell.contentView.frame.height / 2 - diameter / 2, width: diameter, height: diameter)).cgPath
            }
            
        }
        else if position == .next || position == .previous {
            divCell.circleImageView.isHidden = true
            divCell.selectionLayer.isHidden = true
            divCell.eventIndicator.isHidden = true
            // Hide default event indicator
            if self.calendar.selectedDates.contains(date) {
                divCell.titleLabel!.textColor = self.calendar.appearance.titlePlaceholderColor
                // Prevent placeholders from changing text color
            }
        }
        
    }
    
    
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        if self.gregorian.isDateInToday(date) {
            return "今"
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 2
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendar.frame.size.height = bounds.height
        self.eventLabel.frame.origin.y = calendar.frame.maxY + 10
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        print("did select date \(self.formatter.string(from: date))")
        calendar.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        print("did deselect date \(self.formatter.string(from: date))")
        calendar.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if self.gregorian.isDateInToday(date) {
            return [UIColor.orange]
        }
        return [appearance.eventDefaultColor]
    }
    
}

