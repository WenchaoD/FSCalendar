//
//  FSCalendarTransitionCoordinator.m
//  FSCalendar
//
//  Created by Wenchao Ding on 3/13/16.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendarTransitionCoordinator.h"
#import "FSCalendarExtensions.h"
#import "FSCalendarDynamicHeader.h"

@interface FSCalendarTransitionCoordinator ()

@property (weak, nonatomic) FSCalendarCollectionView *collectionView;
@property (weak, nonatomic) FSCalendarCollectionViewLayout *collectionViewLayout;
@property (weak, nonatomic) FSCalendar *calendar;

@property (strong, nonatomic) FSCalendarTransitionAttributes *transitionAttributes;

- (FSCalendarTransitionAttributes *)createTransitionAttributesTargetingScope:(FSCalendarScope)targetScope;

- (void)performTransitionCompletionAnimated:(BOOL)animated;

- (void)performAlphaAnimationWithProgress:(CGFloat)progress;
- (void)performPathAnimationWithProgress:(CGFloat)progress;

- (void)scopeTransitionDidBegin:(UIPanGestureRecognizer *)panGesture;
- (void)scopeTransitionDidUpdate:(UIPanGestureRecognizer *)panGesture;
- (void)scopeTransitionDidEnd:(UIPanGestureRecognizer *)panGesture;

- (void)boundingRectWillChange:(CGRect)targetBounds animated:(BOOL)animated;

@end

@implementation FSCalendarTransitionCoordinator

- (instancetype)initWithCalendar:(FSCalendar *)calendar
{
    self = [super init];
    if (self) {
        self.calendar = calendar;
        self.collectionView = self.calendar.collectionView;
        self.collectionViewLayout = self.calendar.collectionViewLayout;
    }
    return self;
}

#pragma mark - Target actions

- (void)handleScopeGesture:(UIPanGestureRecognizer *)sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            [self scopeTransitionDidBegin:sender];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self scopeTransitionDidUpdate:sender];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:{
            [self scopeTransitionDidEnd:sender];
            break;
        }
        default: {
            break;
        }
    }
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.state != FSCalendarTransitionStateIdle) {
        return NO;
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    
    if (gestureRecognizer == self.calendar.scopeGesture && self.calendar.collectionViewLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return NO;
    }
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [[gestureRecognizer valueForKey:@"_targets"] containsObject:self.calendar]) {
        CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureRecognizer.view];
        BOOL shouldStart = self.calendar.scope == FSCalendarScopeWeek ? velocity.y >= 0 : velocity.y <= 0;
        if (!shouldStart) return NO;
        shouldStart = (ABS(velocity.x)<=ABS(velocity.y));
        if (shouldStart) {
            self.calendar.collectionView.panGestureRecognizer.enabled = NO;
            self.calendar.collectionView.panGestureRecognizer.enabled = YES;
        }
        return shouldStart;
    }
    return YES;
    
#pragma GCC diagnostic pop
    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return otherGestureRecognizer == self.collectionView.panGestureRecognizer && self.collectionView.decelerating;
}

- (void)scopeTransitionDidBegin:(UIPanGestureRecognizer *)panGesture
{
    if (self.state != FSCalendarTransitionStateIdle) return;
    
    CGPoint velocity = [panGesture velocityInView:panGesture.view];
    if (self.calendar.scope == FSCalendarScopeMonth && velocity.y >= 0) {
        return;
    }
    if (self.calendar.scope == FSCalendarScopeWeek && velocity.y <= 0) {
        return;
    }
    self.state = FSCalendarTransitionStateChanging;
    
    self.transitionAttributes = [self createTransitionAttributesTargetingScope:1-self.calendar.scope];
    
    if (self.transitionAttributes.targetScope == FSCalendarScopeMonth) {
        [self prepareWeekToMonthTransition];
    }
}

- (void)scopeTransitionDidUpdate:(UIPanGestureRecognizer *)panGesture
{
    if (self.state != FSCalendarTransitionStateChanging) return;
    
    CGFloat translation = ABS([panGesture translationInView:panGesture.view].y);
    CGFloat progress = ({
        CGFloat maxTranslation = ABS(CGRectGetHeight(self.transitionAttributes.targetBounds) - CGRectGetHeight(self.transitionAttributes.sourceBounds));
        translation = MIN(maxTranslation, translation);
        translation = MAX(0, translation);
        CGFloat progress = translation/maxTranslation;
        progress;
    });
    [self performAlphaAnimationWithProgress:progress];
    [self performPathAnimationWithProgress:progress];
}

