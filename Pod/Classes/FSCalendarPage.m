//
//  FSCalendarViewPage.m
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import "FSCalendarPage.h"
#import "FSCalendarUnit.h"
#import "NSDate+FSExtension.h"
#import "UIView+FSExtension.h"
#import "FSCalendar.h"

@interface FSCalendarPage ()

@property (readonly, nonatomic) FSCalendar *calendarView;

@end

@implementation FSCalendarPage

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        for (int i = 0; i < 42; i++) {
            FSCalendarUnit *unit = [[FSCalendarUnit alloc] initWithFrame:CGRectZero];
            [self addSubview:unit];
        }
    }
    return self;
}

- (void)setDate:(NSDate *)date
{
    if (![_date isEqualToDate:date]) {
        _date = [date copy];
    }
    [self updateDateForUnits];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat inset = self.fs_height/80;
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSInteger row = idx / 7;
        CGFloat width = self.fs_width/7;
        CGFloat height = (self.fs_height-inset*2)/6;
        CGFloat top = inset+row * height;
        CGFloat left = (idx % 7)*width;
        [obj setFrame:CGRectMake(left, top, width, height)];
    }];
}

- (void)updateDateForUnits
{
    NSMutableArray *dates = [NSMutableArray arrayWithCapacity:42];
    for (int i = 0; i < _date.fs_numberOfDaysInMonth; i++) {
        [dates addObject:[NSDate fs_dateWithYear:_date.fs_year month:_date.fs_month day:i+1]];
    }
    NSInteger numberOfPlaceholders = 42 - dates.count;
    NSInteger numberOfPlaceholdersForPrev = [dates[0] fs_weekday]-1 ? : 7;
    for (int i = 0; i < numberOfPlaceholdersForPrev; i++) {
        [dates insertObject:[dates[0] fs_dateBySubtractingDays:1] atIndex:0];
    }
    for (int i = 0; i < numberOfPlaceholders-numberOfPlaceholdersForPrev; i++) {
        [dates addObject:[dates.lastObject fs_dateByAddingDays:1]];
    }
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDate *date = dates[idx];
        [obj setDate: date];
        [obj setTag: date.fs_year*10000 + date.fs_month*100 + date.fs_day*100];
    }];
}

- (FSCalendarUnit *)unitForDate:(NSDate *)date
{
    NSInteger tag = date.fs_year*10000 + date.fs_month*100 + date.fs_day*100;
    return (FSCalendarUnit *)[self viewWithTag:tag];
}

- (FSCalendar *)calendarView
{
    return (FSCalendar *)self.superview.superview;
}


@end
