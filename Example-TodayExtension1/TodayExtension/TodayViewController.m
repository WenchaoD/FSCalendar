//
//  TodayViewController.m
//  Example-TodayExtension
//
//  Created by dingwenchao on 9/6/16.
//  Copyright © 2016 dingwenchao. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "FSCalendar.h"

@interface TodayViewController () <NCWidgetProviding,FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>

@property (weak  , nonatomic) IBOutlet FSCalendar *calendar;
@property (weak  , nonatomic) IBOutlet UIButton *prevButton;
@property (weak  , nonatomic) IBOutlet UIButton *nextButton;
@property (weak  , nonatomic) IBOutlet NSLayoutConstraint *calendarHeight;

@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSCalendar *lunarCalendar;
@property (strong, nonatomic) NSArray<NSString *> *lunarChars;

@end

@implementation TodayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.calendar.today = nil;
    self.calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
    self.lunarCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    self.lunarCalendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
    self.lunarChars = @[@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",@"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",@"二一",@"二二",@"二三",@"二四",@"二五",@"二六",@"二七",@"二八",@"二九",@"三十"];
    self.gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    
    if ([self.extensionContext respondsToSelector:@selector(setWidgetLargestAvailableDisplayMode:)]) {
        self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
    } else {
        self.preferredContentSize = CGSizeMake(320, self.calendarHeight.constant);
    }
    
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize
{
    if (activeDisplayMode == NCWidgetDisplayModeCompact) {
        [self.calendar setScope:FSCalendarScopeWeek animated:YES];
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0;
        self.prevButton.hidden = NO;
        self.nextButton.hidden = NO;
    } else if (activeDisplayMode == NCWidgetDisplayModeExpanded) {
        [self.calendar setScope:FSCalendarScopeMonth animated:YES];
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.5;
        self.prevButton.hidden = YES;
        self.nextButton.hidden = YES;
    }
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler
{
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsZero;
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    self.calendarHeight.constant = CGRectGetHeight(bounds);
    self.preferredContentSize = CGSizeMake(320, self.calendarHeight.constant);
    [self.view layoutIfNeeded];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date
{
    return [self.gregorian isDateInToday:date] ? appearance.todayColor : nil;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date
{
    return [UIColor clearColor];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date
{
    return appearance.selectionColor;
}

- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date
{
    NSInteger day = [_lunarCalendar components:NSCalendarUnitDay fromDate:date].day;
    return _lunarChars[day-1];
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    if (monthPosition != FSCalendarMonthPositionCurrent) {
        [calendar setCurrentPage:date animated:YES];
    }
}

@end
