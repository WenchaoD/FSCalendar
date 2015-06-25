//
//  ViewDidLoadExampleViewController.m
//  FSCalendar
//
//  Created by DingWenchao on 6/25/15.
//  Copyright (c) 2015 =. All rights reserved.
//

#import "ViewDidLoadExampleViewController.h"
#import "NSDate+FSExtension.h"

@implementation ViewDidLoadExampleViewController

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.backgroundColor = [UIColor whiteColor];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 300)];
    calendar.dataSource = self;
    calendar.delegate = self;
//    calendar.flow = FSCalendarFlowVertical;
    [self.view addSubview:calendar];
    
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"did select date %@",[date fs_stringWithFormat:@"yyyy/MM/dd"]);
}

- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar
{
    NSLog(@"did change to month %@",[calendar.currentMonth fs_stringWithFormat:@"MMMM yyyy"]);
}

- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date
{
    return date.fs_day == 5;
}

@end
