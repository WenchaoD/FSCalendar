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

- (void)testIndexPathForDatePerformance {
    [self measureBlock:^{
        [self.calendar indexPathForDate:self.date];
    }];
}

- (void)testDateForIndexPathPerformance {
    [self measureBlock:^{
        [self.calendar dateForIndexPath:self.indexPath];
    }];
}

@end
