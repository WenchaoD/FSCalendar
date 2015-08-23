//
//  SSHolidayTW.m
//  SSLunarDate
//
//  Created by Jiejing Zhang on 13-8-25.
//  Copyright (c) 2013年 Jiejing Zhang. All rights reserved.
//

#import "SSHolidayTW.h"
#import "SSLunarDate.h"

@interface SSHolidayTW() 
{
        NSDictionary    *_solarHolidayTW;
}

@property (readonly) NSDictionary *solarHolidayTW;

@end

@implementation SSHolidayTW

- (NSDictionary *) solarHolidayTW
{   if (!_solarHolidayTW)
    _solarHolidayTW = @{@"0101":NSLocalizedString(@"开国纪念日",""),
                        @"0214":NSLocalizedString(@"情人节",""),
                        @"0228":NSLocalizedString(@"和平纪念日",""),
                        @"0308":NSLocalizedString(@"妇女节",""),
                        @"0501":NSLocalizedString(@"劳动节",""),
                        @"0601":NSLocalizedString(@"儿童节",""),
                        @"0903":NSLocalizedString(@"军人节", ""),
                        @"1010":NSLocalizedString(@"中华民国国庆日",""),
                        @"1225":NSLocalizedString(@"圣诞节","")
                        };
    return _solarHolidayTW;
}

- (NSArray *) getHolidayListForDate:(NSDate *)date
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    SSLunarDate *lunarDate = [[SSLunarDate alloc] initWithDate:date
                                                      calendar:self.calendar];
    NSString *lunar;
    lunar = [lunarDate getLunarHolidayNameWithRegion:self.region];
    if (lunar != nil)
        [result addObject:lunar];
    [result addObjectsFromArray: [SSHolidayCountry  getHolidayListFromTable:date
                                                                 calendar:self.calendar
                                                                     dict:self.solarHolidayTW]];
    return result;
}

@end
