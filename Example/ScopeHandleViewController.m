//
//  ScopeHandleViewController.m
//  FSCalendar
//
//  Created by dingwenchao on 5/8/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "ScopeHandleViewController.h"

@interface ScopeHandleViewController () <FSCalendarDataSource,FSCalendarDelegate>

@property (weak, nonatomic) FSCalendar *calendar;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation ScopeHandleViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"FSCalendar";
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = view;
    
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 480 : 330;
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0,  CGRectGetMaxY(self.navigationController.navigationBar.frame), view.frame.size.width, height)];
    calendar.dataSource = self;
    calendar.delegate = self;
//    calendar.showsPlaceholders = NO;
    calendar.scopeGesture.enabled = YES;
    calendar.showsScopeHandle = YES; // important
    calendar.backgroundColor = [UIColor whiteColor];
    [view addSubview:calendar];
    self.calendar = calendar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    [self.calendar selectDate:[self.dateFormatter dateFromString:@"2016-05-10"]];
    
    // Uncomment this to perform an 'initial-week-scope'
    // self.calendar.scope = FSCalendarScopeWeek;
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"did select date %@",[self.dateFormatter stringFromDate:date]);
}

@end
