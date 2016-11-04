//
//  ScopeHandleViewController.m
//  FSCalendar
//
//  Created by dingwenchao on 5/8/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "DIVExampleViewController.h"
#import "DIVCalendarCell.h"

@interface DIVExampleViewController () <FSCalendarDataSource,FSCalendarDelegate>

@property (weak, nonatomic) FSCalendar *calendar;

@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation DIVExampleViewController

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
    
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 450 : 300;
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0,  CGRectGetMaxY(self.navigationController.navigationBar.frame), view.frame.size.width, height)];
    calendar.dataSource = self;
    calendar.delegate = self;
//    calendar.showsPlaceholders = NO;
    calendar.scopeGesture.enabled = YES;
    calendar.backgroundColor = [UIColor whiteColor];
    [view addSubview:calendar];
    self.calendar = calendar;
    
    calendar.calendarHeaderView.backgroundColor = [UIColor orangeColor];
    calendar.calendarWeekdayView.backgroundColor = [UIColor orangeColor];
    
    calendar.appearance.todayColor = nil;
    
    [calendar registerClass:[DIVCalendarCell class] forCellReuseIdentifier:@"cell"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    [self.calendar selectDate:[self.gregorian dateByAddingUnit:NSCalendarUnitDay value:1 toDate:[NSDate date] options:0]];

    // Uncomment this to perform an 'initial-week-scope'
    // self.calendar.scope = FSCalendarScopeWeek;
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

- (FSCalendarCell *)calendar:(FSCalendar *)calendar cellForDate:(NSDate *)date
{
    DIVCalendarCell *cell = [calendar dequeueReusableCellWithIdentifier:@"cell" forDate:date];
    NSLog(@"%d",cell.isPlaceholder);
    return cell;
}

- (void)calendar:(FSCalendar *)calendar willDisplayCell:(FSCalendarCell *)cell forDate:(NSDate *)date
{
    DIVCalendarCell *divCell = (DIVCalendarCell *)cell;
    if (divCell.isPlaceholder) {
        divCell.divImageView.hidden = YES;
    } else {
        divCell.divImageView.hidden = ![self.gregorian isDateInToday:date];
    }
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
