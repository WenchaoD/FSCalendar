//
//  FSCalendarTests.m
//  FSCalendarTests
//
//  Created by dingwenchao on 8/24/16.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FSCalendar.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarExtensions.h"

@interface FSCalendarTests : XCTestCase <FSCalendarDataSource,FSCalendarDelegate>

@property (strong, nonatomic) FSCalendar *calendar;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSMutableArray<NSIndexPath *> *indexPaths;
@property (strong, nonatomic) NSDateFormatter *formatter;

@end

@implementation FSCalendarTests

- (void)setUp
{
    [super setUp];
    self.calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
    [self.calendar.calculator reloadSections];
    self.indexPath = [NSIndexPath indexPathForItem:25 inSection:0];
    
    self.indexPaths = [NSMutableArray array];
    for (int i = 0; i < 42; i++) {
        [self.indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }
    self.formatter = [[NSDateFormatter alloc] init];
    self.formatter.dateFormat = @"yyyy-MM-dd";
    self.date = [self.formatter dateFromString:@"1900-11-11"];
    
}

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    return [self.formatter dateFromString:@"1900-01-01"];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    return [self.formatter dateFromString:@"2300-01-01"];
}

- (void)tearDown
{
    [super tearDown];
    self.calendar = nil;
    self.indexPath = nil;
    self.date = nil;
}

// 首周可以跨到公元前，占位日期重建必须保留纪元。
- (void)testEraBoundaryDateHelpers
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    gregorian.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.era = 1;
    components.year = 1;
    components.month = 1;
    components.day = 1;
    NSDate *minimum = [gregorian dateFromComponents:components];
    NSDate *previousDay = [gregorian dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:minimum options:0];
    XCTAssertEqual([gregorian component:NSCalendarUnitEra fromDate:[gregorian fs_firstDayOfMonth:previousDay]], 0);
    XCTAssertEqualObjects([gregorian fs_lastDayOfMonth:previousDay], previousDay);
    for (NSUInteger weekday = 1; weekday <= 7; weekday++) {
        gregorian.firstWeekday = weekday;
        NSDate *first = [gregorian fs_firstDayOfWeek:minimum];
        NSDate *middle = [gregorian dateByAddingUnit:NSCalendarUnitDay value:3 toDate:first options:0];
        XCTAssertEqualObjects([gregorian fs_middleDayOfWeek:minimum], middle);
    }
}

- (void)testOutOfBoundsException
{
    XCTAssertThrows([self.calendar selectDate:[self.formatter dateFromString:@"1900-01-01"]]);
    XCTAssertThrows([self.calendar selectDate:[self.formatter dateFromString:@"2300-01-01"]]);
}

- (void)testIndexPathForDatePerformance {
    [self measureBlock:^{
        [self.calendar.calculator indexPathForDate:self.date scope:FSCalendarScopeMonth];
    }];
}

- (void)testDateForIndexPathPerformance {
    [self measureBlock:^{
        [self.indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.calendar.calculator dateForIndexPath:obj];
        }];
    }];
}

@end
