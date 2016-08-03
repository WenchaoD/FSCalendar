//
//  HDReservationManagerVC.m
//  ihealth4d
//
//  Created by 洪东 on 5/24/16.
//  Copyright © 2016 abnerh. All rights reserved.
//

#import "HDReservationManagerVC.h"
#import "FSCalendar.h"

@interface HDReservationManagerVC ()<FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance>

@property (weak, nonatomic) IBOutlet UIView *calendarBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarHeightConstrtaint;
@property (nonatomic, strong) FSCalendar *calendar;

@property (strong, nonatomic) NSCalendar *lunarCalendar;
@property (strong, nonatomic) NSArray *lunarChars;

@end

@implementation HDReservationManagerVC
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _lunarCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    _lunarCalendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
    _lunarChars = @[@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",@"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"廿十",@"廿一",@"廿二",@"廿三",@"廿四",@"廿五",@"廿六",@"廿七",@"廿八",@"廿九",@"三十"];
    
    self.calendar = ({
        FSCalendar * calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, (330))];
        calendar.backgroundColor = [UIColor whiteColor];
        calendar.showsPlaceholders = NO;
        calendar.appearance.headerTitleFont=[UIFont boldSystemFontOfSize:20];
        calendar.appearance.weekdayFont=[UIFont boldSystemFontOfSize:16];
        calendar.appearance.eventColor = [UIColor greenColor];
        calendar.appearance.headerDateFormat = @"yyyy年M月";
        calendar.appearance.todayColor = nil;
        calendar.appearance.subtitleVerticalOffset=2.0;
        calendar.appearance.titleFont=[UIFont boldSystemFontOfSize:16];
        calendar.appearance.subtitleFont=[UIFont boldSystemFontOfSize:16];
        calendar.appearance.cellShape = FSCalendarCellShapeCircle;
        calendar.appearance.headerMinimumDissolvedAlpha = 0.2;
                calendar.dataSource = self;
                calendar.delegate = self;
                calendar.showsScopeHandle = YES;
                [self.view addSubview:calendar];
                calendar;});

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.calendar setScope:FSCalendarScopeWeek animated:YES];
}

#pragma mark - FSCalendarDataSource

- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date
{
    return [calendar isDateInToday:date] ? @"今天" : nil;
}
- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date{
    return [calendar isDateInToday:date] ? [UIColor redColor] : nil;
}

- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date
{
    if ([calendar isDateInToday:date]) {
        return nil;
    }
    NSInteger day = [_lunarCalendar components:NSCalendarUnitDay fromDate:date].day;
    return _lunarChars[day-1];
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
    NSLog(@"height=%f",calendar.frame.size.height);
    self.calendarHeightConstrtaint.constant=calendar.frame.size.height;
    
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"did select date %@",[calendar stringFromDate:date format:@"yyyy/MM/dd"]);
    CGRect frame = [self.calendar frameForDate:date];
    NSLog(@"%@",NSStringFromCGRect(frame));
    
    if (self.calendar.scope==FSCalendarScopeMonth) {
        [self.calendar setScope:FSCalendarScopeWeek animated:YES];
    }
}

@end
