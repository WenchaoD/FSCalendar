//
//  SSLunarDateFormatter.m
//  SSLunarDate
//
//  Created by Jiejing Zhang on 13-2-7.
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

#import "SSLunarDateFormatter.h"

#define YEAR_STR NSLocalizedString(@"年", "year")
#define LEAP_STR NSLocalizedString(@"闰", "leap")

@interface SSLunarDateFormatter()
{
    NSArray *_monthArray;
    NSArray *_dayArray;
    NSArray *_ganArray;
    NSArray *_zhiArray;
    NSArray *_zodiacArray;
    NSArray *_solarTerm;
}
@end


static SSLunarDateFormatter  *_sharedFormatter = NULL;

@implementation SSLunarDateFormatter

+ (SSLunarDateFormatter *)sharedLunarDateFormatter
{
    @synchronized([SSLunarDateFormatter class]) {
        if (!_sharedFormatter)
            _sharedFormatter = [[self alloc] init];
        return _sharedFormatter;
    }
    return nil;
}

+ (id) alloc
{
    @synchronized([SSLunarDateFormatter class]) {
        NSAssert(_sharedFormatter == NULL, @"attempt to alloc a second SharedLunarDateFormatter");
        _sharedFormatter = [super alloc];
        return _sharedFormatter;
    }
    return nil;
}

- (NSArray *) monthArray
{
    if (!_monthArray)
        _monthArray = @[
        NSLocalizedString(@"正月",""),
        NSLocalizedString(@"二月",""),
        NSLocalizedString(@"三月",""),
        NSLocalizedString(@"四月",""),
        NSLocalizedString(@"五月",""),
        NSLocalizedString(@"六月",""),
        NSLocalizedString(@"七月",""),
        NSLocalizedString(@"八月",""),
        NSLocalizedString(@"九月",""),
        NSLocalizedString(@"十月",""),
        NSLocalizedString(@"十一月",""),
        NSLocalizedString(@"腊月","")];

    return _monthArray;
}

- (NSArray *) dayArray
{
    if (!_dayArray)
        _dayArray = @[
        NSLocalizedString(@"初一",""),
        NSLocalizedString(@"初二",""),
        NSLocalizedString(@"初三",""),
        NSLocalizedString(@"初四",""),
        NSLocalizedString(@"初五",""),
        NSLocalizedString(@"初六",""),
        NSLocalizedString(@"初七",""),
        NSLocalizedString(@"初八",""),
        NSLocalizedString(@"初九",""),
        NSLocalizedString(@"初十",""),
        NSLocalizedString(@"十一",""),
        NSLocalizedString(@"十二",""),
        NSLocalizedString(@"十三",""),
        NSLocalizedString(@"十四",""),
        NSLocalizedString(@"十五",""),
        NSLocalizedString(@"十六",""),
        NSLocalizedString(@"十七",""),
        NSLocalizedString(@"十八",""),
        NSLocalizedString(@"十九",""),
        NSLocalizedString(@"二十",""),
        NSLocalizedString(@"廿一",""),
        NSLocalizedString(@"廿二",""),
        NSLocalizedString(@"廿三",""),
        NSLocalizedString(@"廿四",""),
        NSLocalizedString(@"廿五",""),
        NSLocalizedString(@"廿六",""),
        NSLocalizedString(@"廿七",""),
        NSLocalizedString(@"廿八",""),
        NSLocalizedString(@"廿九",""),
        NSLocalizedString(@"三十","")];
    
    return _dayArray;
}

- (NSArray *) ganArray
{
    if (!_ganArray)
        _ganArray = @[
        NSLocalizedString(@"甲",""),
        NSLocalizedString(@"乙",""),
        NSLocalizedString(@"丙",""),
        NSLocalizedString(@"丁",""),
        NSLocalizedString(@"戊",""),
        NSLocalizedString(@"己",""),
        NSLocalizedString(@"庚",""),
        NSLocalizedString(@"辛",""),
        NSLocalizedString(@"壬",""),
        NSLocalizedString(@"癸","")];
    return _ganArray;
}

- (NSArray *) zhiArray
{
    if (!_zhiArray)
        _zhiArray = @[
        NSLocalizedString(@"子",""),
        NSLocalizedString(@"丑",""),
        NSLocalizedString(@"寅",""),
        NSLocalizedString(@"卯",""),
        NSLocalizedString(@"辰",""),
        NSLocalizedString(@"巳",""),
        NSLocalizedString(@"午",""),
        NSLocalizedString(@"未",""),
        NSLocalizedString(@"申",""),
        NSLocalizedString(@"酉",""),
        NSLocalizedString(@"戌",""),
        NSLocalizedString(@"亥","")];
    return _zhiArray;
}

