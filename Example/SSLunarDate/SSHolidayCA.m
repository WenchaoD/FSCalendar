//
//  SSHolidayCA.m
//  SSLunarDate
//
//  Created by Jiejing Zhang on 13-8-25.
//  Copyright (c) 2013年 Jiejing Zhang. All rights reserved.
//

#import "SSHolidayCA.h"
#import "SSLunarDateHoliday.h"
#import "SSHolidayWest.h"

@interface SSHolidayCA()
{
        NSDictionary    *_solarHolidayCA;
        NSDictionary    *_variableHoliday;
        int             _cachedYear;
}

@property (readonly) NSDictionary *solarHolidayCA;
@property (readonly) NSDictionary *variableHoliday;

@end

@implementation SSHolidayCA

- (NSArray *) getHolidayListForDate:(NSDate *)date 
{
// 1. add table holiday
// 2. add selected wester holiday
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    [result addObjectsFromArray: [SSHolidayCountry  getHolidayListFromTable:date
                                                                 calendar:self.calendar
                                                                     dict:[self solarHolidayCA]]];
    
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

        d = [self.west getGoodFriday:_cachedYear];
        [dict setObject:HOLIDAY_GOOD_FRIDAY forKey:[self convertDateIndex:d]];

        d = [self.west getEasterMonday:_cachedYear];
        [dict setObject:HOLIDAY_EASTER_MONDAY
                 forKey:[self convertDateIndex:d]];

        d = [self.west getLaborDay:_cachedYear];
        [dict setObject:HOLIDAY_LABOR_DAY forKey:[self convertDateIndex:d]];
        
        d = [self.west getThanksGivingDay:_cachedYear];
        [dict setObject:HOLIDAY_THANKS_DAY forKey:[self convertDateIndex:d]];

        d = [self.west getVictoriaDay:_cachedYear];
        [dict setObject:HOLIDAY_VICTORIA_DAY forKey:[self convertDateIndex:d]];
        
        _variableHoliday = dict;
    }
    
    return _variableHoliday;
}
// 1. Good Friday
// 2. Labor 's day

- (NSDictionary *) solarHolidayCA
{
    if (!_solarHolidayCA)
        _solarHolidayCA = @{@"0101":NSLocalizedString(@"New Year's Day",""),
                            @"0214":NSLocalizedString(@"Valentine",""),
                            @"0701":NSLocalizedString(@"Canada Day",""),
                            @"1111":NSLocalizedString(@"Remembrance Day",""),
                            @"1225":NSLocalizedString(@"Christmas Day",""),
                            @"1226":NSLocalizedString(@"Boxing Day","")
                            };
    return _solarHolidayCA;

}

@end
