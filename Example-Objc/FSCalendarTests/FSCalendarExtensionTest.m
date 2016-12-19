//
//  FSExtensionTest.m
//  FSCalendar
//
//  Created by dingwenchao on 9/13/16.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FSCalendarExtensions.h"

@interface FSCalendarExtensionTest : XCTestCase

@end

@implementation FSCalendarExtensionTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testNSObjectExtension
{
    NSString *string = @"hello";
    NSString *newString = [string fs_performSelector:@selector(stringByAppendingString:) withObjects:@" world.", nil];
    XCTAssertEqualObjects(newString, @"hello world.");
    
    NSArray *array = @[@0];
    NSArray *newArray = [array fs_performSelector:@selector(arrayByAddingObject:) withObjects:@1, nil];
    XCTAssertEqualObjects(newArray, (@[@0,@1]));
    
    UITableView *t = [UITableView new];
    NSValue *insets = [t fs_performSelector:@selector(contentInset) withObjects:nil, nil];
    XCTAssertEqualObjects(insets, ([NSValue valueWithUIEdgeInsets:t.contentInset]));
    
    NSNumber *rowHeight = [t fs_performSelector:@selector(rowHeight) withObjects:nil, nil];
    XCTAssertEqualObjects(rowHeight, @(t.rowHeight));
    
    UIColor *color = [UIColor alloc];
    UIColor *color1 = [color initWithRed:1 green:1 blue:1 alpha:1];
    UIColor *color2 = [color fs_performSelector:@selector(initWithRed:green:blue:alpha:) withObjects:@1,@1,@1,@1,nil];
    XCTAssertEqualObjects(color1, color2);

    NSValue *value1 = [NSValue valueWithCGSize:CGSizeMake(10, 10)];
    NSValue *value2 = [NSValue fs_performSelector:@selector(valueWithCGSize:) withObjects:[NSValue valueWithCGSize:CGSizeMake(10, 10)],nil];
    XCTAssertEqualObjects(value1, value2);
    
}


@end
