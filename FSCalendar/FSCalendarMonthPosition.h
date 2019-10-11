//
//  FSCalendar.h
//  FSCalendar
//
//  Created by Wenchao Ding on 29/1/15.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//
//  https://github.com/WenchaoD
//
//  FSCalendar is a superior awesome calendar control with high performance, high customizablility and very simple usage.
//
//  @see FSCalendarDataSource
//  @see FSCalendarDelegate
//  @see FSCalendarDelegateAppearance
//  @see FSCalendarAppearance
//

#ifndef FSCalendarMonthPosition_h
#define FSCalendarMonthPosition_h

typedef NS_ENUM(NSUInteger, FSCalendarMonthPosition) {
    FSCalendarMonthPositionPrevious,
    FSCalendarMonthPositionCurrent,
    FSCalendarMonthPositionNext,
    
    FSCalendarMonthPositionNotFound = NSNotFound
};

#endif /* FSCalendarMonthPosition_h */
