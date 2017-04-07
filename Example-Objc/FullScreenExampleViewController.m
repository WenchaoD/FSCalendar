//
//  FullScreenExample.m
//  FSCalendar
//
//  Created by Wenchao Ding on 9/16/15.
//  Copyright (c) 2015 Wenchao Ding. All rights reserved.
//

#import "FullScreenExampleViewController.h"
#import <EventKit/EventKit.h>

#import "FSCalendar.h"

NS_ASSUME_NONNULL_BEGIN

@interface FullScreenExampleViewController()<FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>

@property (weak, nonatomic) FSCalendar *calendar;

@property (assign, nonatomic) BOOL showsLunar;
@property (assign, nonatomic) BOOL showsEvents;

@property (strong, nonatomic) NSCache *cache;

- (void)todayItemClicked:(id)sender;
- (void)lunarItemClicked:(id)sender;
- (void)eventItemClicked:(id)sender;

@property (strong, nonatomic) NSCalendar *lunarCalendar;
@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) NSDate *minimumDate;
@property (strong, nonatomic) NSDate *maximumDate;

@property (strong, nonatomic) NSArray<NSString *> *lunarChars;
@property (strong, nonatomic) NSArray<EKEvent *> *events;

- (void)loadCalendarEvents;
- (nullable NSArray<EKEvent *> *)eventsForDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END

@implementation FullScreenExampleViewController

#pragma mark - Life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"FSCalendar";
        _lunarCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
        _lunarCalendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
        _lunarChars = @[@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",@"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",@"二一",@"二二",@"二三",@"二四",@"二五",@"二六",@"二七",@"二八",@"二九",@"三十"];
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    self.view = view;
    
#define FULL_SCREEN 1
    
#if FULL_SCREEN
    
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-self.navigationController.navigationBar.frame.size.height)];
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.pagingEnabled = NO; // important
    calendar.allowsMultipleSelection = YES;
    calendar.firstWeekday = 2;
    calendar.placeholderType = FSCalendarPlaceholderTypeFillHeadTail;
    calendar.appearance.caseOptions = FSCalendarCaseOptionsWeekdayUsesSingleUpperCase|FSCalendarCaseOptionsHeaderUsesUpperCase;
    [self.view addSubview:calendar];
    self.calendar = calendar;
    
#else

    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 300)];
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.allowsMultipleSelection = YES;
    calendar.firstWeekday = 2;
    calendar.appearance.caseOptions = FSCalendarCaseOptionsWeekdayUsesSingleUpperCase|FSCalendarCaseOptionsHeaderUsesUpperCase;
    [self.view addSubview:calendar];
    self.calendar = calendar;
    
#endif
    
    UIBarButtonItem *todayItem = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStylePlain target:self action:@selector(todayItemClicked:)];
    
    UIBarButtonItem *lunarItem = [[UIBarButtonItem alloc] initWithTitle:@"Lunar" style:UIBarButtonItemStylePlain target:self action:@selector(lunarItemClicked:)];
    [lunarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor magentaColor]} forState:UIControlStateNormal];
    
    UIBarButtonItem *eventItem = [[UIBarButtonItem alloc] initWithTitle:@"Event" style:UIBarButtonItemStylePlain target:self action:@selector(eventItemClicked:)];
    [eventItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor purpleColor]} forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItems = @[eventItem ,lunarItem, todayItem];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    self.minimumDate = [self.dateFormatter dateFromString:@"2016-02-03"];
    self.maximumDate = [self.dateFormatter dateFromString:@"2018-04-10"];

    self.calendar.accessibilityIdentifier = @"calendar";
    
    [self loadCalendarEvents];
    
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.minimumDate = [self.dateFormatter dateFromString:@"2015-02-01"];
        self.maximumDate = [self.dateFormatter dateFromString:@"2015-06-10"];
        [self.calendar reloadData];
    });
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.cache removeAllObjects];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
#if FULL_SCREEN
    self.calendar.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.bounds.size.width, self.view.bounds.size.height-CGRectGetMaxY(self.navigationController.navigationBar.frame));
#else
    self.calendar.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.bounds.size.width, 300);
#endif
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - Target actions

- (void)todayItemClicked:(id)sender
{
    [self.calendar setCurrentPage:[NSDate date] animated:YES];
}

- (void)lunarItemClicked:(UIBarButtonItem *)item
{
    self.showsLunar = !self.showsLunar;
    [self.calendar reloadData];
}

- (void)eventItemClicked:(id)sender
{
    self.showsEvents = !self.showsEvents;
    [self.calendar reloadData];
}

#pragma mark - FSCalendarDataSource

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    return self.minimumDate;
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    return self.maximumDate;
}

- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date
{
    if (_showsEvents) {
        EKEvent *event = [self eventsForDate:date].firstObject;
        if (event) {
            return event.title;
        }
    }
    if (_showsLunar) {
        NSInteger day = [_lunarCalendar component:NSCalendarUnitDay fromDate:date];
        return _lunarChars[day-1];
    }
    return nil;
}

#pragma mark - FSCalendarDelegate

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    NSLog(@"did select %@",[self.dateFormatter stringFromDate:date]);
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
    NSLog(@"did change page %@",[self.dateFormatter stringFromDate:calendar.currentPage]);
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    if (!self.showsEvents) return 0;
    if (!self.events) return 0;
    NSArray<EKEvent *> *events = [self eventsForDate:date];
    return events.count;
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date
{
    if (!self.showsEvents) return nil;
    if (!self.events) return nil;
    NSArray<EKEvent *> *events = [self eventsForDate:date];
    NSMutableArray<UIColor *> *colors = [NSMutableArray arrayWithCapacity:events.count];
    [events enumerateObjectsUsingBlock:^(EKEvent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [colors addObject:[UIColor colorWithCGColor:obj.calendar.CGColor]];
    }];
    return colors.copy;
}

#pragma mark - Private methods

- (void)loadCalendarEvents
{
    __weak typeof(self) weakSelf = self;
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        
        if(granted) {
            NSDate *startDate = self.minimumDate;
            NSDate *endDate = self.maximumDate;
            NSPredicate *fetchCalendarEvents = [store predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
            NSArray<EKEvent *> *eventList = [store eventsMatchingPredicate:fetchCalendarEvents];
            NSArray<EKEvent *> *events = [eventList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(EKEvent * _Nullable event, NSDictionary<NSString *,id> * _Nullable bindings) {
                return event.calendar.subscribed;
            }]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!weakSelf) return;
                weakSelf.events = events;
                [weakSelf.calendar reloadData];
            });
            
        } else {
            
            // Alert
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Permission Error" message:@"Permission of calendar is required for fetching events." preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
    
}

- (NSArray<EKEvent *> *)eventsForDate:(NSDate *)date
{
    NSArray<EKEvent *> *events = [self.cache objectForKey:date];
    if ([events isKindOfClass:[NSNull class]]) {
        return nil;
    }
    NSArray<EKEvent *> *filteredEvents = [self.events filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(EKEvent * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject.occurrenceDate isEqualToDate:date];
    }]];
    if (filteredEvents.count) {
        [self.cache setObject:filteredEvents forKey:date];
    } else {
        [self.cache setObject:[NSNull null] forKey:date];
    }
    return filteredEvents;
}

@end
