//
//  SSHolidayChina.m
//  SSLunarDate
//
//  Created by Jiejing Zhang on 13-8-25.
//  Copyright (c) 2013年 Jiejing Zhang. All rights reserved.
//

#import "SSHolidayChina.h"
#import "SSLunarDate.h"

@interface SSHolidayChina()
{
    NSDictionary    *_solarHolidayCN;
}

@property (readonly) NSDictionary *solarHolidayCN;
@end


@implementation SSHolidayChina

- (NSDictionary *) solarHolidayCN
{
    if (!_solarHolidayCN)
        _solarHolidayCN = @{
                            @"0101":NSLocalizedString(@"元旦",""),
                          @"0214":NSLocalizedString(@"情人节",""),
                          @"0308":NSLocalizedString(@"妇女节",""),
                          @"0501":NSLocalizedString(@"劳动节",""),
                          @"0601":NSLocalizedString(@"儿童节",""),
                            @"0801":NSLocalizedString(@"建军节", ""),
                          @"0910":NSLocalizedString(@"教师节",""),
                          @"1001":NSLocalizedString(@"国庆节",""),
                          @"1225":NSLocalizedString(@"圣诞节","")
                          };
    
    return _solarHolidayCN;
}

- (NSArray *) getHolidayListForDate:(NSDate *)date
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    SSLunarDate *lunarDate = [[SSLunarDate alloc] initWithDate:date
                                                      calendar:self.calendar];
    NSString *lunar = [lunarDate getLunarHolidayNameWithRegion:self.region];
    if (lunar != nil)
        [result addObject:lunar];
    [result addObjectsFromArray: [SSHolidayCountry  getHolidayListFromTable:date
                                                                   calendar:self.calendar
                                                                       dict:self.solarHolidayCN]];
    return result;
}

@end
