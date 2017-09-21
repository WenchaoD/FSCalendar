//
//  ViewController.swift
//  IFSCalendarFSCalendar
//
//  Created by Andrzej Spiess on 17.09.2017.
//  Copyright © 2017 eSky. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var calendarView: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.scrollDirection = .vertical
        calendarView.locale = Locale(identifier: "PL")
        calendarView.placeholderType = .none
        
        calendarView.register(IFSCalendarCell.self, forCellReuseIdentifier: "IFSCell")
        
        // MARK: Configure Sizes
        
        calendarView.rowHeight = 50
        calendarView.headerHeight = 60
        calendarView.weekdayHeight = 0
        calendarView.pagingEnabled = false
        
        // MARK: Configure Appearance
        
        calendarView.appearance.headerTitleColor = UIColor.white
        calendarView.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 20)
        calendarView.appearance.headerTitleTextAlignment = .left
        calendarView.appearance.headerDateFormat = "MMMM"
        calendarView.appearance.bottomBorderLineColor = UIColor.clear
        
        calendarView.delegate = self
        calendarView.dataSource = self
        
    }
}


// MARK: FSCalendarDataSource

extension ViewController: FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        return calendar.dequeueReusableCell(withIdentifier: "IFSCell", for: date, at: position)
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        (cell as? IFSCalendarCell)?.isMarked = calendar.selectedDates.contains(date)
    }
    
}

// MARK: FSCalendarDelegateAppearance & FSCalendarDelegate

extension ViewController: FSCalendarDelegateAppearance {
    
    // MARK: Delegate
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return monthPosition == FSCalendarMonthPosition.current
    }
    
    // MARK: Appearance
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        return UIColor(red: 7/255.0, green: 117/255.0, blue: 226/255.0, alpha: 0.2)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return UIColor(red: 226/255.0, green: 7/255.0, blue: 107/255.0, alpha: 1)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.5)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        return UIColor.white
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        return UIColor.clear
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderSelectionColorFor date: Date) -> UIColor? {
        return UIColor.white
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleOffsetFor date: Date) -> CGPoint {
        return CGPoint(x: 0, y: 3)
    }
}

class IFSCalendarCell: FSCalendarCell {
    
    override var isSelected: Bool {
        didSet {
            isMarked = isSelected
        }
    }
    
    var isMarked: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    private func mark() {
        defaultShapeLayer.fillColor = UIColor(red: 226/255.0, green: 7/255.0, blue: 107/255.0, alpha: 1).cgColor
        defaultShapeLayer.lineWidth = 4
        defaultShapeLayer.strokeColor = UIColor.white.cgColor
        
        
        self.layer.addSublayer(titleLabel.layer)
    }
    
    private func unmark() {
        defaultShapeLayer.fillColor = UIColor(red: 7/255.0, green: 117/255.0, blue: 226/255.0, alpha: 0.2).cgColor
        defaultShapeLayer.lineWidth = 0
        defaultShapeLayer.strokeColor = nil
        
        
        self.layer.addSublayer(titleLabel.layer)
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var defaultShapeLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        shapeLayer.isHidden = true
        
        let defaultShapeLayer = CAShapeLayer()
        defaultShapeLayer.fillColor = UIColor(red: 7/255.0, green: 117/255.0, blue: 226/255.0, alpha: 0.2).cgColor
        
        defaultShapeLayer.path = UIBezierPath(roundedRect: self.bounds.insetBy(dx: 5, dy: 5), byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: 5, height: 5)).cgPath
        
        
        self.defaultShapeLayer = defaultShapeLayer
        self.layer.insertSublayer(defaultShapeLayer, below: self.titleLabel!.layer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isMarked {
            mark()
        } else {
            unmark()
        }
    }
}

