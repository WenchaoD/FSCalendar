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

#pragma mark - Life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"FSCalendar";
        
        self.selectionColors = @{@"2015/10/8":[UIColor greenColor],
                                 @"2015/10/6":[UIColor purpleColor],
                                 @"2015/10/17":[UIColor grayColor],
                                 @"2015/10/21":[UIColor cyanColor],
                                 @"2015/11/8":[UIColor greenColor],
                                 @"2015/11/6":[UIColor purpleColor],
                                 @"2015/11/17":[UIColor grayColor],
                                 @"2015/11/21":[UIColor cyanColor],
                                 @"2015/12/8":[UIColor greenColor],
                                 @"2015/12/6":[UIColor purpleColor],
                                 @"2015/12/17":[UIColor grayColor],
                                 @"2015/12/21":[UIColor cyanColor]};
        
        self.borderDefaultColors = @{@"2015/10/8":[UIColor brownColor],
                                     @"2015/10/17":[UIColor magentaColor],
                                     @"2015/10/21":FSCalendarStandardSelectionColor,
                                     @"2015/10/25":[UIColor blackColor],
                                     @"2015/11/8":[UIColor brownColor],
                                     @"2015/11/17":[UIColor magentaColor],
                                     @"2015/11/21":FSCalendarStandardSelectionColor,
                                     @"2015/11/25":[UIColor blackColor],
                                     @"2015/12/8":[UIColor brownColor],
                                     @"2015/12/17":[UIColor magentaColor],
                                     @"2015/12/21":FSCalendarStandardSelectionColor,
                                     @"2015/12/25":[UIColor blackColor]};
        
        self.borderSelectionColors = @{@"2015/10/8":[UIColor redColor],
                                       @"2015/10/17":[UIColor purpleColor],
                                       @"2015/10/21":FSCalendarStandardSelectionColor,
                                       @"2015/10/25":FSCalendarStandardTodayColor,
                                       @"2015/11/8":[UIColor redColor],
                                       @"2015/11/17":[UIColor purpleColor],
                                       @"2015/11/21":FSCalendarStandardSelectionColor,
                                       @"2015/11/25":FSCalendarStandardTodayColor,
                                       @"2015/12/8":[UIColor redColor],
                                       @"2015/12/17":[UIColor purpleColor],
                                       @"2015/12/21":FSCalendarStandardSelectionColor,
                                       @"2015/12/25":FSCalendarStandardTodayColor};
        
        
        self.datesWithEvent = @[@"2015-10-03",
                            @"2015-10-06",
                            @"2015-10-12",
                            @"2015-10-25"];
        
        self.datesWithMultipleEvents = @[@"2015-10-08",
                                     @"2015-10-16",
                                     @"2015-10-20",
                                     @"2015-10-28"];
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = view;
    
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 450 : 300;
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, height)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.allowsMultipleSelection = YES;
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesUpperCase|FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    [self.view addSubview:calendar];
    [calendar selectDate:[calendar dateWithYear:2015 month:10 day:3]];
    self.calendar = calendar;
    
    
    UIBarButtonItem *todayItem = [[UIBarButtonItem alloc] initWithTitle:@"TODAY" style:UIBarButtonItemStyleBordered target:self action:@selector(todayItemClicked:)];
    self.navigationItem.rightBarButtonItem = todayItem;
    
}

#pragma mark - Target actions

- (void)todayItemClicked:(id)sender
{
    [_calendar setCurrentPage:[NSDate date] animated:NO];
}

#pragma mark - <FSCalendarDataSource>

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    NSString *dateString = [calendar stringFromDate:date format:@"yyyy-MM-dd"];
    if ([_datesWithEvent containsObject:dateString]) {
        return 1;
    }
    if ([_datesWithMultipleEvents containsObject:dateString]) {
        return 3;
    }
    return 0;
}

#pragma mark - <FSCalendarDelegateAppearance>

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventColorForDate:(NSDate *)date
{
    NSString *dateString = [calendar stringFromDate:date format:@"yyyy-MM-dd"];
    if ([_datesWithEvent containsObject:dateString]) {
        return appearance.eventColor;
    }
    if ([_datesWithMultipleEvents containsObject:dateString]) {
        return [UIColor magentaColor];
    }
    return 0;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance selectionColorForDate:(NSDate *)date
{
    NSString *key = [_calendar stringFromDate:date format:@"yyyy/MM/dd"];
    if ([_selectionColors.allKeys containsObject:key]) {
        return _selectionColors[key];
    }
    return appearance.selectionColor;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date
{
    NSString *key = [_calendar stringFromDate:date format:@"yyyy/MM/dd"];
    if ([_borderDefaultColors.allKeys containsObject:key]) {
        return _borderDefaultColors[key];
    }
    return appearance.borderDefaultColor;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date
{
    NSString *key = [_calendar stringFromDate:date format:@"yyyy/MM/dd"];
    if ([_borderSelectionColors.allKeys containsObject:key]) {
        return _borderSelectionColors[key];
    }
    return appearance.borderSelectionColor;
}

- (FSCalendarCellShape)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance cellShapeForDate:(NSDate *)date
{
    if ([@[@8,@17,@21,@25] containsObject:@([_calendar dayOfDate:date])]) {
        return FSCalendarCellShapeRectangle;
    }
    return FSCalendarCellShapeCircle;
}

@end
