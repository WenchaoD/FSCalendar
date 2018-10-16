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

@interface FSCalendarTransitionCoordinator : NSObject <UIGestureRecognizerDelegate>

@property (assign, nonatomic) FSCalendarTransitionState state;

@property (assign, nonatomic) CGSize cachedMonthSize;

@property (readonly, nonatomic) FSCalendarScope representingScope;

- (instancetype)initWithCalendar:(FSCalendar *)calendar;

- (void)performScopeTransitionFromScope:(FSCalendarScope)fromScope toScope:(FSCalendarScope)toScope animated:(BOOL)animated;
- (void)performBoundingRectTransitionFromMonth:(NSDate *)fromMonth toMonth:(NSDate *)toMonth duration:(CGFloat)duration;
- (CGRect)boundingRectForScope:(FSCalendarScope)scope page:(NSDate *)page;

- (void)handleScopeGesture:(id)sender;

@end


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

