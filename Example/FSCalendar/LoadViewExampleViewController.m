//
//  LoadViewExampleViewController.m
//  FSCalendar
//
//  Created by DingWenchao on 6/25/15.
//  Copyright (c) 2015 =. All rights reserved.
//

#import "LoadViewExampleViewController.h"
#import "NSDate+FSExtension.h"

@implementation LoadViewExampleViewController

- (void)dealloc
{
    NSLog(@"%@:%s", self.class.description, __FUNCTION__);
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.backgroundColor = [UIColor whiteColor];
    self.view = view;
    
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 64, view.frame.size.width, 400)];
    calendar.dataSource = self;
    calendar.delegate = self;
//    calendar.flow = FSCalendarFlowVertical;
    calendar.selectedDate = [NSDate fs_dateWithYear:2015 month:2 day:1];
    [view addSubview:calendar];
    self.calendar = calendar;
    self.calendar.appearance.headerTitleColor = [UIColor whiteColor];
    self.calendar.appearance.headerBackgroundColor = [UIColor colorWithRed:247.0/255.0 green:129.0/255.0 blue:127.0/255.0 alpha:1];
    self.calendar.appearance.weekdayTextColor = [UIColor whiteColor];
//    self.calendar.calendarGlobalColor = [UIColor colorWithRed:247.0/255.0 green:129.0/255.0 blue:127.0/255.0 alpha:1];
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"did select date %@",[date fs_stringWithFormat:@"yyyy/MM/dd"]);
}

- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar
{
    NSLog(@"did change to month %@",[calendar.currentMonth fs_stringWithFormat:@"MMMM yyyy"]);
}

//- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
//{
//    return [NSDate fs_dateWithYear:2015 month:1 day:1];
//}
//
//- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
//{
//    return [NSDate fs_dateWithYear:2015 month:10 day:31];
//}

- (UIImage *)calendar:(FSCalendar *)calendar topImageForDate:(NSDate *)date
{
    if (date.fs_day == 13) {
        return [UIImage imageNamed:@"icon_footprint"];
    }
    return nil;
}

- (UIImage *)calendar:(FSCalendar *)calendar bottomImageForDate:(NSDate *)date
{
    if (date.fs_day == 5) {
        return [UIImage imageNamed:@"icon_footprint"];
    }
    if (date.fs_day == 10 || date.fs_day == 15) {
        return [UIImage imageNamed:@"icon_cat"];
    }
    return nil;
}

@end
