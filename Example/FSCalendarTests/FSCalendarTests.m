//
//  FSCalendarTests.m
//  FSCalendarTests
//
//  Created by dingwenchao on 8/24/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FSCalendar.h"
#import "FSCalendarDynamicHeader.h"

@interface FSCalendarTests : XCTestCase

@property (strong, nonatomic) FSCalendar *calendar;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end

@implementation FSCalendarTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
    self.indexPath = [NSIndexPath indexPathForItem:25 inSection:0];
    self.date = [self.calendar dateForIndexPath:self.indexPath];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testMonthsCalculation
{
    NSDate *fromDate = [self.calendar beginingOfMonthOfDate:[NSDate date]];
    fromDate = [self.calendar dateByAddingMonths:-1 toDate:fromDate];
    NSDate *toDate = [self.calendar beginingOfMonthOfDate:[NSDate date]];
    XCTAssertEqual(1, [self.calendar monthsFromDate:fromDate toDate:toDate], "Fail");
    
    NSDate *today = [NSDate date];
    NSDate *date = [self.calendar dateWithYear:[self.calendar yearOfDate:today] month:[self.calendar monthOfDate:today] day:2];
    
    XCTAssertTrue([self.calendar isDate:date equalToDate:today toCalendarUnit:FSCalendarUnitMonth], "Fail");
    
}

- (void)testIgnoringTimeComponents
{
    NSDate *date = [NSDate date];
    NSDate *newDate = [self.calendar dateByIgnoringTimeComponentsOfDate:date];
    XCTAssertTrue([self.calendar isDate:date equalToDate:newDate toCalendarUnit:FSCalendarUnitDay], "Fail");
}

- (void)testIndexPathForDatePerformance {
    [self measureBlock:^{
        [self.calendar indexPathForDate:self.date scope:FSCalendarScopeMonth];
    }];
}

- (void)testDateForIndexPathPerformance {
    [self measureBlock:^{
        [self.calendar dateForIndexPath:self.indexPath];
    }];
}

@end
