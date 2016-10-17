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
@property (strong, nonatomic) NSDateFormatter *formatter;

@end

@implementation FSCalendarTests

- (void)setUp
{
    [super setUp];
    self.calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
    self.indexPath = [NSIndexPath indexPathForItem:25 inSection:0];
    self.date = [self.calendar dateForIndexPath:self.indexPath];
    self.formatter = [[NSDateFormatter alloc] init];
    self.formatter.dateFormat = @"yyyy-MM-dd";
    
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
        [self.calendar indexPathForDate:self.date scope:FSCalendarScopeMonth];
    }];
}

- (void)testDateForIndexPathPerformance {
    [self measureBlock:^{
        [self.calendar dateForIndexPath:self.indexPath];
    }];
}


- (void)testFilter {
    NSMutableArray<NSNumber *> *array = [NSMutableArray arrayWithCapacity:50];
    for (int i = 0; i < 50; i++) {
        [array addObject:@(i)];
    }
    [self measureBlock:^{
        [array filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [evaluatedObject compare:@25]==NSOrderedSame;
        }]];
    }];
    
}

- (void)testCache {
    NSCache *c = [[NSCache alloc] init];
    for (int i = 0; i < 50; i++) {
        [c setObject:@(i) forKey:@(i)];
    }
    [self measureBlock:^{
        [c objectForKey:@25];
    }];
}

@end