- (void)scopeTransitionDidEnd:(UIPanGestureRecognizer *)panGesture
{
    if (self.state != FSCalendarTransitionStateChanging) return;
    
    self.state = FSCalendarTransitionStateFinishing;

    CGFloat translation = [panGesture translationInView:panGesture.view].y;
    CGFloat velocity = [panGesture velocityInView:panGesture.view].y;
    
    CGFloat progress = ({
        CGFloat maxTranslation = CGRectGetHeight(self.transitionAttributes.targetBounds) - CGRectGetHeight(self.transitionAttributes.sourceBounds);
        translation = MAX(0, translation);
        translation = MIN(maxTranslation, translation);
        CGFloat progress = translation/maxTranslation;
        progress;
    });
    if (velocity * translation < 0) {
        [self.transitionAttributes revert];
    }
    [self performTransition:self.transitionAttributes.targetScope fromProgress:progress toProgress:1.0 animated:YES];
}

#pragma mark - Public methods

- (void)performScopeTransitionFromScope:(FSCalendarScope)fromScope toScope:(FSCalendarScope)toScope animated:(BOOL)animated
{
    if (fromScope == toScope) {
        [self.calendar willChangeValueForKey:@"scope"];
        [self.calendar fs_setUnsignedIntegerVariable:toScope forKey:@"_scope"];
        [self.calendar didChangeValueForKey:@"scope"];
        return;
    }
    // Start transition
    self.state = FSCalendarTransitionStateFinishing;
    FSCalendarTransitionAttributes *attr = [self createTransitionAttributesTargetingScope:toScope];
    self.transitionAttributes = attr;
    if (toScope == FSCalendarScopeMonth) {
        [self prepareWeekToMonthTransition];
    }
    [self performTransition:self.transitionAttributes.targetScope fromProgress:0 toProgress:1 animated:animated];
}

- (void)performBoundingRectTransitionFromMonth:(NSDate *)fromMonth toMonth:(NSDate *)toMonth duration:(CGFloat)duration
{
    if (!self.calendar.adjustsBoundingRectWhenChangingMonths) return;
    if (self.calendar.scope != FSCalendarScopeMonth) return;
    NSInteger lastRowCount = [self.calendar.calculator numberOfRowsInMonth:fromMonth];
    NSInteger currentRowCount = [self.calendar.calculator numberOfRowsInMonth:toMonth];
    if (lastRowCount != currentRowCount) {
        CGFloat animationDuration = duration;
        CGRect bounds = [self boundingRectForScope:FSCalendarScopeMonth page:toMonth];
        self.state = FSCalendarTransitionStateChanging;
        void (^completion)(BOOL) = ^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MAX(0, duration-animationDuration) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.calendar.needsAdjustingViewFrame = YES;
                [self.calendar setNeedsLayout];
                self.state = FSCalendarTransitionStateIdle;
            });
        };
        if (FSCalendarInAppExtension) {
            // Detect today extension: http://stackoverflow.com/questions/25048026/ios-8-extension-how-to-detect-running
            [self boundingRectWillChange:bounds animated:YES];
            completion(YES);
        } else {
            [UIView animateWithDuration:animationDuration delay:0  options:UIViewAnimationOptionAllowUserInteraction animations:^{
                [self boundingRectWillChange:bounds animated:YES];
            } completion:completion];
        }
        
    }
}

#pragma mark - Private properties

- (void)performTransitionCompletionAnimated:(BOOL)animated
{
    switch (self.transitionAttributes.targetScope) {
        case FSCalendarScopeWeek: {
            self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            self.calendar.calendarHeaderView.scrollDirection = self.collectionViewLayout.scrollDirection;
            self.calendar.needsAdjustingViewFrame = YES;
            [self.collectionView reloadData];
            [self.calendar.calendarHeaderView reloadData];
            break;
        }
        case FSCalendarScopeMonth: {
            self.calendar.needsAdjustingViewFrame = YES;
            break;
        }
        default:
            break;
    }
    self.state = FSCalendarTransitionStateIdle;
    self.transitionAttributes = nil;
    [self.calendar setNeedsLayout];
    [self.calendar layoutIfNeeded];
}

