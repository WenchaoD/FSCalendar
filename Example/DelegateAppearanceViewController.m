//
//  RollViewController.m
//  FSCalendar
//
//  Created by dingwenchao on 10/16/15.
//  Copyright (c) 2015 wenchaoios. All rights reserved.
//

#import "DelegateAppearanceViewController.h"

#define kViolet [UIColor colorWithRed:170/255.0 green:114/255.0 blue:219/255.0 alpha:1.0]

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
    
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 400 : 300;
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, height)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.allowsMultipleSelection = YES;
//    calendar.scrollEnabled = NO;
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesUpperCase|FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    [self.view addSubview:calendar];
    self.calendar = calendar;
}

#pragma mark - <FSCalendarDelegateAppearance>

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance selectionColorForDate:(NSDate *)date
{
    if (date.fs_day == 8) {
        return [UIColor greenColor];
    } else if (date.fs_day == 16) {
        return [UIColor purpleColor];
    } else if (date.fs_day == 17) {
        return [UIColor grayColor];
    } else if (date.fs_day == 21) {
        return FSCalendarStandardSelectionColor;
    }
    return appearance.selectionColor;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date
{
    if (date.fs_day == 8) {
        return [UIColor brownColor];
    } else if (date.fs_day == 17) {
        return [UIColor magentaColor];
    } else if (date.fs_day == 21) {
        return FSCalendarStandardSelectionColor;
    } else if (date.fs_day == 25) {
        return [UIColor blackColor];
    }
    return appearance.borderDefaultColor;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date
{
    if (date.fs_day == 8) {
        return [UIColor redColor];
    } else if (date.fs_day == 17) {
        return [UIColor purpleColor];
    } else if (date.fs_day == 21) {
        return FSCalendarStandardTodayColor;
    }
    return appearance.borderSelectionColor;
}

- (FSCalendarCellShape)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance cellShapeForDate:(NSDate *)date
{
    if (date.fs_day == 17 || date.fs_day == 8 || date.fs_day == 25) {
        return FSCalendarCellShapeRectangle;
    }
    return FSCalendarCellShapeCircle;
}

@end
