//
//  FSCalendarExampleUITests.m
//  FSCalendarExampleUITests
//
//  Created by Wenchao Ding on 27/01/2017.
//  Copyright © 2017 wenchao. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FSCalendar.h"

@interface FSCalendarExampleUITests : XCTestCase

@property (strong, nonatomic) XCUIApplication *application;

@end

@implementation FSCalendarExampleUITests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
}

- (void)testDIY
{
    XCUIApplication *application = [[XCUIApplication alloc] init];
    [[application.tables elementBoundByIndex:0].cells[@"DIY Example, Feature!"] tap];
    XCUIElement *calendar = application.otherElements[@"calendar"];
    
    XCUICoordinate *swipeStart = [calendar coordinateWithNormalizedOffset:CGVectorMake(0.5/7.0, 0.5)];
    XCUICoordinate *swipeEnd = [calendar coordinateWithNormalizedOffset:CGVectorMake(6.5/7.0, 0.5)];
    [swipeStart pressForDuration:0.8 thenDragToCoordinate:swipeEnd];
    
    [calendar swipeUp];
    [calendar swipeLeft];
    
    swipeStart = [calendar coordinateWithNormalizedOffset:CGVectorMake(0.5/7.0, 0.75)];
    swipeEnd = [calendar coordinateWithNormalizedOffset:CGVectorMake(6.5/7.0, 0.75)];
    [swipeStart pressForDuration:0.8 thenDragToCoordinate:swipeEnd];
    [calendar swipeDown];
    
    // Exit
    [NSThread sleepForTimeInterval:1];
    [[application.buttons elementBoundByIndex:0] tap]; // Pop
}

- (void)testPrevNextButtons
{
    XCUIApplication *application = [[XCUIApplication alloc] init];
    [[application.tables elementBoundByIndex:0].cells[@"Prev-Next Buttons"] tap];
    XCUIElement *prevButton = [application.buttons elementBoundByIndex:2];
    XCUIElement *nextButton = [application.buttons elementBoundByIndex:3];
    NSInteger count = 3;
    for (int i = 0; i < count; i++) {
        [prevButton tap];
    }
    for (int i = 0; i < count; i++) {
        [nextButton tap];
    }
    // Exit
    [NSThread sleepForTimeInterval:1];
    [[application.buttons elementBoundByIndex:0] tap]; // Pop
}

- (void)testHidePlaceholders
{
    XCUIApplication *application = [[XCUIApplication alloc] init];
    [[application.tables elementBoundByIndex:0].cells[@"Hides Placeholder"] tap];
    XCUIElement *calendar = application.otherElements[@"calendar"];
    NSInteger count = 3;
    for (int i = 0; i < count; i++) {
        [calendar swipeDown];
    }
    for (int i = 0; i < count; i++) {
        [calendar swipeUp];
    }
    // Exit
    [NSThread sleepForTimeInterval:1];
    [[application.buttons elementBoundByIndex:0] tap];
}

- (void)testDelegateAppearance
{
    XCUIApplication *application = [[XCUIApplication alloc] init];
    [[application.tables elementBoundByIndex:0].cells[@"Delegate Appearance"] tap];
    XCUIElement *calendar = application.otherElements[@"calendar"];
    
    CGFloat calendarHeight = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 400 : 300;
    CGFloat cellStart = (FSCalendarStandardHeaderHeight+FSCalendarStandardWeekdayHeight)/calendarHeight;
    CGFloat rowHeight = (1.0-cellStart)/6.0;
    CGFloat columnWidth = 1.0/7;
    
    CGVector vectors[10] = {
        CGVectorMake(6.5*columnWidth, cellStart+rowHeight*0.5),
        CGVectorMake(2.5*columnWidth, cellStart+rowHeight*1.5),
        CGVectorMake(4.5*columnWidth, cellStart+rowHeight*1.5),
        CGVectorMake(5.5*columnWidth, cellStart+rowHeight*2.5),
        CGVectorMake(6.5*columnWidth, cellStart+rowHeight*2.5),
        CGVectorMake(0.5*columnWidth, cellStart+rowHeight*3.5),
        CGVectorMake(3.5*columnWidth, cellStart+rowHeight*3.5),
        CGVectorMake(4.5*columnWidth, cellStart+rowHeight*3.5),
        CGVectorMake(0.5*columnWidth, cellStart+rowHeight*4.5),
        CGVectorMake(5.5*columnWidth, cellStart+rowHeight*5.5),
    };
    for (NSInteger i = 0; i < 10; i++) {
        [[calendar coordinateWithNormalizedOffset:vectors[i]] tap];
    }
    for (NSInteger i = 9; i >= 0; i--) {
        [[calendar coordinateWithNormalizedOffset:vectors[i]] tap];
    }
    [NSThread sleepForTimeInterval:1.0];
    [application.buttons[@"TODAY"] tap];
    
    // Exit
    [NSThread sleepForTimeInterval:1.0];
    [[application.buttons elementBoundByIndex:0] tap];
}

- (void)testFullScreen
{
    XCUIApplication *application = [[XCUIApplication alloc] init];
    [[application.tables elementBoundByIndex:0].cells[@"Full Screen Example"] tap];
    XCUIElement *calendar = application.otherElements[@"calendar"];
    [calendar swipeUp];
    [application.buttons[@"Lunar"] tap];
    [calendar swipeUp];
    [application.buttons[@"Lunar"] tap];
    [NSThread sleepForTimeInterval:1.0];
    [application.buttons[@"Today"] tap];
    
    // Exit
    [NSThread sleepForTimeInterval:1];
    [[application.buttons elementBoundByIndex:0] tap];
}

