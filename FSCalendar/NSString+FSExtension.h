//
//  NSString+FSExtension.h
//  FSCalendar
//
//  Created by Wenchao Ding on 8/29/15.
//  Copyright (c) 2015 wenchaoios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FSExtension)

- (NSDate *)fs_dateWithFormat:(NSString *)format;
- (NSDate *)fs_date;

@end
