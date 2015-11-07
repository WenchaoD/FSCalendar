//
//  NSString+FSExtension.m
//  FSCalendar
//
//  Created by Wenchao Ding on 8/29/15.
//  Copyright (c) 2015 wenchaoios. All rights reserved.
//

#import "NSString+FSExtension.h"
#import "NSDate+FSExtension.h"

@implementation NSString (FSExtension)

- (NSDate *)fs_dateWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [NSDateFormatter fs_sharedDateFormatter];
    formatter.dateFormat = format;
    return [formatter dateFromString:self];
}

- (NSDate *)fs_date
{
    return [self fs_dateWithFormat:@"yyyyMMdd"];
}

@end
