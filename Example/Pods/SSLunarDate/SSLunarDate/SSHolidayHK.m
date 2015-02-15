//
//  SSHolidayHK.m
//  SSLunarDate
//
//  Created by Jiejing Zhang on 13-8-25.
//  Copyright (c) 2013年 Jiejing Zhang. All rights reserved.
//

#import "SSHolidayHK.h"
#import "SSLunarDate.h"

@interface SSHolidayHK()
{
    NSDictionary *_solarHolidayHK;
    NSDictionary *_variableHoliday;
    int             _cachedYear;
}

@property (readonly) NSDictionary *solarHolidayTW;
@property (readonly) NSDictionary *variableHoliday;

@end

@implementation SSHolidayHK

- (NSArray *) getHolidayListForDate:(NSDate *)date
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    SSLunarDate *lunarDate = [[SSLunarDate alloc] initWithDate:date
                                                      calendar:self.calendar];

        NSDateComponents *c = [self.calendar components:NSYearCalendarUnit fromDate:date];

    NSAssert(c.year != 0, @"should not zero");
    if (_cachedYear != c.year) {
        _cachedYear = c.year;
        _variableHoliday = nil;
    }

    NSString *lunar = [lunarDate getLunarHolidayNameWithRegion:self.region];
    if (lunar != nil)
        [result addObject:lunar];
    [result addObjectsFromArray: [SSHolidayCountry  getHolidayListFromTable:date
                                                                 calendar:self.calendar
                                                                     dict:self.solarHolidayHK]];

    [result addObjectsFromArray:[SSHolidayCountry getHolidayListFromTable:date calendar:self.calendar dict:[self variableHoliday]]];


    return result;
}

-(NSDictionary *) variableHoliday {
    if (_variableHoliday == nil) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

        NSDate *d;

        d = [self.west getGoodFriday:_cachedYear];
        [dict setObject:HOLIDAY_GOOD_FRIDAY forKey:[self convertDateIndex:d]];

        d = [self.west getGoodFridayNextDay:_cachedYear];
        [dict setObject:HOLIDAY_GOOD_FRIDAY_NEXT forKey:[self convertDateIndex:d]];
        d = [self.west getEasterMonday:_cachedYear];
        [dict setObject:HOLIDAY_EASTER_MONDAY
                forKey:[self convertDateIndex:d]];
        
        _variableHoliday = dict;
    }
    
    return _variableHoliday;
}

// 1. Good Firday, 
// 2. Good Firday + 1 
// 3. Easter + 1
- (NSDictionary *) solarHolidayHK
{
    if (!_solarHolidayHK)
        _solarHolidayHK = @{@"0101":NSLocalizedString(@"元旦",""),
                            @"0214":NSLocalizedString(@"情人节",""),
                            @"0308":NSLocalizedString(@"妇女节",""),
                            @"0501":NSLocalizedString(@"劳动节",""),
                            @"0601":NSLocalizedString(@"儿童节",""),
                            @"0701":NSLocalizedString(@"特区紀念日", ""),
                            @"1001":NSLocalizedString(@"国庆节",""),
                            @"1225":NSLocalizedString(@"圣诞节","")
                            };
    return _solarHolidayHK;
}

@end
