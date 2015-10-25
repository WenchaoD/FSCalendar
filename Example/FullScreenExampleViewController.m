//
//  FullScreenExample.m
//  FSCalendar
//
//  Created by Wenchao Ding on 9/16/15.
//  Copyright (c) 2015 wenchaoios. All rights reserved.
//

#import "FullScreenExampleViewController.h"
#import "NSDate+FSExtension.h"

#import "FSCalendarTestMacros.h"

@implementation FullScreenExampleViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"FSCalendar";
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    self.view = view;
    
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.pagingEnabled = NO; // important
    calendar.allowsMultipleSelection = YES;
    calendar.backgroundColor = [UIColor whiteColor];
//    calendar.appearance.caseOptions = FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    [self.view addSubview:calendar];
    self.calendar = calendar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        _calendar.appearance.caseOptions = FSCalendarCaseOptionsWeekdayUsesDefaultCase|FSCalendarCaseOptionsHeaderUsesUpperCase;
//    });
//    [_calendar selectDate:[NSDate fs_dateWithYear:2015 month:9 day:30] scrollToDate:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"reload");
        [_calendar reloadData];
        //        _calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesDefaultCase|FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    });
#if 0
    FSCalendarTestSelectDate
#endif

}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"did select %@",[date fs_stringWithFormat:@"yyyy/MM/dd"]);
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
    NSLog(@"did change page %@",[calendar.currentPage fs_stringWithFormat:@"yyyy-MM"]);
}

@end
