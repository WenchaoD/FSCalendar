//
//  FSCalendarAnimator.h
//  FSCalendar
//
//  Created by dingwenchao on 3/13/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "FSCalendar.h"
#import "FSCalendarCollectionView.h"
#import "FSCalendarFlowLayout.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarScopeHandle.h"

typedef NS_ENUM(NSUInteger, FSCalendarTransition) {
    FSCalendarTransitionNone,
    FSCalendarTransitionMonthToWeek,
    FSCalendarTransitionWeekToMonth
};
typedef NS_ENUM(NSUInteger, FSCalendarTransitionState) {
    FSCalendarTransitionStateIdle,
    FSCalendarTransitionStateInProgress
};

@interface FSCalendarAnimator : NSObject <FSCalendarScopeHandleDelegate>

@property (weak, nonatomic) FSCalendar *calendar;
@property (weak, nonatomic) FSCalendarCollectionView *collectionView;
@property (weak, nonatomic) FSCalendarFlowLayout *collectionViewLayout;

@property (assign, nonatomic) FSCalendarTransition transition;
@property (assign, nonatomic) FSCalendarTransitionState state;

@property (assign, nonatomic) CGSize cachedMonthSize;

- (void)performScopeTransitionFromScope:(FSCalendarScope)fromScope toScope:(FSCalendarScope)toScope animated:(BOOL)animated;
- (void)performBoudingRectTransitionFromMonth:(NSDate *)fromMonth toMonth:(NSDate *)toMonth duration:(CGFloat)duration;

@end


@interface FSCalendarTransitionAttributes : NSObject

@property (assign, nonatomic) CGRect sourceBounds;
@property (assign, nonatomic) CGRect targetBounds;
@property (strong, nonatomic) UIBezierPath *sourceMask;
@property (strong, nonatomic) UIBezierPath *targetMask;
@property (strong, nonatomic) NSDate *sourcePage;
@property (strong, nonatomic) NSDate *targetPage;
@property (assign, nonatomic) NSInteger focusedRowNumber;
@property (assign, nonatomic) NSDate *focusedDate;
@property (strong, nonatomic) NSDate *firstDayOfMonth;

@end

