//
//  FSExtensionTest.m
//  FSCalendar
//
//  Created by dingwenchao on 9/13/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+FSExtension.h"

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
}


@end
