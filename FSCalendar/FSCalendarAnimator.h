//
//  FSCalendarAnimator.h
//  FSCalendar
//
//  Created by dingwenchao on 3/13/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSCalendar.h"
#import "FSCalendarCollectionView.h"
#import "FSCalendarFlowLayout.h"
#import "FSCalendarDynamicHeader.h"

typedef NS_ENUM(NSUInteger, FSCalendarTransition) {
    FSCalendarTransitionNone,
    FSCalendarTransitionMonthToWeek,
    FSCalendarTransitionWeekToMonth
};
typedef NS_ENUM(NSUInteger, FSCalendarTransitionState) {
    FSCalendarTransitionStateIdle,
    FSCalendarTransitionStateInProgress
};

@interface FSCalendarAnimator : NSObject

@property (weak, nonatomic) FSCalendar *calendar;
@property (weak, nonatomic) FSCalendarCollectionView *collectionView;
@property (weak, nonatomic) FSCalendarFlowLayout *collectionViewLayout;

@property (assign, nonatomic) FSCalendarTransition transition;
@property (assign, nonatomic) FSCalendarTransitionState state;

- (void)performScopeTransitionFromScope:(FSCalendarScope)fromScope toScope:(FSCalendarScope)toScope animated:(BOOL)animated;
- (void)performBoudingRectTransitionFromMonth:(NSDate *)fromMonth toMonth:(NSDate *)toMonth duration:(CGFloat)duration;

@end
