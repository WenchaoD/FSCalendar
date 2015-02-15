//
//  SSHolidayCA.h
//  SSLunarDate
//
//  Created by Jiejing Zhang on 13-8-25.
//  Copyright (c) 2013年 Jiejing Zhang. All rights reserved.
//

#import "SSHolidayCountry.h"

@interface SSHolidayCA : SSHolidayCountry

- (NSArray *) getHolidayListForDate:(NSDate *)date;

@end
