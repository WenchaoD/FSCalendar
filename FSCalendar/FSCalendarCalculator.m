//
//  FSCalendarCalculator.m
//  FSCalendar
//
//  Created by dingwenchao on 30/10/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendar.h"
#import "FSCalendarCalculator.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarExtensions.h"

@interface FSCalendarCalculator ()

@property (assign, nonatomic) NSInteger numberOfMonths;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSDate *> *months;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSDate *> *monthHeads;

@property (assign, nonatomic) NSInteger numberOfWeeks;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSDate *> *weeks;
@property (strong, nonatomic) NSMutableDictionary<NSDate *, NSNumber *> *rowCounts;

@property (readonly, nonatomic) NSCalendar *gregorian;
@property (readonly, nonatomic) NSDate *minimumDate;
@property (readonly, nonatomic) NSDate *maximumDate;

- (void)didReceiveNotifications:(NSNotification *)notification;

@end

@implementation FSCalendarCalculator

@dynamic gregorian,minimumDate,maximumDate;

- (instancetype)initWithCalendar:(FSCalendar *)calendar
{
    self = [super init];
    if (self) {
        self.calendar = calendar;
        
        self.months = [NSMutableDictionary dictionary];
        self.monthHeads = [NSMutableDictionary dictionary];
        self.weeks = [NSMutableDictionary dictionary];
        self.rowCounts = [NSMutableDictionary dictionary];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotifications:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (id)forwardingTargetForSelector:(SEL)selector
{
    if ([self.calendar respondsToSelector:selector]) {
        return self.calendar;
    }
    return [super forwardingTargetForSelector:selector];
}

#pragma mark - Public functions

- (NSDate *)safeDateForDate:(NSDate *)date
{
    if ([self.gregorian compareDate:date toDate:self.minimumDate toUnitGranularity:NSCalendarUnitDay] == NSOrderedAscending) {
        date = self.minimumDate;
    } else if ([self.gregorian compareDate:date toDate:self.maximumDate toUnitGranularity:NSCalendarUnitDay] == NSOrderedDescending) {
        date = self.maximumDate;
    }
    return date;
}

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath scope:(FSCalendarScope)scope
{
    if (!indexPath) return nil;
    switch (scope) {
        case FSCalendarScopeMonth: {
            NSDate *head = [self monthHeadForSection:indexPath.section];
            NSUInteger daysOffset = indexPath.item;
            NSDate *date = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:daysOffset toDate:head options:0];
            return date;
            break;
        }
        case FSCalendarScopeWeek: {
            NSDate *currentPage = [self weekForSection:indexPath.section];
            NSDate *date = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:indexPath.item toDate:currentPage options:0];
            return date;
        }
    }
    return nil;
}

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) return nil;
    return [self dateForIndexPath:indexPath scope:self.calendar.transitionCoordinator.representingScope];
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date
{
    return [self indexPathForDate:date atMonthPosition:FSCalendarMonthPositionCurrent scope:self.calendar.transitionCoordinator.representingScope];
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date scope:(FSCalendarScope)scope
{
    return [self indexPathForDate:date atMonthPosition:FSCalendarMonthPositionCurrent scope:scope];
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position scope:(FSCalendarScope)scope
{
    if (!date) return nil;
    NSInteger item = 0;
    NSInteger section = 0;
    switch (scope) {
        case FSCalendarScopeMonth: {
            section = [self.gregorian components:NSCalendarUnitMonth fromDate:[self.gregorian fs_firstDayOfMonth:self.minimumDate] toDate:[self.gregorian fs_firstDayOfMonth:date] options:0].month;
            if (position == FSCalendarMonthPositionPrevious) {
                section++;
            } else if (position == FSCalendarMonthPositionNext) {
                section--;
            }
            NSDate *head = [self monthHeadForSection:section];
            item = [self.gregorian components:NSCalendarUnitDay fromDate:head toDate:date options:0].day;
            break;
        }
        case FSCalendarScopeWeek: {
            section = [self.gregorian components:NSCalendarUnitWeekOfYear fromDate:[self.gregorian fs_firstDayOfWeek:self.minimumDate] toDate:[self.gregorian fs_firstDayOfWeek:date] options:0].weekOfYear;
            item = (([self.gregorian component:NSCalendarUnitWeekday fromDate:date] - self.gregorian.firstWeekday) + 7) % 7;
            break;
        }
    }
    if (item < 0 || section < 0) {
        return nil;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
    return indexPath;
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position
{
    return [self indexPathForDate:date atMonthPosition:position scope:self.calendar.transitionCoordinator.representingScope];
}

- (NSDate *)pageForSection:(NSInteger)section
{
    switch (self.calendar.transitionCoordinator.representingScope) {
        case FSCalendarScopeWeek:
            return [self.gregorian fs_middleDayOfWeek:[self weekForSection:section]];
        case FSCalendarScopeMonth:
            return [self monthForSection:section];
        default:
            break;
    }
}

- (NSDate *)monthForSection:(NSInteger)section
{
    NSNumber *key = @(section);
    NSDate *month = self.months[key];
    if (!month) {
        month = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:section toDate:[self.gregorian fs_firstDayOfMonth:self.minimumDate] options:0];
        NSInteger numberOfHeadPlaceholders = [self numberOfHeadPlaceholdersForMonth:month];
        NSDate *monthHead = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:-numberOfHeadPlaceholders toDate:month options:0];
        self.months[key] = month;
        self.monthHeads[key] = monthHead;
    }
    return month;
}

- (NSDate *)monthHeadForSection:(NSInteger)section
{
    NSNumber *key = @(section);
    NSDate *monthHead = self.monthHeads[key];
    if (!monthHead) {
        NSDate *month = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:section toDate:[self.gregorian fs_firstDayOfMonth:self.minimumDate] options:0];
        NSInteger numberOfHeadPlaceholders = [self numberOfHeadPlaceholdersForMonth:month];
        monthHead = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:-numberOfHeadPlaceholders toDate:month options:0];
        self.months[key] = month;
        self.monthHeads[key] = monthHead;
    }
    return monthHead;
}

