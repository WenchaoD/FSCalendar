//
//  FSCalendarTransitionCoordinator.h
//  FSCalendar
//
//  Created by dingwenchao on 3/13/16.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendar.h"
#import "FSCalendarCollectionView.h"
#import "FSCalendarCollectionViewLayout.h"

typedef NS_ENUM(NSUInteger, FSCalendarTransitionState) {
    FSCalendarTransitionStateIdle,
    FSCalendarTransitionStateChanging,
    FSCalendarTransitionStateFinishing,
};

@interface FSCalendarTransitionAttributes : NSObject

@property (assign, nonatomic) CGRect sourceBounds;
@property (assign, nonatomic) CGRect targetBounds;
@property (strong, nonatomic) NSDate *sourcePage;
@property (strong, nonatomic) NSDate *targetPage;
@property (assign, nonatomic) NSInteger focusedRow;
@property (strong, nonatomic) NSDate *focusedDate;
@property (assign, nonatomic) FSCalendarScope targetScope;

- (void)revert;

@end

@interface FSCalendarTransitionCoordinator : NSObject <UIGestureRecognizerDelegate>

@property (assign, nonatomic) FSCalendarTransitionState state;

@property (assign, nonatomic) CGSize cachedMonthSize;

@property (readonly, nonatomic) FSCalendarScope representingScope;

@property (weak, nonatomic) FSCalendarCollectionView *collectionView;

@property (weak, nonatomic) FSCalendarCollectionViewLayout *collectionViewLayout;

@property (weak, nonatomic) FSCalendar *calendar;

@property (strong, nonatomic) FSCalendarTransitionAttributes *transitionAttributes;

- (FSCalendarTransitionAttributes *)createTransitionAttributesTargetingScope:(FSCalendarScope)targetScope;

- (instancetype)initWithCalendar:(FSCalendar *)calendar;

- (void)performScopeTransitionFromScope:(FSCalendarScope)fromScope toScope:(FSCalendarScope)toScope animated:(BOOL)animated;
- (void)performBoundingRectTransitionFromMonth:(NSDate *)fromMonth toMonth:(NSDate *)toMonth duration:(CGFloat)duration;
- (void)performTransition:(FSCalendarScope)targetScope fromProgress:(CGFloat)fromProgress toProgress:(CGFloat)toProgress animated:(BOOL)animated;
- (void)performTransitionCompletionAnimated:(BOOL)animated;

- (void)performAlphaAnimationWithProgress:(CGFloat)progress;
- (void)performPathAnimationWithProgress:(CGFloat)progress;

- (CGRect)boundingRectForScope:(FSCalendarScope)scope page:(NSDate *)page;

- (void)handleScopeGesture:(id)sender;

- (void)scopeTransitionDidBegin:(UIPanGestureRecognizer *)panGesture;
- (void)scopeTransitionDidUpdate:(UIPanGestureRecognizer *)panGesture;
- (void)scopeTransitionDidEnd:(UIPanGestureRecognizer *)panGesture;

- (void)boundingRectWillChange:(CGRect)targetBounds animated:(BOOL)animated;

- (void)prepareWeekToMonthTransition;

@end
