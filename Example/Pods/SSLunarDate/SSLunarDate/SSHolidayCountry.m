//
//  SSHolidayCountry.m
//  SSLunarDate
//
//  Created by Jiejing Zhang on 13-8-25.
//  Copyright (c) 2013年 Jiejing Zhang. All rights reserved.
//

#import "SSHolidayCountry.h"
#import "SSLunarDate.h"
#import "SSLunarDateHoliday.h"

@interface SSHolidayCountry () 
{
    SSHolidayRegion     _region;
    NSCalendar          *_calendar;
    SSHolidayWest       *_west;
}
@end

@implementation SSHolidayCountry

@synthesize calendar, region;

- (id) initWithRegion:(SSHolidayRegion) reg
{
    self = [super init];
    if (self) {
        _region = reg;
        _calendar = [NSCalendar currentCalendar];
    }
    return self;
}

- (NSCalendar *) calendar {
    if (_calendar == nil)
        _calendar = [NSCalendar currentCalendar];
    return _calendar;
}

- (NSArray *) getHolidayListForDate:(NSDate *)date
{
    NSAssert(false, @"NSHolidayCountry dummy function called");
    return [NSArray array];
}

+ (NSArray *) getHolidayListFromTable:(NSDate *)date
                             calendar:(NSCalendar *)cal
                                 dict:(NSDictionary *) dict
{
    NSString *index;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    unsigned int flags = NSYearCalendarUnit
        | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *parts = [cal components:flags fromDate:date];
    index = [SSLunarDateHoliday convertIndexFrom:parts.month day:parts.day];

    NSString *holiday = [dict objectForKey:index];
    if (holiday)
        [result addObject:holiday];
    return result;
}

-(NSString *) convertDateIndex:(NSDate *)date
{
    NSDateComponents *c = [self.calendar components: NSDayCalendarUnit | NSMonthCalendarUnit fromDate:date];
    return [SSLunarDateHoliday convertIndexFrom:c.month day:c.day];
}

- (SSHolidayWest *) west
{
    if (_west == nil) 
        _west = [[SSHolidayWest alloc] initWithCalendar:self.calendar];
    return _west;
}

@end
