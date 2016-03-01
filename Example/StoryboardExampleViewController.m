//
//  StoryboardExampleViewController.m
//  Chinese-Lunar-Calendar
//
//  Created by Wenchao Ding on 01/29/2015.
//  Copyright (c) 2014 Wenchao Ding. All rights reserved.
//

#import "StoryboardExampleViewController.h"

#import "CalendarConfigViewController.h"

@interface StoryboardExampleViewController ()

@property (strong, nonatomic) NSCalendar *lunarCalendar;
@property (strong, nonatomic) NSArray *lunarChars;

@end

@implementation StoryboardExampleViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    _lunarCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    _lunarCalendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
    _lunarChars = @[@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",@"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",@"二一",@"二二",@"二三",@"二四",@"二五",@"二六",@"二七",@"二八",@"二九",@"三十"];

    _scrollDirection = _calendar.scrollDirection;
    _calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesUpperCase|FSCalendarCaseOptionsWeekdayUsesUpperCase;
    
    [_calendar selectDate:[_calendar dateWithYear:2015 month:10 day:5]];
    
    _datesShouldNotBeSelected = @[@"2015/08/07",
                                  @"2015/09/07",
                                  @"2015/10/07",
                                  @"2015/11/07",
                                  @"2015/12/07",
                                  @"2016/01/07",
                                  @"2016/02/07"];
    
    _datesWithEvent = @[@"2015-10-03",
                        @"2015-10-07",
                        @"2015-10-15",
                        @"2015-10-25"];
    
    // Uncomment this to test the month->week & week->month transition
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_calendar setScope:FSCalendarScopeWeek animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_calendar setScope:FSCalendarScopeMonth animated:YES];
        });
    });
     */
    
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
    NSInteger day = [_lunarCalendar components:NSCalendarUnitDay fromDate:date].day;
    return _lunarChars[day-1];
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    return [_datesWithEvent containsObject:[calendar stringFromDate:date format:@"yyyy-MM-dd"]];
}

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    return [calendar dateWithYear:2015 month:2 day:1];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    return [calendar dateWithYear:2039 month:5 day:31];
}


- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date
{
    NSLog(@"Did deselect date %@",[calendar stringFromDate:date]);
}

#pragma mark - FSCalendarDelegate

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date
{
    BOOL shouldSelect = ![_datesShouldNotBeSelected containsObject:[calendar stringFromDate:date format:@"yyyy/MM/dd"]];
    if (!shouldSelect) {
        [[[UIAlertView alloc] initWithTitle:@"FSCalendar"
                                    message:[NSString stringWithFormat:@"FSCalendar delegate forbid %@  to be selected",[calendar stringFromDate:date format:@"yyyy/MM/dd"]]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    } else {
        NSLog(@"Should select date %@",[calendar stringFromDate:date format:@"yyyy/MM/dd"]);
    }
    return shouldSelect;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"did select date %@",[calendar stringFromDate:date format:@"yyyy/MM/dd"]);
    
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
    NSLog(@"did change to page %@",[calendar stringFromDate:calendar.currentPage format:@"MMMM yyyy"]);
}

- (void)calendarCurrentScopeWillChange:(FSCalendar *)calendar animated:(BOOL)animated
{
    _calendarHeightConstraint.constant = [calendar sizeThatFits:CGSizeZero].height;
    [self.view layoutIfNeeded];
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    _calendarHeightConstraint.constant = CGRectGetHeight(bounds);
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
                _calendar.appearance.weekdayTextColor = FSCalendarStandardTitleTextColor;
                _calendar.appearance.headerTitleColor = FSCalendarStandardTitleTextColor;
                _calendar.appearance.eventColor = FSCalendarStandardEventDotColor;
                _calendar.appearance.selectionColor = FSCalendarStandardSelectionColor;
                _calendar.appearance.headerDateFormat = @"MMMM yyyy";
                _calendar.appearance.todayColor = FSCalendarStandardTodayColor;
                _calendar.appearance.cellShape = FSCalendarCellShapeCircle;
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
                _calendar.appearance.cellShape = FSCalendarCellShapeCircle;
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
                _calendar.appearance.cellShape = FSCalendarCellShapeRectangle;
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



