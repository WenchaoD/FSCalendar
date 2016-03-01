//
//  LoadViewExampleViewController.m
//  FSCalendar
//
//  Created by DingWenchao on 6/25/15.
//  Copyright (c) 2015 =. All rights reserved.
//

#import "LoadViewExampleViewController.h"

@implementation LoadViewExampleViewController

- (void)dealloc
{
    NSLog(@"%@:%s", self.class.description, __FUNCTION__);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"FSCalendar";
        self.images = @{@"2015/02/01":[UIImage imageNamed:@"icon_cat"],
                        @"2015/02/05":[UIImage imageNamed:@"icon_footprint"],
                        @"2015/02/20":[UIImage imageNamed:@"icon_cat"],
                        @"2015/03/07":[UIImage imageNamed:@"icon_footprint"]};
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = view;
    
    // 450 for iPad and 300 for iPhone
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 450 : 300;
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 64, view.frame.size.width, height)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.scrollDirection = FSCalendarScrollDirectionVertical;
    calendar.backgroundColor = [UIColor whiteColor];
    [view addSubview:calendar];
    self.calendar = calendar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.calendar selectDate:[self.calendar tomorrowOfDate:[NSDate date]]];
    
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.calendar setScope:FSCalendarScopeWeek animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.calendar setScope:FSCalendarScopeMonth animated:YES];
        });
    });
    */
    
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date
{
    NSLog(@"should select date %@",[calendar stringFromDate:date format:@"yyyy/MM/dd"]);
    return YES;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"did select date %@",[calendar stringFromDate:date format:@"yyyy/MM/dd"]);
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
    NSLog(@"did change to page %@",[calendar stringFromDate:calendar.currentPage format:@"MMMM YYYY"]);
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
}

/*
- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    return [calendar tomorrowOfDate:[NSDate date]];
}
*/

/*
- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    return [_calendar dateWithYear:2026 month:12 day:31];
}
*/

- (UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date
{
    return self.images[[calendar stringFromDate:date format:@"yyyy/MM/dd"]];
}

@end