- (FSCalendarTransitionAttributes *)createTransitionAttributesTargetingScope:(FSCalendarScope)targetScope
{
    FSCalendarTransitionAttributes *attributes = [[FSCalendarTransitionAttributes alloc] init];
    attributes.sourceBounds = self.calendar.bounds;
    attributes.sourcePage = self.calendar.currentPage;
    attributes.targetScope = targetScope;
    attributes.focusedDate = ({
        NSArray<NSDate *> *candidates = ({
            NSMutableArray *dates = self.calendar.selectedDates.reverseObjectEnumerator.allObjects.mutableCopy;
            if (self.calendar.today) {
                [dates addObject:self.calendar.today];
            }
            if (targetScope == FSCalendarScopeWeek) {
                [dates addObject:self.calendar.currentPage];
            } else {
                [dates addObject:[self.calendar.gregorian dateByAddingUnit:NSCalendarUnitDay value:3 toDate:self.calendar.currentPage options:0]];
            }
            dates.copy;
        });
        NSArray<NSDate *> *visibleCandidates = [candidates filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDate *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            NSIndexPath *indexPath = [self.calendar.calculator indexPathForDate:evaluatedObject scope:1-targetScope];
            NSInteger currentSection = [self.calendar.calculator indexPathForDate:self.calendar.currentPage scope:1-targetScope].section;
            return indexPath.section == currentSection;
        }]];
        NSDate *date = visibleCandidates.firstObject;
        date;
    });
    attributes.focusedRow = ({
        NSIndexPath *indexPath = [self.calendar.calculator indexPathForDate:attributes.focusedDate scope:FSCalendarScopeMonth];
        FSCalendarCoordinate coordinate = [self.calendar.calculator coordinateForIndexPath:indexPath];
        coordinate.row;
    });
    attributes.targetPage = ({
        NSDate *targetPage = targetScope == FSCalendarScopeMonth ? [self.calendar.gregorian fs_firstDayOfMonth:attributes.focusedDate] : [self.calendar.gregorian fs_middleDayOfWeek:attributes.focusedDate];
        targetPage;
    });
    attributes.targetBounds = [self boundingRectForScope:attributes.targetScope page:attributes.targetPage];
    return attributes;
}

#pragma mark - Private properties

- (FSCalendarScope)representingScope
{
    switch (self.state) {
        case FSCalendarTransitionStateIdle: {
            return self.calendar.scope;
        }
        case FSCalendarTransitionStateChanging:
        case FSCalendarTransitionStateFinishing: {
            return FSCalendarScopeMonth;
        }
    }
}

#pragma mark - Private methods

- (CGRect)boundingRectForScope:(FSCalendarScope)scope page:(NSDate *)page
{
    CGSize contentSize;
    switch (scope) {
        case FSCalendarScopeMonth: {
            contentSize = self.calendar.adjustsBoundingRectWhenChangingMonths ? [self.calendar sizeThatFits:self.calendar.frame.size scope:scope] : self.cachedMonthSize;
            break;
        }
        case FSCalendarScopeWeek: {
            contentSize = [self.calendar sizeThatFits:self.calendar.frame.size scope:scope];
            break;
        }
    }
    return (CGRect){CGPointZero, contentSize};
}

- (void)boundingRectWillChange:(CGRect)targetBounds animated:(BOOL)animated
{
    self.calendar.contentView.fs_height = CGRectGetHeight(targetBounds);
    self.calendar.daysContainer.fs_height = CGRectGetHeight(targetBounds)-self.calendar.preferredHeaderHeight-self.calendar.preferredWeekdayHeight;
    [[self.calendar valueForKey:@"delegateProxy"] calendar:self.calendar boundingRectWillChange:targetBounds animated:animated];
}

