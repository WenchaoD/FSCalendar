//
//  RollViewController.m
//  FSCalendar
//
//  Created by dingwenchao on 10/16/15.
//  Copyright (c) 2015 Wenchao Ding. All rights reserved.
//

#import "DelegateAppearanceViewController.h"

#define kViolet [UIColor colorWithRed:170/255.0 green:114/255.0 blue:219/255.0 alpha:1.0]

NS_ASSUME_NONNULL_BEGIN

@interface DelegateAppearanceViewController()<FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>

@property (weak, nonatomic) FSCalendar *calendar;

@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *dateFormatter1;
@property (strong, nonatomic) NSDateFormatter *dateFormatter2;

@property (strong, nonatomic) NSDictionary *fillSelectionColors;
@property (strong, nonatomic) NSDictionary *fillDefaultColors;
@property (strong, nonatomic) NSDictionary *borderDefaultColors;
@property (strong, nonatomic) NSDictionary *borderSelectionColors;

@property (strong, nonatomic) NSArray *datesWithEvent;
@property (strong, nonatomic) NSArray *datesWithMultipleEvents;

@end

NS_ASSUME_NONNULL_END

@implementation DelegateAppearanceViewController

#pragma mark - Life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"FSCalendar";
        
        self.fillDefaultColors = @{@"2015/10/08":[UIColor purpleColor],
                                     @"2015/10/06":[UIColor greenColor],
                                     @"2015/10/18":[UIColor cyanColor],
                                     @"2015/10/22":[UIColor yellowColor],
                                     @"2015/11/08":[UIColor purpleColor],
                                     @"2015/11/06":[UIColor greenColor],
                                     @"2015/11/18":[UIColor cyanColor],
                                     @"2015/11/22":[UIColor yellowColor],
                                     @"2015/12/08":[UIColor purpleColor],
                                     @"2015/12/06":[UIColor greenColor],
                                     @"2015/12/18":[UIColor cyanColor],
                                     @"2015/12/22":[UIColor magentaColor]};
        
        self.fillSelectionColors = @{@"2015/10/08":[UIColor greenColor],
                                 @"2015/10/06":[UIColor purpleColor],
                                 @"2015/10/17":[UIColor grayColor],
                                 @"2015/10/21":[UIColor cyanColor],
                                 @"2015/11/08":[UIColor greenColor],
                                 @"2015/11/06":[UIColor purpleColor],
                                 @"2015/11/17":[UIColor grayColor],
                                 @"2015/11/21":[UIColor cyanColor],
                                 @"2015/12/08":[UIColor greenColor],
                                 @"2015/12/06":[UIColor purpleColor],
                                 @"2015/12/17":[UIColor grayColor],
                                 @"2015/12/21":[UIColor cyanColor]};
        
        self.borderDefaultColors = @{@"2015/10/08":[UIColor brownColor],
                                     @"2015/10/17":[UIColor magentaColor],
                                     @"2015/10/21":FSCalendarStandardSelectionColor,
                                     @"2015/10/25":[UIColor blackColor],
                                     @"2015/11/08":[UIColor brownColor],
                                     @"2015/11/17":[UIColor magentaColor],
                                     @"2015/11/21":FSCalendarStandardSelectionColor,
                                     @"2015/11/25":[UIColor blackColor],
                                     @"2015/12/08":[UIColor brownColor],
                                     @"2015/12/17":[UIColor magentaColor],
                                     @"2015/12/21":FSCalendarStandardSelectionColor,
                                     @"2015/12/25":[UIColor blackColor]};
        
        self.borderSelectionColors = @{@"2015/10/08":[UIColor redColor],
                                       @"2015/10/17":[UIColor purpleColor],
                                       @"2015/10/21":FSCalendarStandardSelectionColor,
                                       @"2015/10/25":FSCalendarStandardTodayColor,
                                       @"2015/11/08":[UIColor redColor],
                                       @"2015/11/17":[UIColor purpleColor],
                                       @"2015/11/21":FSCalendarStandardSelectionColor,
                                       @"2015/11/25":FSCalendarStandardTodayColor,
                                       @"2015/12/08":[UIColor redColor],
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
        
        
        self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        
        self.dateFormatter1 = [[NSDateFormatter alloc] init];
        self.dateFormatter1.dateFormat = @"yyyy/MM/dd";
        
        self.dateFormatter2 = [[NSDateFormatter alloc] init];
        self.dateFormatter2.dateFormat = @"yyyy-MM-dd";
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
    calendar.swipeToChooseGesture.enabled = YES;
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesUpperCase|FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    [self.view addSubview:calendar];
    self.calendar = calendar;
    
    [calendar setCurrentPage:[self.dateFormatter1 dateFromString:@"2015/10/03"] animated:NO];
    
    UIBarButtonItem *todayItem = [[UIBarButtonItem alloc] initWithTitle:@"TODAY" style:UIBarButtonItemStylePlain target:self action:@selector(todayItemClicked:)];
    self.navigationItem.rightBarButtonItem = todayItem;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // For UITest
    self.calendar.accessibilityIdentifier = @"calendar";
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - Target actions

- (void)todayItemClicked:(id)sender
{
    [_calendar setCurrentPage:[NSDate date] animated:NO];
}

#pragma mark - <FSCalendarDataSource>

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    NSString *dateString = [self.dateFormatter2 stringFromDate:date];
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
    NSString *dateString = [self.dateFormatter2 stringFromDate:date];
    if ([_datesWithEvent containsObject:dateString]) {
        return [UIColor purpleColor];
    }
    return nil;
}

- (NSArray *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date
{
    NSString *dateString = [self.dateFormatter2 stringFromDate:date];
    if ([_datesWithMultipleEvents containsObject:dateString]) {
        return @[[UIColor magentaColor],appearance.eventDefaultColor,[UIColor blackColor]];
    }
    return nil;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date
{
    NSString *key = [self.dateFormatter1 stringFromDate:date];
    if ([_fillSelectionColors.allKeys containsObject:key]) {
        return _fillSelectionColors[key];
    }
    return appearance.selectionColor;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillDefaultColorForDate:(NSDate *)date
{
    NSString *key = [self.dateFormatter1 stringFromDate:date];
    if ([_fillDefaultColors.allKeys containsObject:key]) {
        return _fillDefaultColors[key];
    }
    return nil;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date
{
    NSString *key = [self.dateFormatter1 stringFromDate:date];
    if ([_borderDefaultColors.allKeys containsObject:key]) {
        return _borderDefaultColors[key];
    }
    return appearance.borderDefaultColor;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date
{
    NSString *key = [self.dateFormatter1 stringFromDate:date];
    if ([_borderSelectionColors.allKeys containsObject:key]) {
        return _borderSelectionColors[key];
    }
    return appearance.borderSelectionColor;
}

- (CGFloat)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderRadiusForDate:(nonnull NSDate *)date
{
    if ([@[@8,@17,@21,@25] containsObject:@([self.gregorian component:NSCalendarUnitDay fromDate:date])]) {
        return 0.0;
    }
    return 1.0;
}

@end
