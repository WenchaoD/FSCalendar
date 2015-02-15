//
//  SSHolidayManager.m
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
#import "SSHolidayManager.h"
#import "SSLunarDate.h"
#import "SSHolidayCountry.h"
#import "SSHolidayUK.h"
#import "SSHolidayTW.h"
#import "SSHolidayUS.h"
#import "SSHolidayChina.h"
#import "SSHolidayHK.h"
#import "SSHolidayCA.h"

@interface SSHolidayManager ()
{
    SSHolidayRegion _region;
    SSHolidayCountry *_country;    
}

@property (readonly) SSHolidayCountry *country;
@end

@implementation SSHolidayManager

- (id) initWithRegion:(SSHolidayRegion)region
{
    self = [super init];
    if (self) {
        _region = region;
        _country = [self allocateHolidayAlgoByRegion:region];
    }
    return self;
}

- (SSHolidayCountry *) allocateHolidayAlgoByRegion:(SSHolidayRegion)r {
    switch (r) {
    case SSHolidayRegionChina:
        return [[SSHolidayChina alloc] init];
    case SSHolidayRegionHongkong:
        return [[SSHolidayHK alloc] init];
    case SSHolidayRegionTaiwan:
        return [[SSHolidayTW alloc] init];
    case SSHolidayRegionUS:
        return [[SSHolidayUS alloc] init];
    case SSHolidayRegionCanadia:
        return [[SSHolidayCA alloc] init];
    case SSHolidayRegionUK:
        return [[SSHolidayUK alloc] init];
    default:
        NSAssert(false, @"should not be here");
        return [[SSHolidayChina alloc] init];
    }
}


- (NSArray *) getHolidayListForDate:(NSDate *)date
{
    return [_country getHolidayListForDate:date];
}


@end