- (void)testScope
{
    XCUIApplication *application = [[XCUIApplication alloc] init];
    [[application.tables elementBoundByIndex:0].cells[@"FSCalendarScope Example"] tap];
    XCUIElement *tableView = [application.tables elementBoundByIndex:0];
    XCUIElement *toggleButton = application.buttons[@"Toggle"];
    [tableView swipeDown];
    [tableView swipeUp];
    [tableView swipeUp];
    [toggleButton tap];
    [toggleButton tap];
    [tableView swipeDown];
    [tableView swipeDown];
    
    // Orientation Test
    [NSThread sleepForTimeInterval:0.5];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeLeft;
    [NSThread sleepForTimeInterval:1.5];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    [NSThread sleepForTimeInterval:1.5];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeRight;
    [NSThread sleepForTimeInterval:1.5];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    [NSThread sleepForTimeInterval:1];
    
    // Exit
    [NSThread sleepForTimeInterval:1];
    [[application.buttons elementBoundByIndex:0] tap];
}

- (void)testStoryboard
{
    XCUIApplication *application = [[XCUIApplication alloc] init];
    [[application.tables elementBoundByIndex:0].cells[@"Storyboard Example"] tap];
    XCUIElement *calendar = application.otherElements[@"calendar"];
    CGFloat calendarHeight = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 400 : 300;
    CGFloat cellStart = (FSCalendarStandardHeaderHeight+FSCalendarStandardWeekdayHeight)/calendarHeight;
    CGFloat rowHeight = (1.0-cellStart)/6.0;
    CGFloat columnWidth = 1.0/7;
    
    CGVector nextVector = CGVectorMake(columnWidth * 5.5, cellStart + rowHeight * 5.5);
    CGVector prevVector = CGVectorMake(columnWidth * 1.5, cellStart + rowHeight * 0.5);
    [[calendar coordinateWithNormalizedOffset:nextVector] tap];
    [[calendar coordinateWithNormalizedOffset:nextVector] tap];
    [[calendar coordinateWithNormalizedOffset:prevVector] tap];
    [[calendar coordinateWithNormalizedOffset:prevVector] tap];
    
    CGVector vector1 = CGVectorMake(columnWidth * 3.5, cellStart + rowHeight * 2.5);
    CGVector vector2 = CGVectorMake(columnWidth * 4.5, cellStart + rowHeight * 2.5);
    
    XCUIElement *configureButton = [application.buttons elementBoundByIndex:2];
    
    [NSThread sleepForTimeInterval:0.5];
    [configureButton tap];
    [application.tables.staticTexts[@"Theme2"] tap];
    [[calendar coordinateWithNormalizedOffset:vector1] tap];
    [[calendar coordinateWithNormalizedOffset:vector2] tap];
    [calendar swipeLeft];
    [calendar swipeRight];
    
    [NSThread sleepForTimeInterval:0.5];
    [configureButton tap];
    [application.tables.staticTexts[@"Theme3"] tap];
    [[calendar coordinateWithNormalizedOffset:vector1] tap];
    [[calendar coordinateWithNormalizedOffset:vector2] tap];
    [calendar swipeRight];
    [calendar swipeLeft];
    
    [NSThread sleepForTimeInterval:0.5];
    [configureButton tap];
    [application.tables.staticTexts[@"Theme1"] tap];
    [[calendar coordinateWithNormalizedOffset:vector1] tap];
    [[calendar coordinateWithNormalizedOffset:vector2] tap];
    [calendar swipeLeft];
    [calendar swipeRight];
    
    [NSThread sleepForTimeInterval:0.5];
    [configureButton tap];
    [application.tables.staticTexts[@"Lunar"] tap];
    [[calendar coordinateWithNormalizedOffset:vector1] tap];
    [[calendar coordinateWithNormalizedOffset:vector2] tap];
    
    [NSThread sleepForTimeInterval:0.5];
    [configureButton tap];
    [application.tables.staticTexts[@"Vertical"] tap];
    [calendar swipeUp];
    [calendar swipeUp];
    [calendar swipeUp];
    [calendar swipeDown];
    [calendar swipeDown];
    [calendar swipeDown];
    
    
    XCUIElement *table = [application.tables elementBoundByIndex:0];
    [NSThread sleepForTimeInterval:0.5];
    [configureButton tap];
    XCUIElement *monday = application.tables.staticTexts[@"Monday"];
    [self swipeUpTable:table toElement:monday];
    [monday tap];
    [calendar swipeUp];
    [calendar swipeDown];
    [NSThread sleepForTimeInterval:1];
    
    [NSThread sleepForTimeInterval:0.5];
    [configureButton tap];
    XCUIElement *tuesday = application.tables.staticTexts[@"Tuesday"];
    [self swipeUpTable:table toElement:monday];
    [tuesday tap];
    [calendar swipeDown];
    [calendar swipeUp];
    
    [NSThread sleepForTimeInterval:0.5];
    [configureButton tap];
    XCUIElement *sunday = application.tables.staticTexts[@"Sunday"];
    [self swipeUpTable:table toElement:monday];
    [sunday tap];
    [calendar swipeUp];
    [calendar swipeDown];
    [NSThread sleepForTimeInterval:1];
    
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeLeft;
    [NSThread sleepForTimeInterval:1.5];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    [NSThread sleepForTimeInterval:1.5];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeRight;
    [NSThread sleepForTimeInterval:1.5];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    [NSThread sleepForTimeInterval:1];
    
    // Exit
    [NSThread sleepForTimeInterval:1];
    [[application.buttons elementBoundByIndex:0] tap];
}

- (void)swipeUpTable:(XCUIElement *)table toElement:(XCUIElement *)row
{
    NSInteger maxSwipe = 5;
    NSInteger currentSwipe = 0;
    while (currentSwipe < maxSwipe && !row.exists) {
        currentSwipe++;
        [table swipeUp];
    }
}

@end