- (NSArray *) zodiacArray
{
    if (!_zodiacArray)
        _zodiacArray = @[
        NSLocalizedString(@"鼠",""),
        NSLocalizedString(@"牛",""),
        NSLocalizedString(@"虎",""),
        NSLocalizedString(@"兔",""),
        NSLocalizedString(@"龙",""),
        NSLocalizedString(@"蛇",""),
        NSLocalizedString(@"马",""),
        NSLocalizedString(@"羊",""),
        NSLocalizedString(@"猴",""),
        NSLocalizedString(@"鸡",""),
        NSLocalizedString(@"狗",""),
        NSLocalizedString(@"猪","")];
    return _zodiacArray;
}

- (NSArray *) solarTerm
{
    if (!_solarTerm)
        _solarTerm = @[
        NSLocalizedString(@"立春",""),
        NSLocalizedString(@"雨水",""),
        NSLocalizedString(@"清明",""),
        NSLocalizedString(@"春分",""),
        NSLocalizedString(@"惊蛰",""),
        NSLocalizedString(@"谷雨",""),
        NSLocalizedString(@"立夏",""),
        NSLocalizedString(@"小满",""),
        NSLocalizedString(@"芒种",""),
        NSLocalizedString(@"夏至",""),
        NSLocalizedString(@"小暑",""),
        NSLocalizedString(@"大暑",""),
        NSLocalizedString(@"立秋",""),
        NSLocalizedString(@"处暑",""),
        NSLocalizedString(@"白露",""),
        NSLocalizedString(@"秋分",""),
        NSLocalizedString(@"寒露",""),
        NSLocalizedString(@"霜降",""),
        NSLocalizedString(@"立冬",""),
        NSLocalizedString(@"小雪",""),
        NSLocalizedString(@"大雪",""),
        NSLocalizedString(@"冬至",""),
        NSLocalizedString(@"小寒",""),
        NSLocalizedString(@"大寒","")];

    return _solarTerm;
}




- (NSString *) getGanZhiNameForDate:(LibLunarContext *)lunar
{
    NSAssert(lunar != NULL, @"lunar not be null");
    
    return [NSString  stringWithFormat:@"%@%@",
            [self ganArray][lunar->_gan.year],
            [self zhiArray][lunar->_zhi.year]];
}

- (NSString *) getGanZhiYearNameForDate:(LibLunarContext *)lunar
{
    NSAssert(lunar != NULL, @"lunar not be null");

    return [NSString stringWithFormat:@"%@%@%@",
                     [self ganArray][lunar->_gan.year],
                     [self zhiArray][lunar->_zhi.year],
                     YEAR_STR];
}

- (NSString *) getShengXiaoNameForDate:(LibLunarContext *)lunar
{
    NSAssert(lunar != NULL, @"lunar should not null");
    return [self zodiacArray][lunar->_zhi.year];
}

- (NSString *) getLunarMonthForDate: (LibLunarContext *) lunar
{
    NSAssert(lunar != NULL, @"lunar should not null");

    NSString *monthStr = [self monthArray][lunar->_lunar.month - 1];
    if ([self isLeapMonthForDate:lunar]) {
        return [NSString stringWithFormat:@"%@%@",
                         LEAP_STR,
                         monthStr];
    } else 
        return monthStr;
}

- (NSString *) getDayNameForDate: (LibLunarContext *) lunar
{
    NSAssert(lunar != NULL, @"lunar should not null");
    return [self dayArray][lunar->_lunar.day - 1];
}

- (NSString *) getFullLunarStringForDate: (LibLunarContext *) lunar
{
    NSAssert(lunar != NULL, @"lunar should not null");

    return [NSString stringWithFormat:@"%@%@%@%@", [self getGanZhiNameForDate:lunar],
    YEAR_STR, [self getLunarMonthForDate:lunar],
     [self getDayNameForDate:lunar] ];
    
}

- (NSString *) getLeapString
{
    return LEAP_STR;
}

- (BOOL) isLeapMonthForDate: (LibLunarContext *) lunar
{
        NSAssert(lunar != NULL, @"lunar should not null");
        return lunar->_lunar.leap == 1;
}

@end
