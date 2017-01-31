//
//  StoryboardExampleViewController.m
//  Chinese-Lunar-Calendar
//
//  Created by Wenchao Ding on 01/29/2015.
//  Copyright (c) 2014 Wenchao Ding. All rights reserved.
//

#import "StoryboardExampleViewController.h"

#import "CalendarConfigViewController.h"

@interface StoryboardExampleViewController()<FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>

@property (weak  , nonatomic) IBOutlet FSCalendar *calendar;
@property (weak  , nonatomic) IBOutlet NSLayoutConstraint *calendarHeightConstraint;

@property (assign, nonatomic) NSInteger      theme;
@property (assign, nonatomic) BOOL           lunar;

@property (strong, nonatomic) NSArray<NSString *> *datesShouldNotBeSelected;
@property (strong, nonatomic) NSArray<NSString *> *datesWithEvent;

@property (strong, nonatomic) NSCalendar *gregorianCalendar;

@property (strong, nonatomic) NSCalendar *lunarCalendar;
@property (strong, nonatomic) NSArray<NSString *> *lunarChars;

@property (strong, nonatomic) NSDateFormatter *dateFormatter1;
@property (strong, nonatomic) NSDateFormatter *dateFormatter2;

- (IBAction)unwind2StoryboardExample:(UIStoryboardSegue *)segue;

@end

@implementation StoryboardExampleViewController

