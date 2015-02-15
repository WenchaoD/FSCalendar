//
//  SSHolidayWest.h
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


#import <Foundation/Foundation.h>

// United Kingdom holiday
#define HOLIDAY_GOOD_FRIDAY      NSLocalizedString(@"Good Friday","")
#define HOLIDAY_GOOD_FRIDAY_NEXT NSLocalizedString(@"The day following Good Friday","")
#define HOLIDAY_EASTER_DAY       NSLocalizedString(@"Easter Day","")
#define HOLIDAY_EASTER_MONDAY    NSLocalizedString(@"Easter Monday","")
#define HOLIDAY_MAY_BANK_DAY     NSLocalizedString(@"May Day Bank Holiday", "")
#define HOLIDAY_SPRING_BANK_DAY NSLocalizedString(@"Spring Bank Holiday", "")
#define HOLIDAY_LATE_SUMMERY_BANK_DAY   NSLocalizedString(@"Summer Bank Holiday","")
#define HOLIDAY_BOXING_DAY      NSLocalizedString(@"Boxing Day","")

// US Holiday
#define HOLIDAY_MLK_BIRTHDAY    NSLocalizedString(@"Birthday of MLK", "")
#define HOLIDAY_MEM_DAY         NSLocalizedString(@"Memorial Day", "")
#define HOLIDAY_LABOR_DAY       NSLocalizedString(@"Labor Day", "")
#define HOLIDAY_COLUMBUS_DAY    NSLocalizedString(@"Columbus Day", "")
#define HOLIDAY_THANKS_DAY      NSLocalizedString(@"Thanksgiving Day", "")

// CA Holiday
#define HOLIDAY_VICTORIA_DAY    NSLocalizedString(@"Victoria Day", "")

@interface SSHolidayWest : NSObject
{
    NSCalendar *currentCalendar;
}
- (id) initWithCalendar:(NSCalendar *) calendar;
- (NSDate *) getEaster: (int) year;
- (NSDate *) getEasterMonday: (int) year;
- (NSDate *) getGoodFriday: (int) year;
- (NSDate *) getGoodFridayNextDay: (int) year;
- (NSDate *) getMartinLutherKingBirthday: (int) year;
- (NSDate *) getPresidentsDay: (int) year;
- (NSDate *) getMemorialDay: (int) year;
- (NSDate *) getLaborDay: (int) year;
- (NSDate *) getColumbusDay: (int) year;
- (NSDate *) getThanksGivingDay: (int) year;

- (NSDate *) getMayBankDay: (int) year;
- (NSDate *) getSpringBankDay: (int) year;
- (NSDate *) getLateSummaryBankHoliday: (int) year;
- (NSDate *) getBoxingDay: (int) year;

- (NSDate *) getVictoriaDay: (int) year;

@end
