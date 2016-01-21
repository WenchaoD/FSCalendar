//
//  FSCalendarAnimationLayout.h
//  FSCalendar
//
//  Created by dingwenchao on 1/3/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSCalendar;

typedef NS_ENUM(NSUInteger, FSCalendarScope);
typedef NS_ENUM(NSUInteger, FSCalendarTransition) {
    FSCalendarTransitionNone,
    FSCalendarTransitionMonthToWeek,
    FSCalendarTransitionWeekToMonth
};
typedef NS_ENUM(NSUInteger, FSCalendarTransitionState) {
    FSCalendarTransitionStateIdle,
    FSCalendarTransitionStateInProgress
};

@interface FSCalendarFlowLayout : UICollectionViewFlowLayout <UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) FSCalendar *calendar;
@property (assign, nonatomic) FSCalendarTransition transition;
@property (assign, nonatomic) FSCalendarTransitionState state;

- (void)performScopeTransitionFromScope:(FSCalendarScope)fromScope toScope:(FSCalendarScope)toScope animated:(BOOL)animated;
- (void)performTransition:(BOOL)animated;


@end
