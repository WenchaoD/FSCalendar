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
    return date.fs_day != 3;
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
                [[FSCalendar appearance] setWeekdayTextColor:kBlueText];
                [[FSCalendar appearance] setHeaderTitleColor:kBlueText];
                [[FSCalendar appearance] setEventColor:[UIColor cyanColor]];
                [[FSCalendar appearance] setSelectionColor:kBlue];
                [[FSCalendar appearance] setHeaderDateFormat:@"yyyy-M"];
                [[FSCalendar appearance] setMinDissolvedAlpha:0.2];
                [[FSCalendar appearance] setTodayColor:kPink];
                [[FSCalendar appearance] setCellStyle:FSCalendarCellStyleCircle];
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
                [[FSCalendar appearance] setCellStyle:FSCalendarCellStyleCircle];
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
                [[FSCalendar appearance] setCellStyle:FSCalendarCellStyleRectangle];
                [[FSCalendar appearance] setTodayColor:[UIColor orangeColor]];
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
