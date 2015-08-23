//
//  SSHolidayCountry.h
//  SSLunarDate
//
//  Created by Jiejing Zhang on 13-8-25.
//  Copyright (c) 2013年 Jiejing Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSHolidayManager.h"
#import "SSHolidayWest.h"

@interface SSHolidayCountry : NSObject
- (id) initWithRegion:(SSHolidayRegion) region;
- (NSArray *) getHolidayListForDate:(NSDate *)date;
+ (NSArray *) getHolidayListFromTable:(NSDate *)date
                             calendar:(NSCalendar *)cal
                                 dict:(NSDictionary *) dict;

@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) SSHolidayWest *west;
@property SSHolidayRegion region;

- (NSString*)convertDateIndex: (NSDate*)date;

@end
