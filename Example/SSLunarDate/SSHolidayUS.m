//
//  SSHolidayUS.m
//  SSLunarDate
//
//  Created by Jiejing Zhang on 13-8-25.
//  Copyright (c) 2013年 Jiejing Zhang. All rights reserved.
//

#import "SSHolidayUS.h"
#import "SSLunarDateHoliday.h"
#import "SSHolidayWest.h"

@interface SSHolidayUS()
{
    NSDictionary        *_solarHolidayUS;
    NSDictionary        *_variableHoliday;
    int                 _cachedYear;
}

@property (readonly) NSDictionary *solarHolidayUS;
@property (readonly) NSDictionary *variableHoliday;

@end

@implementation SSHolidayUS

- (NSArray *) getHolidayListForDate:(NSDate *)date 
{
// 1. add table holiday
// 2. add selected wester holiday
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    [result addObjectsFromArray: [SSHolidayCountry  getHolidayListFromTable:date
                                                                 calendar:self.calendar
                                                                     dict:[self solarHolidayUS]]];
    
    NSDateComponents *c = [self.calendar components:NSYearCalendarUnit fromDate:date];
    
    if (_cachedYear != c.year) {
        _cachedYear = c.year;
        _variableHoliday = nil;
    }
    
    [result addObjectsFromArray:[SSHolidayCountry getHolidayListFromTable:date calendar:self.calendar dict:[self variableHoliday]]];
    return result;
}



-(NSDictionary *) variableHoliday {
    if (_variableHoliday == nil) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

        NSDate *d;

// FIXME: I really don't happy with these code, should be more table
// way, but I don't want setup a function pointer in Obj-c.

        d = [self.west getGoodFriday:_cachedYear];
        [dict setObject:HOLIDAY_GOOD_FRIDAY forKey:[self convertDateIndex:d]];

        d = [self.west getEaster:_cachedYear];
        [dict setObject:HOLIDAY_EASTER_DAY forKey:[self convertDateIndex:d]];
        
        d = [self.west getMartinLutherKingBirthday:_cachedYear];
        [dict setObject:HOLIDAY_MLK_BIRTHDAY  forKey:[self convertDateIndex:d]];
        d = [self.west getMemorialDay:_cachedYear];
        [dict setObject:HOLIDAY_MEM_DAY forKey:[self convertDateIndex:d]];
        d = [self.west getLaborDay:_cachedYear];
        [dict setObject:HOLIDAY_LABOR_DAY forKey:[self convertDateIndex:d]];

        d = [self.west getColumbusDay:_cachedYear];
        [dict setObject:HOLIDAY_COLUMBUS_DAY forKey:[self convertDateIndex:d]];

        d = [self.west getThanksGivingDay:_cachedYear];
        [dict setObject:HOLIDAY_THANKS_DAY forKey:[self convertDateIndex:d]];
        
        _variableHoliday = dict;
    }
    
    return _variableHoliday;
}


// 1. Third Monday in January, Birthday of Dr. Martin Luther King, Jr.
// 2. 2月的第三個星期一, Washington's Birthday/Presidents' Day
// 3. Last Monday in May	Memorial Day
// 4. First Monday in September Labor Day
// 5. Second Monday in October Columbus Day
// 6. 11月的第四個星期四 Thanksgiving Day
- (NSDictionary *) solarHolidayUS
{   if (!_solarHolidayUS)
    _solarHolidayUS = @{@"0101":NSLocalizedString(@"New Year's Day",""),
                        @"0214":NSLocalizedString(@"Valentine",""),
                        @"0704":NSLocalizedString(@"Independence Day",""),
                        @"1111":NSLocalizedString(@"Veterans Day", ""),
                        @"1225":NSLocalizedString(@"Christmas Day","")
                        };
    return _solarHolidayUS;
}

@end
