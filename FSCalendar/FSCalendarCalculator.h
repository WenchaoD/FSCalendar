//
//  FSCalendarCalculator.h
//  FSCalendar
//
//  Created by dingwenchao on 30/10/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class FSCalendar;

typedef NS_ENUM(NSUInteger, FSCalendarMonthPosition);

struct FSCalendarCoordinate {
    NSInteger row;
    NSInteger column;
};
typedef struct FSCalendarCoordinate FSCalendarCoordinate;

@interface FSCalendarCalculator : NSObject

@property (weak  , nonatomic) FSCalendar *calendar;

@property (assign, nonatomic) CGFloat titleHeight;
@property (assign, nonatomic) CGFloat subtitleHeight;

@property (readonly, nonatomic) NSInteger numberOfSections;

- (instancetype)initWithCalendar:(FSCalendar *)calendar;

- (NSDate *)safeDateForDate:(NSDate *)date;

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath scope:(FSCalendarScope)scope;
- (NSIndexPath *)indexPathForDate:(NSDate *)date;
- (NSIndexPath *)indexPathForDate:(NSDate *)date scope:(FSCalendarScope)scope;
- (NSIndexPath *)indexPathForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position;
- (NSIndexPath *)indexPathForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position scope:(FSCalendarScope)scope;

- (NSDate *)pageForSection:(NSInteger)section;
- (NSDate *)weekForSection:(NSInteger)section;
- (NSDate *)monthForSection:(NSInteger)section;
- (NSDate *)monthHeadForSection:(NSInteger)section;

- (NSInteger)numberOfHeadPlaceholdersForMonth:(NSDate *)month;
- (NSInteger)numberOfRowsInMonth:(NSDate *)month;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

- (FSCalendarMonthPosition)monthPositionForIndexPath:(NSIndexPath *)indexPath;
- (FSCalendarCoordinate)coordinateForIndexPath:(NSIndexPath *)indexPath;

- (void)reloadSections;

@end