- (NSDate *)weekForSection:(NSInteger)section
{
    NSNumber *key = @(section);
    NSDate *week = self.weeks[key];
    if (!week) {
        week = [self.gregorian dateByAddingUnit:NSCalendarUnitWeekOfYear value:section toDate:[self.gregorian fs_firstDayOfWeek:self.minimumDate] options:0];
        self.weeks[key] = week;
    }
    return week;
}

- (NSInteger)numberOfSections
{
    switch (self.calendar.transitionCoordinator.representingScope) {
        case FSCalendarScopeMonth: {
            return self.numberOfMonths;
        }
        case FSCalendarScopeWeek: {
            return self.numberOfWeeks;
        }
    }
}

- (NSInteger)numberOfHeadPlaceholdersForMonth:(NSDate *)month
{
    NSInteger currentWeekday = [self.gregorian component:NSCalendarUnitWeekday fromDate:month];
    NSInteger number = ((currentWeekday- self.gregorian.firstWeekday) + 7) % 7 ?: (7 * (!self.calendar.floatingMode&&(self.calendar.placeholderType == FSCalendarPlaceholderTypeFillSixRows)));
    return number;
}

- (NSInteger)numberOfRowsInMonth:(NSDate *)month
{
    if (!month) return 0;
    if (self.calendar.placeholderType == FSCalendarPlaceholderTypeFillSixRows) return 6;
    
    NSNumber *rowCount = self.rowCounts[month];
    if (rowCount == nil) {
        NSDate *firstDayOfMonth = [self.gregorian fs_firstDayOfMonth:month];
        NSInteger weekdayOfFirstDay = [self.gregorian component:NSCalendarUnitWeekday fromDate:firstDayOfMonth];
        NSInteger numberOfDaysInMonth = [self.gregorian fs_numberOfDaysInMonth:month];
        NSInteger numberOfPlaceholdersForPrev = ((weekdayOfFirstDay - self.gregorian.firstWeekday) + 7) % 7;
        NSInteger headDayCount = numberOfDaysInMonth + numberOfPlaceholdersForPrev;
        NSInteger numberOfRows = (headDayCount/7) + (headDayCount%7>0);
        rowCount = @(numberOfRows);
        self.rowCounts[month] = rowCount;
    }
    return rowCount.integerValue;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    if (self.calendar.transitionCoordinator.representingScope == FSCalendarScopeWeek) return 1;
    NSDate *month = [self monthForSection:section];
    return [self numberOfRowsInMonth:month];
}

- (FSCalendarMonthPosition)monthPositionForIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) return FSCalendarMonthPositionNotFound;
    if (self.calendar.transitionCoordinator.representingScope == FSCalendarScopeWeek) {
        return FSCalendarMonthPositionCurrent;
    }
    NSDate *date = [self dateForIndexPath:indexPath];
    NSDate *page = [self pageForSection:indexPath.section];
    NSComparisonResult comparison = [self.gregorian compareDate:date toDate:page toUnitGranularity:NSCalendarUnitMonth];
    switch (comparison) {
        case NSOrderedAscending:
            return FSCalendarMonthPositionPrevious;
        case NSOrderedSame:
            return FSCalendarMonthPositionCurrent;
        case NSOrderedDescending:
            return FSCalendarMonthPositionNext;
    }
}

- (FSCalendarCoordinate)coordinateForIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCoordinate coordinate;
    coordinate.row = indexPath.item / 7;
    coordinate.column = indexPath.item % 7;
    return coordinate;
}

- (void)reloadSections
{
    self.numberOfMonths = [self.gregorian components:NSCalendarUnitMonth fromDate:[self.gregorian fs_firstDayOfMonth:self.minimumDate] toDate:self.maximumDate options:0].month+1;
    self.numberOfWeeks = [self.gregorian components:NSCalendarUnitWeekOfYear fromDate:[self.gregorian fs_firstDayOfWeek:self.minimumDate] toDate:self.maximumDate options:0].weekOfYear+1;
    [self clearCaches];
}

- (void)clearCaches
{
    [self.months removeAllObjects];
    [self.monthHeads removeAllObjects];
    [self.weeks removeAllObjects];
    [self.rowCounts removeAllObjects];
}

#pragma mark - Private functinos

- (void)didReceiveNotifications:(NSNotification *)notification
{
    if ([notification.name isEqualToString:UIApplicationDidReceiveMemoryWarningNotification]) {
        [self clearCaches];
    }
}

@end
