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

@implementation ViewController

- (IBAction)changeFlowClicked:(id)sender
{
    _calendar.flow = 1 - _calendar.flow;
    [[[UIAlertView alloc] initWithTitle:@"FSCalendarView" message:@[@"Horizontal", @"Vertical"][_calendar.flow] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (NSString *)calendar:(FSCalendar *)calendarView subtitleForDay:(NSDate *)date
{
    return _subtitle ? [[SSLunarDate alloc] initWithDate:date].dayString : nil;
}

- (BOOL)calendar:(FSCalendar *)calendarView hasEventForDate:(NSDate *)date
{
    return date.fs_day == 3;
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
                [[FSCalendar appearance] setWeekdayTextColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
                [[FSCalendar appearance] setHeaderTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
                [[FSCalendar appearance] setEventColor:[UIColor cyanColor]];
                [[FSCalendar appearance] setSelectionColor:[UIColor blackColor]];
                [[FSCalendar appearance] setHeaderDateFormat:@"yyyy-M"];
                [[FSCalendar appearance] setMinDissolvedAlpha:0.2];
                [[FSCalendar appearance] setTodayColor:[UIColor orangeColor]];
                [[FSCalendar appearance] setUnitStyle:FSCalendarUnitStyleCircle];
                [[FSCalendar appearance] setWeekdayTextColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
                break;
            }
            case 1:
            {
                [[FSCalendar appearance] setWeekdayTextColor:[UIColor redColor]];
                [[FSCalendar appearance] setHeaderTitleColor:[UIColor darkGrayColor]];
                [[FSCalendar appearance] setEventColor:[UIColor greenColor]];
                [[FSCalendar appearance] setSelectionColor:[UIColor blueColor]];
                [[FSCalendar appearance] setHeaderDateFormat:@"yyyy-MM"];
                [[FSCalendar appearance] setMinDissolvedAlpha:0.5];
                [[FSCalendar appearance] setTodayColor:[UIColor redColor]];
                [[FSCalendar appearance] setUnitStyle:FSCalendarUnitStyleCircle];
                [[FSCalendar appearance] setWeekdayTextColor:[UIColor darkTextColor]];
                break;
            }
            case 2:
            {
                [[FSCalendar appearance] setWeekdayTextColor:[UIColor redColor]];
                [[FSCalendar appearance] setHeaderTitleColor:[UIColor redColor]];
                [[FSCalendar appearance] setEventColor:[UIColor greenColor]];
                [[FSCalendar appearance] setSelectionColor:[UIColor blueColor]];
                [[FSCalendar appearance] setHeaderDateFormat:@"yyyy/MM"];
                [[FSCalendar appearance] setMinDissolvedAlpha:1.0];
                [[FSCalendar appearance] setUnitStyle:FSCalendarUnitStyleRectangle];
                [[FSCalendar appearance] setTodayColor:[UIColor orangeColor]];
                [[FSCalendar appearance] setWeekdayTextColor:[UIColor redColor]];
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