#pragma mark - Life Cycle

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        self.gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        
        NSLocale *chinese = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
        
        self.dateFormatter1 = [[NSDateFormatter alloc] init];
        self.dateFormatter1.locale = chinese;
        self.dateFormatter1.dateFormat = @"yyyy/MM/dd";
        
        self.dateFormatter2 = [[NSDateFormatter alloc] init];
        self.dateFormatter2.locale = chinese;
        self.dateFormatter2.dateFormat = @"yyyy-MM-dd";
        
        self.lunarCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
        self.lunarCalendar.locale = chinese;
        self.lunarChars = @[@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",@"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",@"二一",@"二二",@"二三",@"二四",@"二五",@"二六",@"二七",@"二八",@"二九",@"三十"];
        
        self.calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesUpperCase|FSCalendarCaseOptionsWeekdayUsesUpperCase;
        
        self.datesShouldNotBeSelected = @[@"2016/08/07",
                                          @"2016/09/07",
                                          @"2016/10/07",
                                          @"2016/11/07",
                                          @"2016/12/07",
                                          @"2016/01/07",
                                          @"2016/02/07"];
        
        self.datesWithEvent = @[@"2016-12-03",
                                @"2016-12-07",
                                @"2016-12-15",
                                @"2016-12-25"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if ([[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
        self.calendarHeightConstraint.constant = 400;
    }
    [self.calendar selectDate:[self.dateFormatter1 dateFromString:@"2016/12/05"] scrollToDate:YES];
    
    self.calendar.accessibilityIdentifier = @"calendar";
    
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - FSCalendarDataSource

- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date
{
    return [self.gregorianCalendar isDateInToday:date] ? @"今天" : nil;
}

- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date
{
    if (!_lunar) {
        return nil;
    }
    NSInteger day = [_lunarCalendar component:NSCalendarUnitDay fromDate:date];
    return _lunarChars[day-1];
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    if ([self.datesWithEvent containsObject:[self.dateFormatter2 stringFromDate:date]]) {
        return 1;
    }
    return 0;
}

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    return [self.dateFormatter1 dateFromString:@"2016/10/01"];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    return [self.dateFormatter1 dateFromString:@"2017/05/31"];
}

#pragma mark - FSCalendarDelegate

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    BOOL shouldSelect = ![_datesShouldNotBeSelected containsObject:[self.dateFormatter1 stringFromDate:date]];
    if (!shouldSelect) {
        [[[UIAlertView alloc] initWithTitle:@"FSCalendar"
                                    message:[NSString stringWithFormat:@"FSCalendar delegate forbid %@  to be selected",[self.dateFormatter1 stringFromDate:date]]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    } else {
        NSLog(@"Should select date %@",[self.dateFormatter1 stringFromDate:date]);
    }
    return shouldSelect;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    NSLog(@"did select date %@",[self.dateFormatter1 stringFromDate:date]);
    if (monthPosition == FSCalendarMonthPositionNext || monthPosition == FSCalendarMonthPositionPrevious) {
        [calendar setCurrentPage:date animated:YES];
    }
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
    NSLog(@"did change to page %@",[self.dateFormatter1 stringFromDate:calendar.currentPage]);
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    _calendarHeightConstraint.constant = CGRectGetHeight(bounds);
    [self.view layoutIfNeeded];
}

- (CGPoint)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleOffsetForDate:(NSDate *)date
{
    if ([self calendar:calendar subtitleForDate:date]) {
        return CGPointZero;
    }
    if ([_datesWithEvent containsObject:[self.dateFormatter2 stringFromDate:date]]) {
        return CGPointMake(0, -2);
    }
    return CGPointZero;
}

- (CGPoint)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventOffsetForDate:(NSDate *)date
{
    if ([self calendar:calendar subtitleForDate:date]) {
        return CGPointZero;
    }
    if ([_datesWithEvent containsObject:[self.dateFormatter2 stringFromDate:date]]) {
        return CGPointMake(0, -10);
    }
    return CGPointZero;
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventSelectionColorsForDate:(nonnull NSDate *)date
{
    if ([self calendar:calendar subtitleForDate:date]) {
        return @[appearance.eventDefaultColor];
    }
    if ([_datesWithEvent containsObject:[self.dateFormatter2 stringFromDate:date]]) {
        return @[[UIColor whiteColor]];
    }
    return nil;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CalendarConfigViewController *config = segue.destinationViewController;
    config.lunar = self.lunar;
    config.theme = self.theme;
    config.selectedDate = self.calendar.selectedDate;
    config.firstWeekday = self.calendar.firstWeekday;
    config.scrollDirection = self.calendar.scrollDirection;
}

- (void)unwind2StoryboardExample:(UIStoryboardSegue *)segue
{
    CalendarConfigViewController *config = segue.sourceViewController;
    self.lunar = config.lunar;
    self.theme = config.theme;
    [self.calendar selectDate:config.selectedDate scrollToDate:NO];
    
    if (self.calendar.firstWeekday != config.firstWeekday) {
        self.calendar.firstWeekday = config.firstWeekday;
    }
    
    if (self.calendar.scrollDirection != config.scrollDirection) {
        self.calendar.scrollDirection = config.scrollDirection;
        [[[UIAlertView alloc] initWithTitle:@"FSCalendar"
                                    message:[NSString stringWithFormat:@"Now swipe %@",@[@"Vertically", @"Horizontally"][self.calendar.scrollDirection]]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    }
}


#pragma mark - Private properties

- (void)setTheme:(NSInteger)theme
{
    if (_theme != theme) {
        _theme = theme;
        switch (theme) {
            case 0: {
                _calendar.appearance.weekdayTextColor = FSCalendarStandardTitleTextColor;
                _calendar.appearance.headerTitleColor = FSCalendarStandardTitleTextColor;
                _calendar.appearance.eventDefaultColor = FSCalendarStandardEventDotColor;
                _calendar.appearance.selectionColor = FSCalendarStandardSelectionColor;
                _calendar.appearance.headerDateFormat = @"MMMM yyyy";
                _calendar.appearance.todayColor = FSCalendarStandardTodayColor;
                _calendar.appearance.borderRadius = 1.0;
                _calendar.appearance.headerMinimumDissolvedAlpha = 0.2;
                break;
            }
            case 1: {
                _calendar.appearance.weekdayTextColor = [UIColor redColor];
                _calendar.appearance.headerTitleColor = [UIColor darkGrayColor];
                _calendar.appearance.eventDefaultColor = [UIColor greenColor];
                _calendar.appearance.selectionColor = [UIColor blueColor];
                _calendar.appearance.headerDateFormat = @"yyyy-MM";
                _calendar.appearance.todayColor = [UIColor redColor];
                _calendar.appearance.borderRadius = 1.0;
                _calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
                
                break;
            }
            case 2: {
                _calendar.appearance.weekdayTextColor = [UIColor redColor];
                _calendar.appearance.headerTitleColor = [UIColor redColor];
                _calendar.appearance.eventDefaultColor = [UIColor greenColor];
                _calendar.appearance.selectionColor = [UIColor blueColor];
                _calendar.appearance.headerDateFormat = @"yyyy/MM";
                _calendar.appearance.todayColor = [UIColor orangeColor];
                _calendar.appearance.borderRadius = 0;
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

@end

