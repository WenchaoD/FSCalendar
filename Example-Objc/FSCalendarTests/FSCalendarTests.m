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
