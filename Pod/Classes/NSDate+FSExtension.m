//
//  NSDate+FSExtension.m
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import "NSDate+FSExtension.h"
#import "NSCalendar+FSExtension.h"

@implementation NSDate (FSExtension)

- (NSInteger)fs_year
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *component = [calendar components:NSYearCalendarUnit fromDate:self];
    return component.year;
}

- (NSInteger)fs_month
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *component = [calendar components:NSMonthCalendarUnit
                                              fromDate:self];
    return component.month;
}

- (NSInteger)fs_day
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *component = [calendar components:NSDayCalendarUnit
                                              fromDate:self];
    return component.day;
}

- (NSInteger)fs_weekday
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *component = [calendar components:NSWeekdayCalendarUnit fromDate:self];
    return component.weekday;
}

- (NSInteger)fs_hour
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *component = [calendar components:NSHourCalendarUnit
                                              fromDate:self];
    return component.hour;
}

- (NSInteger)fs_minute
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *component = [calendar components:NSMinuteCalendarUnit
                                              fromDate:self];
    return component.minute;
}

- (NSInteger)fs_second
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *component = [calendar components:NSSecondCalendarUnit
                                              fromDate:self];
    return component.second;
}

- (NSInteger)fs_numberOfDaysInMonth
{
    NSCalendar *c = [NSCalendar fs_sharedCalendar];
    NSRange days = [c rangeOfUnit:NSDayCalendarUnit
                           inUnit:NSMonthCalendarUnit
                          forDate:self];
    return days.length;
}

- (NSInteger) fs_lastDayForTheMonth{
    NSCalendar* cal = [NSCalendar fs_sharedCalendar];
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setMonth:self.fs_month];
    NSRange range = [cal rangeOfUnit:NSCalendarUnitDay
                              inUnit:NSCalendarUnitMonth
                             forDate:[cal dateFromComponents:comps]];
    return range.length;
}


- (NSDate *) fs_dateElement{
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents * selfComponents = [calendar components:unitFlags fromDate:self];
    return [calendar dateFromComponents:selfComponents];
}

- (NSDate *) fs_timeElement{
    unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit | NSTimeZoneCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents * selfComponents = [calendar components:unitFlags fromDate:self];
    return [calendar dateFromComponents:selfComponents];
}


- (NSString *)fs_stringWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

- (NSDate *)fs_dateByAddingMonths:(NSInteger)months
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:months];
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)fs_dateBySubtractingMonths:(NSInteger)months
{
    return [self fs_dateByAddingMonths:-months];
}

- (NSDate *)fs_dateByAddingDays:(NSInteger)days
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:days];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)fs_dateBySubtractingDays:(NSInteger)days
{
    return [self fs_dateByAddingDays:-days];
}

- (NSInteger)fs_yearsFrom:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit
                                               fromDate:date
                                                 toDate:self
                                                options:0];
    return components.year;
}

- (NSInteger)fs_monthsFrom:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [calendar components: NSMonthCalendarUnit
                                               fromDate:date
                                                 toDate:self
                                                    options:0];
    return components.month;
}

- (NSInteger)fs_daysFrom:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [calendar components:NSDayCalendarUnit
                                               fromDate:date
                                                 toDate:self
                                                options:0];
    return components.day;
}

- (BOOL)fs_isEqualToDateForMonth:(NSDate *)date
{
    return self.fs_year == date.fs_year && self.fs_month == date.fs_month;
}

- (BOOL)fs_isEqualToDateForDay:(NSDate *)date
{
    return self.fs_year == date.fs_year && self.fs_month == date.fs_month && self.fs_day == date.fs_day;
}


+ (instancetype)fs_dateFromString:(NSString *)string format:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    return [formatter dateFromString:string];
}

+ (instancetype)fs_dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = year;
    components.month = month;
    components.day = day;
    return [calendar dateFromComponents:components];
}



- (NSDate *) fs_setDayOfDate: (NSInteger) day
{
    unsigned unitFlags = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSTimeZoneCalendarUnit);
    NSCalendar* calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents * selfComponents = [calendar components:unitFlags fromDate:self];
    [selfComponents setDay:day];
    return [calendar dateFromComponents:selfComponents];
}

- (NSDate *) fs_setMonthOfDate: (NSInteger) month
{
    unsigned unitFlags = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSTimeZoneCalendarUnit);
    NSCalendar* calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents * selfComponents = [calendar components:unitFlags fromDate:self];
    [selfComponents setMonth:month];
    return [calendar dateFromComponents:selfComponents];
}
- (NSDate *) fs_setYearOfDate: (NSInteger) year
{
    unsigned unitFlags = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSTimeZoneCalendarUnit);
    NSCalendar* calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents * selfComponents = [calendar components:unitFlags fromDate:self];
    [selfComponents setYear:year];
    return [calendar dateFromComponents:selfComponents];
}

- (BOOL) fs_isBetween: (NSDate *) earlierDate andDate: (NSDate *) laterDate{
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar fs_sharedCalendar];
    
    NSDateComponents * selfComponents = [calendar components:unitFlags fromDate:self];
    [calendar dateFromComponents:selfComponents];
    NSDate * selfDateComponents = [self fs_dateElement];
    NSDate * beginDateComponents = [earlierDate fs_dateElement];
    NSDate * endDateComponents = [laterDate fs_dateElement];
    
    if ([beginDateComponents compare:endDateComponents] == NSOrderedDescending){
        NSDate * temp = beginDateComponents;
        beginDateComponents = endDateComponents;
        endDateComponents = temp;
    }
    
    if ([selfDateComponents compare:beginDateComponents] == NSOrderedAscending)
        return NO;
    
    if ([selfDateComponents compare:endDateComponents] == NSOrderedDescending)
        return NO;
    
    return YES;
}

- (NSDate *)fs_clampDateToComponents:(NSUInteger)unitFlags
{
    NSCalendar* calendar = [NSCalendar fs_sharedCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:self];
    return [calendar dateFromComponents:components];
}

@end
