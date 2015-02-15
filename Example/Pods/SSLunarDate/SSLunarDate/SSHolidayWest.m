
//
//  SSHolidayWest.m
//  SSLunarDate
//
//  Created by Jiejing Zhang on 13-2-21.
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

// The Easter algorithm is from
// HTTP://www.codeproject.com/Articles/1595/Calculating-Easter-Sunday


#import "SSHolidayWest.h"

@implementation SSHolidayWest
// TODO: need implement a cache with current year.

- (id) initWithCalendar:(NSCalendar *)calendar
{
    self = [super init];
    if (self) {
        currentCalendar = calendar;
    }
    return self;
}

- (NSDate *) getDateFromYear:(int) year month: (int) month day: (int) day
{
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar *cal = currentCalendar;
    NSDateComponents *parts = [cal components:flags
				     fromDate:[NSDate date]];
    [parts setYear:year];
    [parts setMonth:month];
    [parts setDay:day];
    
    return [cal dateFromComponents:parts];
}

- (NSDate *) getEasterMonday: (int) year
{

    // good Friday is two day before easter day
    NSDate *easterDay = [self getEaster:year];
    NSDateComponents *c = [[NSDateComponents  alloc] init];
    c.day = 1;
 
    return [currentCalendar
	       dateByAddingComponents:c toDate:easterDay options:0];
}

// calculate easter sunday
- (NSDate *) getEaster: (int) year
{
     int correction = 0;

     int day, month;

     if (year < 1700)		correction = 4;
     else if (year < 1800)	correction = 5;
     else if (year < 1900)	correction = 6;
     else if (year < 2100)	correction = 0;
     else if (year < 2200)	correction = 1;
     else if (year < 2300)	correction = 2;
     else if (year < 2500)	correction = 3;

     day = (19 * (year % 19) + 24) % 30;
     day = 22 + day + ((2 * (year % 4) + 4 * (year % 7) + 6 * day + 5 + correction) % 7);
     
     // jump to next month
     if (day > 31) {
	  month = 4;
	  day -= 31;
     } else {
	  month = 3;
     }

     // compose to a NSDate...
     return [self getDateFromYear:year month:month day:day];
}

- (NSDate *) getGoodFriday: (int) year
{
    // good Friday is two day before easter day
    NSDate *easterDay = [self getEaster:year];
    NSDateComponents *c = [[NSDateComponents  alloc] init];
    c.day = -2;
 
    return [currentCalendar
	       dateByAddingComponents:c toDate:easterDay options:0];
}

- (NSDate *) getGoodFridayNextDay: (int) year
{
    // one day after good Friday
    NSDate *easterDay = [self getEaster:year];
    NSDateComponents *c = [[NSDateComponents  alloc] init];
    c.day = -1;
    
    return [currentCalendar
	       dateByAddingComponents:c toDate:easterDay options:0];
    
}

// Third Monday in January, Birthday of Dr. Martin Luther King, Jr.
- (NSDate *) getMartinLutherKingBirthday: (int) year
{
    NSCalendar *calendar = currentCalendar;
    NSDateComponents *c = [[NSDateComponents alloc] init];

    c.month = 1;
    c.weekdayOrdinal = 3;	// third week
    c.weekday = 2;		// Monday
    c.year = year;
    
    return [calendar dateFromComponents:c];
}

// Third Monday in Feb
- (NSDate *) getPresidentsDay: (int) year
{
    NSCalendar *calendar = currentCalendar;
    NSDateComponents *c = [[NSDateComponents alloc] init];

    c.month = 2;
    c.weekdayOrdinal = 3;	// third week
    c.weekday = 2;		// Monday
    c.year = year;
    
    return [calendar dateFromComponents:c];
}

// Last Monday in May	Memorial Day
- (NSDate *) getMemorialDay: (int) year
{
    NSCalendar* calendar = currentCalendar;
    NSDateComponents* firstMondayInJuneComponents = [NSDateComponents new] ;
    firstMondayInJuneComponents.month = 6 ;
    firstMondayInJuneComponents.weekdayOrdinal = 1 ;
    firstMondayInJuneComponents.weekday = 2 ; //Monday
    firstMondayInJuneComponents.year = year;
    NSDate* firstMondayInJune = [calendar
                                 dateFromComponents:firstMondayInJuneComponents] ;
// --> 2012-06-04

    NSDateComponents* subtractAWeekComponents = [NSDateComponents new] ;
    subtractAWeekComponents.week = -1 ;
    NSDate* memorialDay = [calendar dateByAddingComponents:subtractAWeekComponents
                                                    toDate:firstMondayInJune options:0] ;
// --> 2012-05-28
    return memorialDay;
}

