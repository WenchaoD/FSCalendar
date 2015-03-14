//
//  FSViewController.m
//  Chinese-Lunar-Calendar
//
//  Created by Wenchao Ding on 01/29/2015.
//  Copyright (c) 2014 Wenchao Ding. All rights reserved.
//

#import "ViewController.h"
#import "NSDate+FSExtension.h"
#import "SSLunarDate.h"
#import "CalendarConfigViewController.h"

#define kPink [UIColor colorWithRed:198/255.0 green:51/255.0 blue:42/255.0 alpha:1.0]
#define kBlue [UIColor colorWithRed:31/255.0 green:119/255.0 blue:219/255.0 alpha:1.0]
#define kBlueText [UIColor colorWithRed:14/255.0 green:69/255.0 blue:221/255.0 alpha:1.0]

@interface ViewController ()

@property (strong, nonatomic) NSCalendar *currentCalendar;
@property (strong, nonatomic) SSLunarDate *lunar;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _currentCalendar = [NSCalendar currentCalendar];
}

- (NSString *)calendar:(FSCalendar *)calendarView subtitleForDate:(NSDate *)date
{
    if (!_subtitle) {
        return nil;
    }
    _lunar = [[SSLunarDate alloc] initWithDate:date calendar:_currentCalendar];
    return _lunar.dayString;
}

#pragma mark - FSCalendarDataSource

- (BOOL)calendar:(FSCalendar *)calendarView hasEventForDate:(NSDate *)date
{
    return date.fs_day == 3;
}

#pragma mark - FSCalendarDelegate

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date
{
    BOOL shouldSelect = date.fs_day != 3;
    if (!shouldSelect) {
        NSLog(@"date %@ should not be selected",[date fs_stringWithFormat:@"yyyy/MM/dd"]);
    }
    return shouldSelect;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"did select date %@",[date fs_stringWithFormat:@"yyyy/MM/dd"]);
}

- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar
{
    NSLog(@"did change to month %@",[calendar.currentMonth fs_stringWithFormat:@"yyyy/MM"]);
}

- (IBAction)changeFlowClicked:(id)sender
{
    _calendar.flow = 1 - _calendar.flow;
    [[[UIAlertView alloc] initWithTitle:@"FSCalendarView" message:@[@"Horizontal", @"Vertical"][_calendar.flow] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[CalendarConfigViewController class]]) {
        [segue.destinationViewController setValue:self forKey:@"viewController"];
    }
}

- (void)setTheme:(NSInteger)theme
{
    if (_theme != theme) {
        _theme = theme;
        switch (theme) {
            case 0:
            {
                [_calendar setWeekdayTextColor:kBlueText];
                [_calendar setHeaderTitleColor:kBlueText];
                [_calendar setEventColor:[UIColor cyanColor]];
                [_calendar setSelectionColor:kBlue];
                [_calendar setHeaderDateFormat:@"yyyy-M"];
                [_calendar setMinDissolvedAlpha:0.2];
                [_calendar setTodayColor:kPink];
                [_calendar setCellStyle:FSCalendarCellStyleCircle];
                break;
            }
            case 1:
            {
                [_calendar setWeekdayTextColor:[UIColor redColor]];
                [_calendar setHeaderTitleColor:[UIColor darkGrayColor]];
                [_calendar setEventColor:[UIColor greenColor]];
                [_calendar setSelectionColor:[UIColor blueColor]];
                [_calendar setHeaderDateFormat:@"yyyy-MM"];
                [_calendar setMinDissolvedAlpha:0.5];
                [_calendar setTodayColor:[UIColor redColor]];
                [_calendar setCellStyle:FSCalendarCellStyleCircle];
                break;
            }
            case 2:
            {
                [_calendar setWeekdayTextColor:[UIColor redColor]];
                [_calendar setHeaderTitleColor:[UIColor redColor]];
                [_calendar setEventColor:[UIColor greenColor]];
                [_calendar setSelectionColor:[UIColor blueColor]];
                [_calendar setHeaderDateFormat:@"yyyy/MM"];
                [_calendar setMinDissolvedAlpha:1.0];
                [_calendar setCellStyle:FSCalendarCellStyleRectangle];
                [_calendar setTodayColor:[UIColor orangeColor]];
                break;
            }
            default:
                break;
        }

    }
}

- (void)setSubtitle:(BOOL)subtitle
{
    if (_subtitle != subtitle) {
        _subtitle = subtitle;
        [_calendar reloadData];
    }
}

@end
