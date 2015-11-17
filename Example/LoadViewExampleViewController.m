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
    view.backgroundColor = [UIColor colorWithRed:.95 green:.95 blue:.95 alpha:1.0];
    self.view = view;
    
    // 450 for iPad and 300 for iPhone
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 450 : 300;
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 64, view.frame.size.width, height)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.scrollDirection = FSCalendarScrollDirectionVertical;
    [calendar selectDate:[calendar dateWithYear:2015 month:2 day:6]];
    calendar.backgroundColor = [UIColor whiteColor];
    [view addSubview:calendar];
    self.calendar = calendar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#if 0
    FSCalendarTestSelectDate
#endif
    
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

//- (void)calendarCurrentScopeWillChange:(FSCalendar *)calendar animated:(BOOL)animated
//{
//    calendar.frame = CGRectMake(0, 64, self.view.bounds.size.width, [calendar sizeThatFits:CGSizeZero].height);
//}

//- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
//{
//    return [_calendar dateWithYear:2015 month:1 day:1];
//}
//
//- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
//{
//    return [_calendar dateWithYear:2016 month:12 day:31];
//}

- (UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date
{
    return self.images[[calendar stringFromDate:date format:@"yyyy/MM/dd"]];
}

@end
