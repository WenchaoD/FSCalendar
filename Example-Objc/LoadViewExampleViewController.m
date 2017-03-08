//
//  LoadViewExampleViewController.m
//  FSCalendar
//
//  Created by DingWenchao on 6/25/15.
//  Copyright (c) 2016 Wenchao Ding. All rights reserved.
//

#import "LoadViewExampleViewController.h"
#import "FSCalendar.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoadViewExampleViewController()<FSCalendarDataSource,FSCalendarDelegate>

@property (weak, nonatomic) FSCalendar *calendar;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDictionary<NSString *, UIImage *> *images;

@end

NS_ASSUME_NONNULL_END

@implementation LoadViewExampleViewController

#pragma mark - Life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"FSCalendar";
        self.images = @{@"2016/11/01":[UIImage imageNamed:@"icon_cat"],
                        @"2016/11/05":[UIImage imageNamed:@"icon_footprint"],
                        @"2016/11/20":[UIImage imageNamed:@"icon_cat"],
                        @"2016/11/07":[UIImage imageNamed:@"icon_footprint"]};
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = view;
    
    // 450 for iPad and 300 for iPhone
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 450 : 300;
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), view.frame.size.width, height)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.scrollDirection = FSCalendarScrollDirectionVertical;
    calendar.backgroundColor = [UIColor whiteColor];
    
    [view addSubview:calendar];
    self.calendar = calendar;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy/MM/dd";
    
    
    // [self.calendar selectDate:[self.dateFormatter dateFromString:@"2016/02/03"]];

    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.calendar setScope:FSCalendarScopeWeek animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.calendar setScope:FSCalendarScopeMonth animated:YES];
        });
    });
     */
    
    
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - <FSCalendarDelegate>

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    NSLog(@"should select date %@",[self.dateFormatter stringFromDate:date]);
    return YES;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    NSLog(@"did select date %@",[self.dateFormatter stringFromDate:date]);
    if (monthPosition == FSCalendarMonthPositionNext || monthPosition == FSCalendarMonthPositionPrevious) {
        [calendar setCurrentPage:date animated:YES];
    }
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
    NSLog(@"did change to page %@",[self.dateFormatter stringFromDate:calendar.currentPage]);
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
}

#pragma mark - <FSCalendarDataSource>


- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    return [self.dateFormatter dateFromString:@"2016/10/01"];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    return [self.dateFormatter dateFromString:@"2017/10/10"];
}


- (UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date
{
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    return self.images[dateString];
}

@end
