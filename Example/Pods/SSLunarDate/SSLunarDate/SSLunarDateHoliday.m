//
//  SSLunarDateHoliday.m
//  SSLunarDate
//
//  Created by Jiejing Zhang on 13-2-20.
//  Copyright (c) 2013 Jiejing Zhang. All rights reserved.

//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software Foundation,
//  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
//

#import "SSLunarDateHoliday.h"

@interface SSLunarDateHoliday()
{
    NSDictionary *_lunarHoliday;
}
@end

static SSLunarDateHoliday *_sslunarholiday = NULL;



@implementation SSLunarDateHoliday

+(id) sharedSSLunarDateHoliday
{
    @synchronized([SSLunarDateHoliday class]) {
        if (!_sslunarholiday)
            _sslunarholiday = [[self alloc] init];
        return _sslunarholiday;
    }
    return nil;
}

+ (id)alloc
{
    @synchronized([SSLunarDateHoliday class]) {
        NSAssert(_sslunarholiday == NULL, @"attempt second sslunarHoliday object");
        if (!_sslunarholiday)
            _sslunarholiday = [super alloc];
        return _sslunarholiday;
    }
    return nil;
}

#define QINGMING_STR NSLocalizedString(@"清明节","")

- (NSDictionary *) lunarHolidayChina
{
    if (!_lunarHoliday)
        _lunarHoliday = @{
                          @"0101":NSLocalizedString(@"春节",""),
                          @"0115":NSLocalizedString(@"元宵节",""),
                          // Qing ming
                          @"0505":NSLocalizedString(@"端午节",""),
                          @"0707":NSLocalizedString(@"七夕",""),
                          @"0815":NSLocalizedString(@"中秋节",""),
                          @"0909":NSLocalizedString(@"重阳节",""),
                          // dong zhi
                          @"1208":NSLocalizedString(@"腊八",""),
                          @"1230":NSLocalizedString(@"除夕","")

                          // FIXME: 2013's Chu Xi is error!!!!
                          };
    
    return _lunarHoliday;
}

+ (NSString *) getPaddingStringForInt:(int) n
{
    return [NSString stringWithFormat:@"%@%d", (n < 10 ? @"0" : @""), n];
}

// Note about qingming:
// http://blog.csdn.net/soft_newcoder/article/details/6127261

- (NSString *) getQingmingDate: (int) solarYear
{
    double c = 0.0f;
    double d = 0.2422;
    if (solarYear >= 1900 && solarYear <= 1999)
        c = 5.59;
    else if (solarYear >= 2000 && solarYear <= 2099)
        c = 4.81;
    else
        return @"";
    int date = ((solarYear % 100) * d + c ) - ((solarYear % 100) / 4);
    
    return [NSString stringWithFormat:@"040%d", date];
}

// Note about Dongzhi & Xiazhi
// http://www.360doc.com/content/10/0424/23/963854_24736431.shtml


#define DONGZHI_STR NSLocalizedString(@"冬至","")

- (NSString *) getDongzhiDate: (int) solarYear
{
    double c = 0.0f;
    double d = 0.2422;
    if (solarYear >= 1900 && solarYear <= 1999)
        c = 22.60f;
    else if (solarYear >= 2000 && solarYear <= 2099)
        c = 21.94;
    else
        return  @"";
    
    int y = solarYear % 100;
    int date = (y * d + c)  - (y / 4);
    
    if (solarYear == 1918 || solarYear == 2021)
        date -= 1;
    return [NSString stringWithFormat:@"12%d", date];
}

+ (NSString *) convertIndexFrom:(int) month day: (int) day
{
    NSString *index;
    index = [NSString stringWithFormat:@"%@%@",
             [self.class getPaddingStringForInt:month],
             [self.class getPaddingStringForInt:day]];
    return index;
}

- (BOOL) isDateLunarHoliday:(LibLunarContext *) lunar region:(SSHolidayRegion) region
{
    NSAssert(lunar != NULL, @"lunar should not null");
    
    NSString *index;
    
//    Leap month is not holiday...
    if (lunar->_lunar.leap == 1)
        return NO;
    
    index = [self.class convertIndexFrom:lunar->_lunar.month
                                     day:lunar->_lunar.day];

    if (region == SSHolidayRegionChina)
        return [self isDateLunarHolidayChina:lunar index:index];
    
   
    
    return NO;
}

- (NSString *) getLunarHolidayNameForDate: (LibLunarContext *) lunar region:(SSHolidayRegion) region
{
    NSAssert(lunar != NULL, @"lunar should not null");
    if (![self isDateLunarHoliday:lunar region:region])
        return nil;
    
    NSString *index = [self.class convertIndexFrom:lunar->_lunar.month
                                     day:lunar->_lunar.day];
    
    if (region == SSHolidayRegionChina)
        return [self getLunarHolidayNameForDateChina:lunar index:index];

    return nil;
}

- (BOOL) isDateLunarHolidayChina:(LibLunarContext *) lunar index:(NSString *)index
{
    if ([[self lunarHolidayChina] objectForKey:index] != nil)
        return YES;
    if ([index isEqualToString:[self getQingmingDate:lunar->_solar.year]])
        return YES;
    if ([index isEqualToString:[self getDongzhiDate:lunar->_solar.year]])
        return YES;
    return NO;
}

- (NSString *) getLunarHolidayNameForDateChina:(LibLunarContext *)lunar index:(NSString *)index
{
    if ([index isEqualToString:[self getQingmingDate:lunar->_solar.year]])
        return QINGMING_STR;
    if ([index isEqualToString:[self getDongzhiDate:lunar->_solar.year]])
        return DONGZHI_STR;
    
    NSString *name = [[self lunarHolidayChina] objectForKey:index];
    return name;
}




@end
