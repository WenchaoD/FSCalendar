//
//  SSHolidayManager.h
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

#import <Foundation/Foundation.h>

typedef enum {
    SSHolidayRegionChina = 0,
    SSHolidayRegionHongkong,
    SSHolidayRegionTaiwan,
    SSHolidayRegionUS,
    SSHolidayRegionCanadia,
    SSHolidayRegionUK,
} SSHolidayRegion;

#define HOLIDAY_REGION_CHANGED_NOTICE @"SSHolidayRegionChanged"


// This class manage the solar holiday of selected region.
// Majoy of the holiday day is calc by some rules in WiKi,
// But for some unknow holiday, such as China off day, which will
// update every year, so this should be fetch from network. 
@interface SSHolidayManager : NSObject

- initWithRegion:(SSHolidayRegion) region;

- (NSArray *) getHolidayListForDate:(NSDate *)date;


@end
