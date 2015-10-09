//
//  DelegateAppearanceViewController.m
//  FSCalendar
//
//  Created by Wenchao Ding on 10/2/15.
//  Copyright © 2015 wenchaoios. All rights reserved.
//

#import "DelegateAppearanceViewController.h"
#import "FSCalendarTestMacros.h"
#import "NSDate+FSExtension.h"

#define kPink [UIColor colorWithRed:198/255.0 green:51/255.0 blue:42/255.0 alpha:1.0]

@implementation DelegateAppearanceViewController

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
    view.backgroundColor = [UIColor colorWithRed:.95 green:.95 blue:.95 alpha:1.0];
    self.view = view;
    
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 300)];
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.allowsMultipleSelection = YES;
    [self.view addSubview:calendar];
    self.calendar = calendar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (int i = 1; i < 28; i+=2) {
        [_calendar selectDate:[[NSDate date].fs_firstDayOfMonth fs_dateByAddingDays:i]];
    }
    
#if 0
    FSCalendarTestSelectDate
#endif
    
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance selectionColorForDate:(NSDate *)date
{
    if (date.fs_day % 5 == 0) {
        return [UIColor purpleColor];
    }
    if (date.fs_day % 3 == 0) {
        return [UIColor cyanColor];
    }
    if (date.fs_day % 7 == 0) {
        return kPink;
    }
    return nil;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleSelectionColorForDate:(NSDate *)date
{
    if (date.fs_day % 5 == 0) {
        return [UIColor orangeColor];
    }
    if (date.fs_day % 3 == 0) {
        return [UIColor purpleColor];
    }
    return nil;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date
{
    if (date.fs_day % 5 == 0) {
        return [UIColor redColor];
    }
    return nil;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date
{
    if (date.fs_day % 5 == 0) {
        return [UIColor greenColor];
    }
    return nil;
}

- (FSCalendarCellStyle)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance cellStyleForDate:(NSDate *)date
{
    if (date.fs_day >= 14) {
        return FSCalendarCellStyleRectangle;
    }
    return FSCalendarCellStyleCircle;
}

@end
