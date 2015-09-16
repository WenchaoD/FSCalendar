//
//  FSViewController.m
//  Chinese-Lunar-Calendar
//
//  Created by Wenchao Ding on 01/29/2015.
//  Copyright (c) 2014 Wenchao Ding. All rights reserved.
//

#import "StoryboardExampleViewController.h"
#import "NSDate+FSExtension.h"
#import "SSLunarDate.h"
#import "CalendarConfigViewController.h"

#define kPink [UIColor colorWithRed:198/255.0 green:51/255.0 blue:42/255.0 alpha:1.0]
#define kBlue [UIColor colorWithRed:31/255.0 green:119/255.0 blue:219/255.0 alpha:1.0]
#define kBlueText [UIColor colorWithRed:14/255.0 green:69/255.0 blue:221/255.0 alpha:1.0]

@interface StoryboardExampleViewController ()

@property (strong, nonatomic) NSCalendar *currentCalendar;
@property (strong, nonatomic) SSLunarDate *lunarDate;

@end

@implementation StoryboardExampleViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    _currentCalendar = [NSCalendar currentCalendar];
//    _firstWeekday = _calendar.firstWeekday;
//    _calendar.firstWeekday = 2; // Monday
//    _calendar.flow = FSCalendarFlowVertical;
//    _calendar.selectedDate = [NSDate fs_dateWithYear:2015 month:2 day:1];
    _scrollDirection = _calendar.scrollDirection;
//    _calendar.appearance.useVeryShortWeekdaySymbols = YES;
//    _calendar.scope = FSCalendarScopeWeek;
//    _calendar.allowsMultipleSelection = YES;
    
}

- (void)dealloc
{
    NSLog(@"%@:%s",self.class.description,__FUNCTION__);
}

#pragma mark - FSCalendarDataSource

- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date
{
    if (!_lunar) {
        return nil;
    }
    _lunarDate = [[SSLunarDate alloc] initWithDate:date calendar:_currentCalendar];
    return _lunarDate.dayString;
}

//- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date
//{
//    return date.fs_day == 3;
//}

//- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
//{
//    return [NSDate fs_dateWithYear:2015 month:6 day:15];
//}
//
//- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
//{
//    return [NSDate fs_dateWithYear:2025 month:7 day:15];
//}


- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date
{
    NSLog(@"Did deselect date %@",date.fs_string);
}

#pragma mark - FSCalendarDelegate

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date
{
    BOOL shouldSelect = date.fs_day != 7;
    if (!shouldSelect) {
        [[[UIAlertView alloc] initWithTitle:@"FSCalendar"
                                    message:[NSString stringWithFormat:@"FSCalendar delegate forbid %@  to be selected",[date fs_stringWithFormat:@"yyyy/MM/dd"]]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    } else {
        NSLog(@"Should select date %@",[date fs_stringWithFormat:@"yyyy/MM/dd"]);
    }
    return shouldSelect;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"did select date %@",[date fs_stringWithFormat:@"yyyy/MM/dd"]);
    
}

- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar
{
    NSLog(@"did change to month %@",[calendar.currentMonth fs_stringWithFormat:@"MMMM yyyy"]);
}

- (void)calendarCurrentScopeWillChange:(FSCalendar *)calendar animated:(BOOL)animated
{
    _calendarHeightConstraint.constant = [calendar sizeThatFits:CGSizeZero].height;
    [self.view layoutIfNeeded];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[CalendarConfigViewController class]]) {
        [segue.destinationViewController setValue:self forKey:@"viewController"];
    }
}

#pragma mark - Setter

- (void)setTheme:(NSInteger)theme
{
    if (_theme != theme) {
        _theme = theme;
        switch (theme) {
            case 0: {
                _calendar.appearance.weekdayTextColor = kBlueText;
                _calendar.appearance.headerTitleColor = kBlueText;
                _calendar.appearance.eventColor = [kBlueText colorWithAlphaComponent:0.75];
                _calendar.appearance.selectionColor = kBlue;
                _calendar.appearance.headerDateFormat = @"MMMM yyyy";
                _calendar.appearance.todayColor = kPink;
                _calendar.appearance.cellStyle = FSCalendarCellStyleCircle;
                _calendar.appearance.headerMinimumDissolvedAlpha = 0.2;
                break;
            }
            case 1: {
                _calendar.appearance.weekdayTextColor = [UIColor redColor];
                _calendar.appearance.headerTitleColor = [UIColor darkGrayColor];
                _calendar.appearance.eventColor = [UIColor greenColor];
                _calendar.appearance.selectionColor = [UIColor blueColor];
                _calendar.appearance.headerDateFormat = @"yyyy-MM";
                _calendar.appearance.todayColor = [UIColor redColor];
                _calendar.appearance.cellStyle = FSCalendarCellStyleCircle;
                _calendar.appearance.headerMinimumDissolvedAlpha = 0.0;

                break;
            }
            case 2: {
                _calendar.appearance.weekdayTextColor = [UIColor redColor];
                _calendar.appearance.headerTitleColor = [UIColor redColor];
                _calendar.appearance.eventColor = [UIColor greenColor];
                _calendar.appearance.selectionColor = [UIColor blueColor];
                _calendar.appearance.headerDateFormat = @"yyyy/MM";
                _calendar.appearance.todayColor = [UIColor orangeColor];
                _calendar.appearance.cellStyle = FSCalendarCellStyleRectangle;
                _calendar.appearance.headerMinimumDissolvedAlpha = 1.0;
                break;
            }
            default:
                break;
        }

    }
}

- (void)setLunar:(BOOL)lunar
{
    if (_lunar != lunar) {
        _lunar = lunar;
        [_calendar reloadData];
    }
}

- (void)setScrollDirection:(FSCalendarScrollDirection)scrollDirection
{
    if (_scrollDirection != scrollDirection) {
        _scrollDirection = scrollDirection;
        _calendar.scrollDirection = scrollDirection;
        [[[UIAlertView alloc] initWithTitle:@"FSCalendar"
                                    message:[NSString stringWithFormat:@"Now swipe %@",@[@"Vertically", @"Horizontally"][_calendar.scrollDirection]]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    }
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    [_calendar selectDate:selectedDate];
}

- (void)setFirstWeekday:(NSUInteger)firstWeekday
{
    if (_firstWeekday != firstWeekday) {
        _firstWeekday = firstWeekday;
        _calendar.firstWeekday = firstWeekday;
    }
}

@end



