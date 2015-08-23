//
//  SSHolidayUK.m
//  SSLunarDate
//
//  Created by Jiejing Zhang on 13-8-25.
//  Copyright (c) 2013年 Jiejing Zhang. All rights reserved.
//

#import "SSHolidayUK.h"

@interface SSHolidayUK()
{
    NSDictionary    *_fixedHoliday;
    NSDictionary    *_variableHoliday;
    int             _cachedYear;
}

@property (readonly) NSDictionary *fixedHoliday;
@property (readonly) NSDictionary *variableHoliday;

@end
@implementation SSHolidayUK


- (NSArray *) getHolidayListForDate:(NSDate *)date
{
// 1. add table holiday
// 2. add selected wester holiday
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    [result addObjectsFromArray: [SSHolidayCountry  getHolidayListFromTable:date
                                                                 calendar:self.calendar
                                                                     dict:[self fixedHoliday]]];
    
    NSDateComponents *c = [self.calendar components:NSYearCalendarUnit fromDate:date];

    NSAssert(c.year != 0, @"should not zero");
    if (_cachedYear != c.year) {
        _cachedYear = c.year;
        _variableHoliday = nil;
    }
    
    [result addObjectsFromArray:[SSHolidayCountry getHolidayListFromTable:date calendar:self.calendar dict:[self variableHoliday]]];
    return result;
}

- (NSDictionary *) fixedHoliday
{
    if (!_fixedHoliday)
        _fixedHoliday = @{@"0101":NSLocalizedString(@"New Year's Day",""),
                          @"0317":NSLocalizedString(@"St. Patrick's Day",""),
                          @"0712":NSLocalizedString(@"Orangeman's Day", ""),
                          @"1225":NSLocalizedString(@"Christmas Day","")};
    return _fixedHoliday;
}

// 1. good Friday
// 2. easter Monday
// 3. may day bank holiday
// 4. spring bank holiday
// 5. last summary bank holiday
// 6. boxing day
- (NSDictionary *) variableHoliday
{
    if (_variableHoliday == nil) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

        NSDate *d;

        d = [self.west getGoodFriday:_cachedYear];
        [dict setObject:HOLIDAY_GOOD_FRIDAY forKey:[self convertDateIndex:d]];

        d = [self.west getEaster:_cachedYear];
        [dict setObject:HOLIDAY_EASTER_DAY forKey:[self convertDateIndex:d]];

        d = [self.west getEasterMonday:_cachedYear];
        [dict setObject:HOLIDAY_EASTER_MONDAY
                 forKey:[self convertDateIndex:d]];

        d = [self.west getMayBankDay: _cachedYear];
        [dict setObject:HOLIDAY_MAY_BANK_DAY forKey:[self convertDateIndex:d]];

        d = [self.west getSpringBankDay: _cachedYear];
        [dict setObject:HOLIDAY_SPRING_BANK_DAY forKey:[self convertDateIndex:d]];

        d = [self.west getLateSummaryBankHoliday:_cachedYear];
        [dict setObject:HOLIDAY_LATE_SUMMERY_BANK_DAY forKey:[self convertDateIndex:d]];

        d = [self.west getBoxingDay:_cachedYear];
        [dict setObject:HOLIDAY_BOXING_DAY forKey:[self convertDateIndex:d]];
        
        _variableHoliday = dict;
    }
    
    return _variableHoliday;
}
@end
