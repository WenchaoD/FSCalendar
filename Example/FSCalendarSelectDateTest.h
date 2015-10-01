//
//  FSCalendarSelectDateTest.h
//  FSCalendar
//
//  Created by Wenchao Ding on 10/1/15.
//  Copyright © 2015 wenchaoios. All rights reserved.
//

#define FSCalendarTestSelectDate \
NSLog(@"start test selected date"); \
[_calendar selectDate:[NSDate fs_dateWithYear:2015 month:2 day:1] scrollToDate:NO]; \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ \
    [_calendar selectDate:[NSDate fs_dateWithYear:2015 month:2 day:2]]; \
    if (_calendar.allowsMultipleSelection) { \
        [_calendar selectDate:[NSDate fs_dateWithYear:2015 month:2 day:3]]; \
        [_calendar selectDate:[NSDate fs_dateWithYear:2015 month:2 day:4]]; \
        [_calendar selectDate:[NSDate fs_dateWithYear:2015 month:2 day:5]]; \
        [_calendar selectDate:[NSDate fs_dateWithYear:2015 month:2 day:6]]; \
    } \
}); \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ \
    [_calendar selectDate:[NSDate fs_dateWithYear:2015 month:4 day:2] scrollToDate:YES]; \
}); \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ \
    [_calendar selectDate:[NSDate fs_dateWithYear:2015 month:2 day:2] scrollToDate:YES]; \
}); \
NSLog(@"end test selected date"); \