// First Monday in Septembe Labor Day
- (NSDate *) getLaborDay: (int) year
{
    NSCalendar *calendar = currentCalendar;
    NSDateComponents *c = [[NSDateComponents alloc] init];

    c.month = 9;
    c.weekdayOrdinal = 1;
    c.weekday = 2;		// Monday
    c.year = year;
    
    return [calendar dateFromComponents:c];
}

// Second Monday in October Columbus Day
- (NSDate *) getColumbusDay: (int) year
{
    NSCalendar *calendar = currentCalendar;
    NSDateComponents *c = [[NSDateComponents alloc] init];

    c.month = 10;
    c.weekdayOrdinal = 2;
    c.weekday = 2;		// Monday
    c.year = year;
    
    return [calendar dateFromComponents:c];
}

// Fourth Thursday in November
- (NSDate *) getThanksGivingDay: (int) year
{
    NSCalendar *calendar = currentCalendar;
    NSDateComponents *c = [[NSDateComponents alloc] init];

    c.month = 11;
    c.weekdayOrdinal = 4;
    c.weekday = 5;	
    c.year = year;
    
    return [calendar dateFromComponents:c];
}


// 1st Monday in May
- (NSDate *) getMayBankDay: (int) year
{
    NSCalendar *calendar = currentCalendar;
    NSDateComponents *c = [[NSDateComponents alloc] init];

    c.month = 5;
    c.weekdayOrdinal = 1;	// 1st
    c.weekday = 2;		// Monday
    c.year = year;
    
    return [calendar dateFromComponents:c];
}

// last Monday in may
- (NSDate *) getSpringBankDay: (int) year
{
    return [self getMemorialDay:year];
}


// last Monday in August
- (NSDate *) getLateSummaryBankHoliday: (int) year
{

    NSCalendar* calendar = currentCalendar;
    NSDateComponents* firstMondayNextMonthComponents = [NSDateComponents new] ;
    firstMondayNextMonthComponents.month = 9 ;
    firstMondayNextMonthComponents.weekdayOrdinal = 1 ;
    firstMondayNextMonthComponents.weekday = 2 ; //Monday
    firstMondayNextMonthComponents.year = year;
    NSDate* firstMondayNextMonth = [calendar
                                 dateFromComponents:firstMondayNextMonthComponents] ;
// 

    NSDateComponents* subtractAWeekComponents = [NSDateComponents new] ;
    subtractAWeekComponents.week = -1 ;
    NSDate* day = [calendar dateByAddingComponents:subtractAWeekComponents
                                                    toDate:firstMondayNextMonth options:0] ;
    return day;
    
}

- (NSDate *) getBoxingDay: (int) year
{
    NSCalendar *calendar = currentCalendar;
    NSDateComponents *c = [[NSDateComponents alloc] init];

    c.month = 12;
    c.day = 26;
    c.year = year;

    NSDate *d = [calendar dateFromComponents:c];
    NSDateComponents *cc = [calendar components:kCFCalendarUnitWeekday fromDate:d];
    if (cc.weekday == 1) {// if sunday, move to next monday
        c.day = 27;
        return [calendar dateFromComponents:c];
    } else
        return d;
}

// Last Monday before 5/25
- (NSDate *) getVictoriaDay: (int) year
{
    NSCalendar *calendar = currentCalendar;
    NSDateComponents *c = [[NSDateComponents alloc] init];

    c.month = 5;
    c.day = 24;
    c.year = year;
    NSDate *may24 = [calendar dateFromComponents:c];
    NSDateComponents *cc = [calendar components:kCFCalendarUnitWeekday fromDate:may24];
    
    // if that day was monday, it equal to zero.
    // if that day was tue, it equal to 1, minor 1 =
    NSDateComponents *ccc = [NSDateComponents new];
    int reminder = cc.weekday - 2;
    if (reminder >= 0)
        ccc.day  = - (cc.weekday - 2);
    else
        ccc.day = -6; // only happen when 24 is sunday.
    
    return [calendar dateByAddingComponents:ccc toDate:may24 options:0];
}

@end