- (void)performTransition:(FSCalendarScope)targetScope fromProgress:(CGFloat)fromProgress toProgress:(CGFloat)toProgress animated:(BOOL)animated
{
    FSCalendarTransitionAttributes *attr = self.transitionAttributes;
    
    [self.calendar willChangeValueForKey:@"scope"];
    [self.calendar fs_setUnsignedIntegerVariable:targetScope forKey:@"_scope"];
    if (targetScope == FSCalendarScopeWeek) {
        [self.calendar fs_setVariable:attr.targetPage forKey:@"_currentPage"];
    }
    [self.calendar didChangeValueForKey:@"scope"];
    
    if (animated) {
        if (self.calendar.delegate && ([self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)])) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self performAlphaAnimationWithProgress:toProgress];
                self.collectionView.fs_top = [self calculateOffsetForProgress:toProgress];
                [self boundingRectWillChange:attr.targetBounds animated:YES];
            } completion:^(BOOL finished) {
                [self performTransitionCompletionAnimated:YES];
            }];
        }
    } else {
        [self performTransitionCompletionAnimated:animated];
        [self boundingRectWillChange:attr.targetBounds animated:animated];
    }
}

- (void)performAlphaAnimationWithProgress:(CGFloat)progress
{
    CGFloat opacity = self.transitionAttributes.targetScope == FSCalendarScopeWeek ? MAX((1-progress*1.1), 0) : progress;
    NSArray<FSCalendarCell *> *surroundingCells = [self.calendar.visibleCells filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSCalendarCell *  _Nullable cell, NSDictionary<NSString *,id> * _Nullable bindings) {
        if (!CGRectContainsPoint(self.collectionView.bounds, cell.center)) {
            return NO;
        }
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        NSInteger row = [self.calendar.calculator coordinateForIndexPath:indexPath].row;
        return row != self.transitionAttributes.focusedRow;
    }]];
    [surroundingCells setValue:@(opacity) forKey:@"alpha"];
}

- (void)performPathAnimationWithProgress:(CGFloat)progress
{
    CGFloat targetHeight = CGRectGetHeight(self.transitionAttributes.targetBounds);
    CGFloat sourceHeight = CGRectGetHeight(self.transitionAttributes.sourceBounds);
    CGFloat currentHeight = sourceHeight - (sourceHeight-targetHeight)*progress;
    CGRect currentBounds = CGRectMake(0, 0, CGRectGetWidth(self.transitionAttributes.targetBounds), currentHeight);
    self.collectionView.fs_top = [self calculateOffsetForProgress:progress];
    [self boundingRectWillChange:currentBounds animated:NO];
    if (self.transitionAttributes.targetScope == FSCalendarScopeMonth) {
        self.calendar.contentView.fs_height = targetHeight;
    }
}

- (CGFloat)calculateOffsetForProgress:(CGFloat)progress
{
    NSIndexPath *indexPath = [self.calendar.calculator indexPathForDate:self.transitionAttributes.focusedDate scope:FSCalendarScopeMonth];
    CGRect frame = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath].frame;
    CGFloat ratio = self.transitionAttributes.targetScope == FSCalendarScopeWeek ? progress : (1 - progress);
    CGFloat offset = (-frame.origin.y + self.collectionViewLayout.sectionInsets.top) * ratio;
    return offset;
}

- (void)prepareWeekToMonthTransition
{
    [self.calendar fs_setVariable:self.transitionAttributes.targetPage forKey:@"_currentPage"];
    self.calendar.contentView.fs_height = CGRectGetHeight(self.transitionAttributes.targetBounds);
    self.collectionViewLayout.scrollDirection = (UICollectionViewScrollDirection)self.calendar.scrollDirection;
    self.calendar.calendarHeaderView.scrollDirection = self.collectionViewLayout.scrollDirection;
    self.calendar.needsAdjustingViewFrame = YES;
    
    [CATransaction begin];
    [CATransaction setDisableActions:NO];
    [self.collectionView reloadData];
    [self.calendar.calendarHeaderView reloadData];
    [self.calendar layoutIfNeeded];
    [CATransaction commit];
    
    self.collectionView.fs_top = [self calculateOffsetForProgress:0];
}

@end

@implementation FSCalendarTransitionAttributes

- (void)revert
{
    CGRect tempRect = self.sourceBounds;
    self.sourceBounds = self.targetBounds;
    self.targetBounds = tempRect;

    NSDate *tempDate = self.sourcePage;
    self.sourcePage = self.targetPage;
    self.targetPage = tempDate;
    
    self.targetScope = 1 - self.targetScope;
}
    
@end
