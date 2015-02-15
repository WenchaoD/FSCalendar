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

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)changeFlowClicked:(id)sender
{
    _calendar.flow = 1 - _calendar.flow;
    [[[UIAlertView alloc] initWithTitle:@"FSCalendarView" message:@[@"Horizontal", @"Vertical"][_calendar.flow] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (NSString *)calendar:(FSCalendar *)calendarView subtitleForDay:(NSDate *)date
{
    return [[SSLunarDate alloc] initWithDate:date].dayString;
}

- (BOOL)calendar:(FSCalendar *)calendarView hasEventForDate:(NSDate *)date
{
    return date.fs_day == 3;
}

@end
