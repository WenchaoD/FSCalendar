//
//  SSLunarDate.m
//  SSLunarDate
//
//  Created by Jiejing Zhang on 13-2-6.
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

#import "SSLunarDate.h"
#import "libLunar.h"
#import "SSLunarDateHoliday.h"

@interface SSLunarDate()
{
    BOOL                    dateOutOfRange;
    NSCalendar              *_calendar;
    NSDate                  *_solarDate;
    SSLunarDateFormatter    *_formater;
    LibLunarContext         *_ctx;
    SSLunarSimpleDate       _simpleSolarDate;
}
@end

@implementation SSLunarDate


- (id) init
{
    self = [super init];
    if (self) {
        [self setupAndDoConvert:[NSDate date]
                       calendar:[NSCalendar currentCalendar]];
    }
    
    return self;
}

- (void) dealloc
{
    // not call [supoer dealloc] since ARC already provide this.
    freeLunarContext(_ctx);
    _ctx = NULL;
}

- (id) initWithDate:(NSDate *) solarDate
{
    self = [super init];
    if (self) {
        [self setupAndDoConvert:solarDate
                       calendar:[NSCalendar currentCalendar]];
    }
    return self;
}

- (id) initWithDate:(NSDate *)solarDate calendar:(NSCalendar *)calendar
{
    self = [super init];
    if (self) {
        [self setupAndDoConvert:solarDate calendar:calendar];
    }
    
    return self;
}

- (void) setupAndDoConvert:(NSDate *) solarDate calendar:(NSCalendar *) cal
{
    _calendar = cal;
    _formater = [SSLunarDateFormatter sharedLunarDateFormatter];
    [self NSDataToLunarDate:solarDate withDate:&_simpleSolarDate];
    
    //    NSLog(@"solarDate:%d %d", _simpleSolarDate.month, _simpleSolarDate.day);
    
    if (libLunarCheckYearRange(_simpleSolarDate.year) == false) {
        dateOutOfRange = TRUE;
    }

    NSAssert(_ctx == NULL,
             @"libLunar Context was not null when setup, leak...");
    _ctx = createLunarContext();
    NSAssert(_ctx != NULL, @"create context failed");
    Solar2Lunar(_ctx, &_simpleSolarDate);
}

#define RETURN_EMPTY_IF_DATE_OUT_OF_RANGE do { if (dateOutOfRange) return @""; } while (0)
#define RETURN_NO_IF_DATE_OUT_OF_RANGE do { if (dateOutOfRange) return FALSE; } while (0)

- (BOOL) convertSuccess
{
    return !dateOutOfRange;
}

- (NSString *) monthString
{
    NSAssert(_formater, @"formatter is null!");
    RETURN_EMPTY_IF_DATE_OUT_OF_RANGE;
    return [_formater getLunarMonthForDate:_ctx];
}

- (NSString *) dayString
{
    NSAssert(_formater, @"formatter is null");
    RETURN_EMPTY_IF_DATE_OUT_OF_RANGE;
    return [_formater getDayNameForDate:_ctx];
}

- (NSString *) zodiacString
{
    NSAssert(_formater, @"formatter is null");
    RETURN_EMPTY_IF_DATE_OUT_OF_RANGE;
    return [_formater getShengXiaoNameForDate:_ctx];
}

- (NSString *) leapString
{
    RETURN_EMPTY_IF_DATE_OUT_OF_RANGE;
    return [_formater getLeapString];
}

- (NSString *) yearGanzhiString
{
    NSAssert(_formater, @"formatter is null");
    RETURN_EMPTY_IF_DATE_OUT_OF_RANGE;
    return [_formater getGanZhiYearNameForDate:_ctx];
}

- (NSString *) string
{
    NSAssert(_formater, @"formatter is null");
    RETURN_EMPTY_IF_DATE_OUT_OF_RANGE;
    return [_formater getFullLunarStringForDate:_ctx];
}

- (BOOL) isLeapMonth
{
    NSAssert(_formater, @"formatter is null");
    RETURN_NO_IF_DATE_OUT_OF_RANGE;
    return [_formater isLeapMonthForDate:_ctx];
}

- (void) NSDataToLunarDate:(NSDate *) date withDate:(SSLunarSimpleDate *) lunarDate
{
    unsigned int flags = NSYearCalendarUnit             \
        | NSMonthCalendarUnit | NSDayCalendarUnit       \
        | NSHourCalendarUnit;
    NSDateComponents *parts = [_calendar components:flags fromDate:date];
    
    lunarDate->year = parts.year;
    lunarDate->month = parts.month;
    lunarDate->day = parts.day;
    lunarDate->hour = parts.hour;
}

- (BOOL) isLunarHolidayWithRegion:(SSHolidayRegion) region
{
    SSLunarDateHoliday *holiday = [SSLunarDateHoliday sharedSSLunarDateHoliday];
    
    return [holiday isDateLunarHoliday:_ctx region:region];
}

- (NSString *) getLunarHolidayNameWithRegion:(SSHolidayRegion) region
{
    SSLunarDateHoliday *holiday = [SSLunarDateHoliday sharedSSLunarDateHoliday];
    return [holiday getLunarHolidayNameForDate:_ctx region:region];
}

@end
