//
//  FSCalendarSwiftExampleUITests.swift
//  FSCalendarSwiftExampleUITests
//
//  Created by Wenchao Ding on 29/01/2017.
//  Copyright © 2017 wenchao. All rights reserved.
//

import XCTest

class FSCalendarSwiftExampleUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        self.doTestDIY()
        self.doTestScope()
        self.doTestDelegateAppearance()
        self.doTestInterfaceBuilder()
    }
    
    func doTestDIY() {
        let application = XCUIApplication()
        application.tables.element(boundBy: 0).staticTexts["DIY"].tap()
        let calendar: XCUIElement = application.otherElements["calendar"]
        var swipeStart: XCUICoordinate = calendar.coordinate(withNormalizedOffset: CGVector(dx: 0.5/7.0, dy: 0.5))
        var swipeEnd: XCUICoordinate = calendar.coordinate(withNormalizedOffset: CGVector(dx: 6.5/7.0, dy: 0.5))
        swipeStart.press(forDuration: 0.8, thenDragTo: swipeEnd)
        calendar.swipeUp()
        calendar.swipeLeft()
        swipeStart = calendar.coordinate(withNormalizedOffset: CGVector(dx: 0.5/7.0, dy: 0.75))
        swipeEnd = calendar.coordinate(withNormalizedOffset: CGVector(dx: 6.5/7.0, dy: 0.75))
        swipeStart.press(forDuration: 0.8, thenDragTo: swipeEnd)
        calendar.swipeDown()
        // Exit
        Thread.sleep(forTimeInterval: 1)
        application.buttons.element(boundBy: 0).tap()
    }
    
    func doTestDelegateAppearance() {
        let application = XCUIApplication()
        application.tables.element(boundBy: 0).staticTexts["Delegate Appearance"].tap()
        
        let calendar: XCUIElement = application.otherElements["calendar"]
        let calendarHeight: CGFloat = UIDevice.current.model.hasPrefix("iPad") ? 400 : 300
        let cellStart: CGFloat = (FSCalendarStandardHeaderHeight+FSCalendarStandardWeekdayHeight)/calendarHeight
        let rowHeight: CGFloat = (1.0-cellStart)/6.0
        let columnWidth: CGFloat = 1.0/7
        
        let vectors = [
            CGVector(dx:6.5*columnWidth, dy:cellStart+rowHeight*0.5),
            CGVector(dx:2.5*columnWidth, dy:cellStart+rowHeight*1.5),
            CGVector(dx:4.5*columnWidth, dy:cellStart+rowHeight*1.5),
            CGVector(dx:5.5*columnWidth, dy:cellStart+rowHeight*2.5),
            CGVector(dx:6.5*columnWidth, dy:cellStart+rowHeight*2.5),
            CGVector(dx:0.5*columnWidth, dy:cellStart+rowHeight*3.5),
            CGVector(dx:3.5*columnWidth, dy:cellStart+rowHeight*3.5),
            CGVector(dx:4.5*columnWidth, dy:cellStart+rowHeight*3.5),
            CGVector(dx:0.5*columnWidth, dy:cellStart+rowHeight*4.5),
            CGVector(dx:5.5*columnWidth, dy:cellStart+rowHeight*5.5),
        ]
        vectors.forEach { (vector) in
            calendar.coordinate(withNormalizedOffset: vector).tap()
        }
        vectors.reversed().forEach { (vector) in
            calendar.coordinate(withNormalizedOffset: vector).tap()
        }
        Thread.sleep(forTimeInterval: 1.0)
        application.buttons["TODAY"].tap()
        // Exit
        Thread.sleep(forTimeInterval: 1.0)
        application.buttons.element(boundBy: 0).tap()
    }
    
    func doTestScope() {
        let application = XCUIApplication()
        application.tables.element(boundBy: 0).staticTexts["FSCalendarScope"].tap()
        let tableView: XCUIElement = application.tables.element(boundBy: 0)
        let toggleButton: XCUIElement = application.buttons["Toggle"]
        tableView.swipeDown()
        tableView.swipeUp()
        tableView.swipeUp()
        toggleButton.tap()
        toggleButton.tap()
        tableView.swipeDown()
        tableView.swipeDown()
        // Orientation Test
        Thread.sleep(forTimeInterval: 0.5)
        XCUIDevice.shared().orientation = .landscapeLeft
        Thread.sleep(forTimeInterval: 1.5)
        XCUIDevice.shared().orientation = .portrait
        Thread.sleep(forTimeInterval: 1.5)
        XCUIDevice.shared().orientation = .landscapeRight
        Thread.sleep(forTimeInterval: 1.5)
        XCUIDevice.shared().orientation = .portrait
        // Exit
        Thread.sleep(forTimeInterval: 1.5)
        application.buttons.element(boundBy: 0).tap()
    }

    func doTestInterfaceBuilder() {
        
        let application = XCUIApplication()
        application.tables.element(boundBy: 0).staticTexts["Interface Builder"].tap()
        let calendar = application.otherElements["calendar"]
        let calendarHeight: CGFloat = UIDevice.current.model.hasPrefix("iPad") ? 400 : 300
        let cellStart: CGFloat = (FSCalendarStandardHeaderHeight+FSCalendarStandardWeekdayHeight)/calendarHeight
        let rowHeight: CGFloat = (1.0-cellStart)/6.0
        let columnWidth: CGFloat = 1.0/7
    
        let nextVector = CGVector(dx: columnWidth.multiplied(by: 5.5), dy: cellStart+rowHeight.multiplied(by: 5.5))
        let prevVector = CGVector(dx: columnWidth.multiplied(by: 1.5), dy: cellStart+rowHeight.multiplied(by: 0.5))
        calendar.coordinate(withNormalizedOffset: nextVector).tap()
        calendar.coordinate(withNormalizedOffset: nextVector).tap()
        calendar.coordinate(withNormalizedOffset: prevVector).tap()
        calendar.coordinate(withNormalizedOffset: prevVector).tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        let vector1 = CGVector(dx: columnWidth.multiplied(by: 3.5), dy: cellStart+rowHeight.multiplied(by: 2.5))
        let vector2 = CGVector(dx: columnWidth.multiplied(by: 4.5), dy: cellStart+rowHeight.multiplied(by: 2.5))
        let configButton = application.buttons.element(boundBy: 2)
        
        configButton.tap()
        application.staticTexts["Theme2"].tap()
        calendar.coordinate(withNormalizedOffset: vector1).tap()
        calendar.coordinate(withNormalizedOffset: vector2).tap()
        calendar.swipeLeft()
        calendar.swipeRight()
        Thread.sleep(forTimeInterval: 0.5)
        
        configButton.tap()
        application.staticTexts["Theme3"].tap()
        calendar.coordinate(withNormalizedOffset: vector1).tap()
        calendar.coordinate(withNormalizedOffset: vector2).tap()
        calendar.swipeRight()
        calendar.swipeLeft()
        Thread.sleep(forTimeInterval: 0.5)
        
        configButton.tap()
        application.staticTexts["Theme1"].tap()
        calendar.coordinate(withNormalizedOffset: vector1).tap()
        calendar.coordinate(withNormalizedOffset: vector2).tap()
        calendar.swipeLeft()
        calendar.swipeRight()
        Thread.sleep(forTimeInterval: 0.5)
        
        configButton.tap()
        application.tables.staticTexts["Lunar"].tap()
        calendar.coordinate(withNormalizedOffset: vector1).tap()
        calendar.coordinate(withNormalizedOffset: vector2).tap()
        Thread.sleep(forTimeInterval: 0.5)
        
        configButton.tap()
        application.tables.staticTexts["Vertical"].tap()
        calendar.swipeUp()
        calendar.swipeUp()
        calendar.swipeUp()
        calendar.swipeDown()
        calendar.swipeDown()
        calendar.swipeDown()
        Thread.sleep(forTimeInterval: 0.5)
        
        configButton.tap()
        application.tables.element(boundBy: 0).swipeUp()
        application.tables.staticTexts["Monday"].tap()
        calendar.swipeUp()
        calendar.swipeDown()
        Thread.sleep(forTimeInterval: 0.5)
        
        configButton.tap()
        application.tables.element(boundBy: 0).swipeUp()
        application.tables.staticTexts["Tuesday"].tap()
        calendar.swipeUp()
        calendar.swipeDown()
        Thread.sleep(forTimeInterval: 0.5)
        
        configButton.tap()
        application.tables.element(boundBy: 0).swipeUp()
        application.tables.staticTexts["Sunday"].tap()
        calendar.swipeUp()
        calendar.swipeDown()
        Thread.sleep(forTimeInterval: 1.5)
        
        // Orientation Test
        XCUIDevice.shared().orientation = .landscapeLeft
        Thread.sleep(forTimeInterval: 1.5)
        XCUIDevice.shared().orientation = .portrait
        Thread.sleep(forTimeInterval: 1.5)
        XCUIDevice.shared().orientation = .landscapeRight
        Thread.sleep(forTimeInterval: 1.5)
        XCUIDevice.shared().orientation = .portrait
        
        // Exit
        Thread.sleep(forTimeInterval: 1.0)
        application.buttons.element(boundBy: 0).tap()
        
    }
}
