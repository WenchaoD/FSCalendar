//
//  FSCalendarAnimator.m
//  FSCalendar
//
//  Created by Wenchao Ding on 3/13/16.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendarAnimator.h"
#import "UIView+FSExtension.h"
#import <objc/runtime.h>

@interface FSCalendarAnimator ()

@property (readonly, nonatomic) FSCalendarTransitionAttributes *transitionAttributes;
@property (strong  , nonatomic) FSCalendarTransitionAttributes *pendingAttributes;
@property (assign  , nonatomic) CGFloat lastTranslation;

@property (assign  , nonatomic) FSCalendarScope calendarScope;
@property (strong  , nonatomic) NSDate *calendarCurrentPage;

- (void)performTransitionCompletionAnimated:(BOOL)animated;
- (void)performTransitionCompletion:(FSCalendarTransition)transition animated:(BOOL)animated;

- (void)performAlphaAnimationFrom:(CGFloat)fromAlpha to:(CGFloat)toAlpha duration:(CGFloat)duration exception:(NSInteger)exception;
- (void)performPathAnimationFrom:(CGPathRef)fromPath to:(CGPathRef)toPath duration:(CGFloat)duration completion:(void(^)())completion;
- (void)performForwardTransition:(FSCalendarTransition)transition fromProgress:(CGFloat)progress;
- (void)performBackwardTransition:(FSCalendarTransition)transition fromProgress:(CGFloat)progress;
- (void)performAlphaAnimationWithProgress:(CGFloat)progress;
- (void)performPathAnimationWithProgress:(CGFloat)progress;

- (CGRect)boundingRectForScope:(FSCalendarScope)scope;

- (void)boundingRectWillChange:(CGRect)targetBounds animated:(BOOL)animated;

@end

@implementation FSCalendarAnimator

#pragma mark - Public methods

- (void)performScopeTransitionFromScope:(FSCalendarScope)fromScope toScope:(FSCalendarScope)toScope animated:(BOOL)animated
{
    if (fromScope == toScope) {
        self.transition = FSCalendarTransitionNone;
        return;
    }
    if (fromScope == FSCalendarScopeMonth && toScope == FSCalendarScopeWeek) {
        self.transition = FSCalendarTransitionMonthToWeek;
    } else if (fromScope == FSCalendarScopeWeek && toScope == FSCalendarScopeMonth) {
        self.transition = FSCalendarTransitionWeekToMonth;
    }
    
    // Start transition
    self.state = FSCalendarTransitionStateInProgress;
    FSCalendarTransitionAttributes *attr = self.transitionAttributes;
    self.pendingAttributes = attr;
    
    switch (self.transition) {
            
        case FSCalendarTransitionMonthToWeek: {
            
            self.calendarCurrentPage = attr.targetPage;
            self.calendar.contentView.clipsToBounds = YES;
            
            if (animated) {
                CGFloat duration = 0.3;
                
                [self performAlphaAnimationFrom:1 to:0 duration:0.22 exception:attr.focusedRowNumber];
                [self performPathAnimationFrom:self.calendar.maskLayer.path to:attr.targetMask.CGPath duration:duration completion:^{
                    [self performTransitionCompletionAnimated:animated];
                }];

                if (self.calendar.delegate && ([self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)] || [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)])) {
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationsEnabled:YES];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    [UIView setAnimationDuration:duration];
                    self.collectionView.fs_top = -attr.focusedRowNumber*self.calendar.preferredRowHeight;
                    [self boundingRectWillChange:attr.targetBounds animated:animated];
                    [UIView commitAnimations];
                }
                
            } else {
                
                [self performTransitionCompletionAnimated:animated];
                [self boundingRectWillChange:attr.targetBounds animated:animated];
                
            }
            
            break;
        }
            
        case FSCalendarTransitionWeekToMonth: {
            
            self.calendarCurrentPage = attr.targetPage;
            self.collectionViewLayout.scrollDirection = (UICollectionViewScrollDirection)self.calendar.scrollDirection;
            self.calendar.header.scrollDirection = self.collectionViewLayout.scrollDirection;
            
            self.calendar.needsAdjustingMonthPosition = YES;
            self.calendar.needsAdjustingViewFrame = YES;
            [self.calendar layoutSubviews];
            [self.collectionView reloadData];
            [self.collectionView layoutIfNeeded];
            [self.calendar.header reloadData];
            [self.calendar.header layoutIfNeeded];
            
            self.calendar.contentView.clipsToBounds = YES;
            
            if (animated) {
                
                [self performAlphaAnimationFrom:0 to:1 duration:0.4 exception:attr.focusedRowNumber];
                
                CGFloat duration = 0.3;
                
                [self performPathAnimationFrom:self.calendar.maskLayer.path to:attr.targetMask.CGPath duration:duration completion:^{
                    [self performTransitionCompletionAnimated:animated];
                }];
                
                [CATransaction begin];
                [CATransaction setDisableActions:NO];
                if (self.calendar.delegate && ([self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)] || [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)])) {
                    self.collectionView.fs_top = -attr.focusedRowNumber*self.calendar.preferredRowHeight;
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationsEnabled:YES];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    [UIView setAnimationDuration:duration];
                    self.collectionView.fs_top = 0;
                    [self boundingRectWillChange:attr.targetBounds animated:animated];
                    [UIView commitAnimations];
                }
                [CATransaction commit];
                
            } else {
                
                [self performTransitionCompletionAnimated:animated];
                [self boundingRectWillChange:attr.targetBounds animated:animated];
                
            }
            break;
        }
        default:
            break;
    }
    
}

- (void)performBoudingRectTransitionFromMonth:(NSDate *)fromMonth toMonth:(NSDate *)toMonth duration:(CGFloat)duration
{
    NSInteger lastRowCount = [self.calendar numberOfRowsInMonth:fromMonth];
    NSInteger currentRowCount = [self.calendar numberOfRowsInMonth:toMonth];
    if (lastRowCount != currentRowCount) {
        CGFloat animationDuration = duration;
        CGRect bounds = (CGRect){CGPointZero,[self.calendar sizeThatFits:self.calendar.frame.size]};
        self.state = FSCalendarTransitionStateInProgress;
        [UIView animateWithDuration:animationDuration delay:0  options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [self boundingRectWillChange:bounds animated:YES];
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MAX(0, duration-animationDuration) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.calendar.needsAdjustingViewFrame = YES;
                [self.calendar setNeedsLayout];
                self.state = FSCalendarTransitionStateIdle;
            });
        }];
        
        CABasicAnimation *path = [CABasicAnimation animationWithKeyPath:@"path"];
        path.fromValue = (id)self.calendar.maskLayer.path;
        path.toValue = (id)[UIBezierPath bezierPathWithRect:bounds].CGPath;
        path.duration = animationDuration*(currentRowCount>lastRowCount?1.25:0.75);
        path.removedOnCompletion = NO;
        path.fillMode = kCAFillModeForwards;
        [self.calendar.maskLayer addAnimation:path forKey:@"path"];
        
    }
}

#pragma mark - <FSCalendarScopeHandleDelegate>

- (void)scopeHandleDidBegin:(FSCalendarScopeHandle *)scopeHandle
{
    self.state = FSCalendarTransitionStateInProgress;
    self.transition = self.calendar.scope == FSCalendarScopeMonth ? FSCalendarTransitionMonthToWeek : FSCalendarTransitionWeekToMonth;
    self.pendingAttributes = self.transitionAttributes;
    self.lastTranslation = [scopeHandle.panGesture translationInView:scopeHandle].y;
    
    if (self.transition == FSCalendarTransitionWeekToMonth) {
        
        self.calendarScope = FSCalendarScopeMonth;
        self.calendarCurrentPage = self.pendingAttributes.targetPage;
        self.calendar.contentView.clipsToBounds = YES;
        
        self.calendar.contentView.fs_height = CGRectGetHeight(self.pendingAttributes.targetBounds)-self.calendar.scopeHandle.fs_height;
        self.collectionViewLayout.scrollDirection = (UICollectionViewScrollDirection)self.calendar.scrollDirection;
        self.calendar.header.scrollDirection = self.collectionViewLayout.scrollDirection;
        self.calendar.needsAdjustingMonthPosition = YES;
        self.calendar.needsAdjustingViewFrame = YES;
        [self.calendar setNeedsLayout];
        [self.collectionView reloadData];
        [self.calendar.header reloadData];
        [self.calendar layoutIfNeeded];
        
        self.collectionView.fs_top = -self.pendingAttributes.focusedRowNumber*self.calendar.preferredRowHeight;
        
    }
}

- (void)scopeHandleDidUpdate:(FSCalendarScopeHandle *)scopeHandle
{
    CGFloat translation = [scopeHandle.panGesture translationInView:scopeHandle].y;
    switch (self.transition) {
        case FSCalendarTransitionMonthToWeek: {
            CGFloat minTranslation = CGRectGetHeight(self.pendingAttributes.targetBounds) - CGRectGetHeight(self.pendingAttributes.sourceBounds);
            translation = MAX(minTranslation, translation);
            translation = MIN(0, translation);
            CGFloat progress = translation/minTranslation;
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [self performAlphaAnimationWithProgress:progress];
            [self performPathAnimationWithProgress:progress];
            [CATransaction commit];
            break;
        }
        case FSCalendarTransitionWeekToMonth: {
            CGFloat maxTranslation = CGRectGetHeight(self.pendingAttributes.targetBounds) - CGRectGetHeight(self.pendingAttributes.sourceBounds);
            translation = MIN(maxTranslation, translation);
            translation = MAX(0, translation);
            CGFloat progress = translation/maxTranslation;
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [self performAlphaAnimationWithProgress:progress];
            [self performPathAnimationWithProgress:progress];
            [CATransaction commit];
            break;
        }
        default:
            break;
    }
    self.lastTranslation = translation;
}

- (void)scopeHandleDidEnd:(FSCalendarScopeHandle *)scopeHandle
{
    CGFloat translation = [scopeHandle.panGesture translationInView:scopeHandle].y;
    CGFloat velocity = [scopeHandle.panGesture velocityInView:scopeHandle].y;
    switch (self.transition) {
        case FSCalendarTransitionMonthToWeek: {
            
            CGFloat minTranslation = CGRectGetHeight(self.pendingAttributes.targetBounds) - CGRectGetHeight(self.pendingAttributes.sourceBounds);
            translation = MAX(minTranslation, translation);
            translation = MIN(0, translation);
            CGFloat progress = translation/minTranslation;
            if (velocity >= 0) {
                
                [self performBackwardTransition:self.transition fromProgress:progress];
                
            } else {
                
                [self performForwardTransition:self.transition fromProgress:progress];
                
            }
            break;
        }
        case FSCalendarTransitionWeekToMonth: {
            CGFloat maxTranslation = CGRectGetHeight(self.pendingAttributes.targetBounds) - CGRectGetHeight(self.pendingAttributes.sourceBounds);
            translation = MAX(0, translation);
            translation = MIN(maxTranslation, translation);
            CGFloat progress = translation/maxTranslation;
            
            if (velocity >= 0) {
                
                [self performForwardTransition:self.transition fromProgress:progress];
                
            } else {
                
                [self performBackwardTransition:self.transition fromProgress:progress];
                
            }
            
        }
        default:
            break;
    }
    
}


#pragma mark - Private properties

- (void)performTransitionCompletionAnimated:(BOOL)animated
{
    [self performTransitionCompletion:self.transition animated:animated];
}

- (void)performTransitionCompletion:(FSCalendarTransition)transition animated:(BOOL)animated
{
    switch (transition) {
        case FSCalendarTransitionMonthToWeek: {
            [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(UICollectionViewCell *obj, NSUInteger idx, BOOL * stop) {
                obj.contentView.layer.opacity = 1;
            }];
            self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            self.calendar.header.scrollDirection = self.collectionViewLayout.scrollDirection;
            self.calendar.needsAdjustingViewFrame = YES;
            self.calendar.needsAdjustingMonthPosition = YES;
            [self.collectionView reloadData];
            [self.calendar.header reloadData];
            break;
        }
        case FSCalendarTransitionWeekToMonth: {
            self.calendar.needsAdjustingViewFrame = YES;
            [self.calendar.collectionView.visibleCells enumerateObjectsUsingBlock:^(UICollectionViewCell *obj, NSUInteger idx, BOOL * stop) {
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                obj.contentView.layer.opacity = 1;
                [CATransaction commit];
                [obj.contentView.layer removeAnimationForKey:@"opacity"];
            }];
            break;
        }
        default:
            break;
    }
    self.state = FSCalendarTransitionStateIdle;
    self.transition = FSCalendarTransitionNone;
    self.calendar.contentView.clipsToBounds = NO;
    self.pendingAttributes = nil;
    [self.calendar.maskLayer removeAnimationForKey:@"path"];
    [self.calendar setNeedsLayout];
    [self.calendar layoutIfNeeded];
}

- (FSCalendarTransitionAttributes *)transitionAttributes
{
    FSCalendarTransitionAttributes *attributes = [[FSCalendarTransitionAttributes alloc] init];
    attributes.sourceBounds = self.calendar.bounds;
    attributes.sourceMask = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.calendar.fs_width, CGRectGetHeight(attributes.sourceBounds)-self.calendar.scopeHandle.fs_height)];
    attributes.sourcePage = self.calendarCurrentPage;
    switch (self.transition) {
            
        case FSCalendarTransitionMonthToWeek: {
            
            attributes.targetBounds = [self boundingRectForScope:FSCalendarScopeWeek];
            attributes.targetMask = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.calendar.fs_width, CGRectGetHeight(attributes.targetBounds)-self.calendar.scopeHandle.fs_height)];
            
            if (self.calendar.focusOnSingleSelectedDate) {
                
                NSInteger focusedRowNumber = 0;
                NSDate *focusedDate = self.calendar.selectedDate;
                
                if (focusedDate) {
                    UICollectionViewLayoutAttributes *attributes = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:[self.calendar indexPathForDate:focusedDate scope:FSCalendarScopeMonth]];
                    CGPoint focuedCenter = attributes.center;
                    if (CGRectContainsPoint(self.collectionView.bounds, focuedCenter)) {
                        switch (self.collectionViewLayout.scrollDirection) {
                            case UICollectionViewScrollDirectionHorizontal: {
                                focusedRowNumber = attributes.indexPath.item%6;
                                break;
                            }
                            case UICollectionViewScrollDirectionVertical: {
                                focusedRowNumber = attributes.indexPath.item/7;
                                break;
                            }
                        }
                    } else {
                        focusedDate = nil;
                    }
                }
                if (!focusedDate) {
                    focusedDate = self.calendar.today;
                    if (focusedDate) {
                        UICollectionViewLayoutAttributes *attributes = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:[self.calendar indexPathForDate:focusedDate scope:FSCalendarScopeMonth]];
                        CGPoint focuedCenter = attributes.center;
                        if (CGRectContainsPoint(self.collectionView.bounds, focuedCenter)) {
                            switch (self.collectionViewLayout.scrollDirection) {
                                case UICollectionViewScrollDirectionHorizontal: {
                                    focusedRowNumber = attributes.indexPath.item%6;
                                    break;
                                }
                                case UICollectionViewScrollDirectionVertical: {
                                    focusedRowNumber = attributes.indexPath.item/7;
                                    break;
                                }
                            }
                        }
                    }
                }
                
                NSDate *currentPage = self.calendar.currentPage;
                NSDate *minimumPage = [self.calendar beginingOfMonthOfDate:self.calendar.minimumDate];
                NSInteger visibleSection = [self.calendar monthsFromDate:minimumPage toDate:currentPage];
                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:visibleSection];
                NSDate *firstDate = [self.calendar dateForIndexPath:firstIndexPath scope:FSCalendarScopeMonth];
                currentPage = [self.calendar dateByAddingDays:focusedRowNumber*7 toDate:firstDate];
                
                attributes.focusedRowNumber = focusedRowNumber;
                attributes.focusedDate = focusedDate;
                attributes.targetPage = currentPage;
                
            }
            break;
        }
        case FSCalendarTransitionWeekToMonth: {
            
            attributes.targetBounds = [self boundingRectForScope:FSCalendarScopeMonth];
            attributes.targetMask = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.calendar.fs_width, CGRectGetHeight(attributes.targetBounds)-self.calendar.scopeHandle.fs_height)];
            
            if (self.calendar.focusOnSingleSelectedDate) {
                
                NSInteger focusedRowNumber = 0;
                NSDate *currentPage = self.calendar.currentPage;
                NSDate *firstDayOfMonth = nil;
                if (self.calendar.focusOnSingleSelectedDate) {
                    NSDate *focusedDate = self.calendar.selectedDate;
                    if (focusedDate) {
                        UICollectionViewLayoutAttributes *attributes = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:[self.calendar indexPathForDate:focusedDate scope:FSCalendarScopeWeek]];
                        CGPoint focuedCenter = attributes.center;
                        if (CGRectContainsPoint(self.collectionView.bounds, focuedCenter)) {
                            firstDayOfMonth = [self.calendar beginingOfMonthOfDate:focusedDate];
                        } else {
                            focusedDate = nil;
                        }
                    }
                    if (!focusedDate) {
                        focusedDate = self.calendar.today;
                        if (focusedDate) {
                            UICollectionViewLayoutAttributes *attributes = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:[self.calendar indexPathForDate:focusedDate scope:FSCalendarScopeWeek]];
                            CGPoint focuedCenter = attributes.center;
                            if (CGRectContainsPoint(self.collectionView.bounds, focuedCenter)) {
                                firstDayOfMonth = [self.calendar beginingOfMonthOfDate:focusedDate];
                            }
                        }
                    };
                    attributes.focusedDate = focusedDate;
                }
                firstDayOfMonth = firstDayOfMonth ?: [self.calendar beginingOfMonthOfDate:currentPage];
                NSInteger numberOfPlaceholdersForPrev = [self.calendar numberOfHeadPlaceholdersForMonth:firstDayOfMonth];
                NSDate *firstDateOfPage = [self.calendar dateBySubstractingDays:numberOfPlaceholdersForPrev fromDate:firstDayOfMonth];
                for (int i = 0; i < 6; i++) {
                    NSDate *currentRow = [self.calendar dateByAddingWeeks:i toDate:firstDateOfPage];
                    if ([self.calendar isDate:currentRow equalToDate:currentPage toCalendarUnit:FSCalendarUnitDay]) {
                        focusedRowNumber = i;
                        currentPage = firstDayOfMonth;
                        break;
                    }
                }
                attributes.focusedRowNumber = focusedRowNumber;
                attributes.targetPage = currentPage;
                attributes.firstDayOfMonth = firstDayOfMonth;
            }
            break;
        }
        default:
            break;
    }
    return attributes;
}

#pragma mark - Private properties

- (void)setCalendarScope:(FSCalendarScope)calendarScope
{
    [self.calendar willChangeValueForKey:@"scope"];
    Ivar scopeIvar = class_getInstanceVariable(FSCalendar.class, "_scope");
    void (*setScope)(id, Ivar, FSCalendarScope) = (void (*)(id, Ivar, FSCalendarScope))object_setIvar;
    setScope(self.calendar, scopeIvar, calendarScope);
    [self.calendar didChangeValueForKey:@"scope"];
}

- (FSCalendarScope)calendarScope
{
    return self.calendar.scope;
}

- (void)setCalendarCurrentPage:(NSDate *)calendarCurrentPage
{
    Ivar currentPageIvar = class_getInstanceVariable(FSCalendar.class, "_currentPage");
    object_setIvar(self.calendar, currentPageIvar, calendarCurrentPage);
}

- (NSDate *)calendarCurrentPage
{
    return self.calendar.currentPage;
}

#pragma mark - Private methods

- (CGRect)boundingRectForScope:(FSCalendarScope)scope
{
    CGSize contentSize;
    switch (scope) {
        case FSCalendarScopeMonth: {
            if (self.calendar.showsPlaceholders) {
                contentSize = self.cachedMonthSize;
            } else {
                contentSize = [self.calendar sizeThatFits:self.calendar.frame.size scope:scope];
            }
            break;
        }
        case FSCalendarScopeWeek: {
            contentSize = [self.calendar sizeThatFits:self.calendar.frame.size scope:scope];
            break;
        }
    }
    return (CGRect){CGPointZero,contentSize};
}

- (void)boundingRectWillChange:(CGRect)targetBounds animated:(BOOL)animated
{
    if (self.calendar.delegate && [self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)]) {
        self.calendar.scopeHandle.fs_bottom = CGRectGetMaxY(targetBounds);
        self.calendar.bottomBorder.fs_top = CGRectGetMaxY(targetBounds);
        self.calendar.daysContainer.fs_height = CGRectGetHeight(targetBounds)-self.calendar.preferredHeaderHeight-self.calendar.preferredWeekdayHeight-self.calendar.scopeHandle.fs_height;
        [self.calendar.delegate calendar:self.calendar boundingRectWillChange:targetBounds animated:animated];
    } else if (self.calendar.delegate && [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)]) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        self.calendar.scopeHandle.fs_bottom = CGRectGetMaxY(targetBounds);
        self.calendar.bottomBorder.fs_top = CGRectGetMaxY(targetBounds);
        self.calendar.daysContainer.fs_height = CGRectGetHeight(targetBounds)-self.calendar.preferredHeaderHeight-self.calendar.preferredWeekdayHeight-self.calendar.scopeHandle.fs_height;
        [self.calendar.delegate calendarCurrentScopeWillChange:self.calendar animated:animated];
#pragma GCC diagnostic pop
    }
}

- (void)performForwardTransition:(FSCalendarTransition)transition fromProgress:(CGFloat)progress
{
    FSCalendarTransitionAttributes *attr = self.pendingAttributes;
    switch (transition) {
        case FSCalendarTransitionMonthToWeek: {
            
            self.calendarScope = FSCalendarScopeWeek;
            self.calendarCurrentPage = attr.targetPage;
            
            self.calendar.contentView.clipsToBounds = YES;
            
            CGFloat currentAlpha = 1 - progress;
            CGFloat duration = 0.3;
            [self performAlphaAnimationFrom:currentAlpha to:0 duration:0.22 exception:attr.focusedRowNumber];
            [self performPathAnimationFrom:self.calendar.maskLayer.path to:[UIBezierPath bezierPathWithRect:attr.targetBounds].CGPath duration:duration completion:^{
                [self performTransitionCompletionAnimated:YES];
            }];
            
            if (self.calendar.delegate && ([self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)] || [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)])) {
                [UIView beginAnimations:@"delegateTranslation" context:"translation"];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [UIView setAnimationDuration:duration];
                self.collectionView.fs_top = -attr.focusedRowNumber*self.calendar.preferredRowHeight;
                [self boundingRectWillChange:attr.targetBounds animated:YES];
                [UIView commitAnimations];
            }
            
            break;
        }
        case FSCalendarTransitionWeekToMonth: {
            
            self.calendarScope = FSCalendarScopeMonth;

            [self performAlphaAnimationFrom:progress to:1 duration:0.4 exception:attr.focusedRowNumber];
            
            CGFloat duration = 0.3;
            [CATransaction begin];
            [CATransaction setDisableActions:NO];
            
            [self performPathAnimationFrom:self.calendar.maskLayer.path to:[UIBezierPath bezierPathWithRect:attr.targetBounds].CGPath duration:duration completion:^{
                [self performTransitionCompletionAnimated:YES];
            }];
            
            if (self.calendar.delegate && ([self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)] || [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)])) {
                [UIView beginAnimations:@"delegateTranslation" context:"translation"];
                [UIView setAnimationsEnabled:YES];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [UIView setAnimationDuration:duration];
                self.collectionView.fs_top = 0;
                [self boundingRectWillChange:attr.targetBounds animated:YES];
                [UIView commitAnimations];
            }
            [CATransaction commit];
            break;
        }
        default:
            break;
    }
}

- (void)performBackwardTransition:(FSCalendarTransition)transition fromProgress:(CGFloat)progress
{
    switch (transition) {
        case FSCalendarTransitionMonthToWeek: {
            [self performAlphaAnimationFrom:1-progress to:1 duration:0.3 exception:self.pendingAttributes.focusedRowNumber];
            [self performPathAnimationFrom:self.calendar.maskLayer.path to:self.pendingAttributes.sourceMask.CGPath duration:0.3 completion:^{
                [self.calendar.maskLayer removeAnimationForKey:@"path"];
                self.calendar.maskLayer.path = self.pendingAttributes.sourceMask.CGPath;
                [self.calendar.collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.contentView.layer.opacity = 1;
                    [obj.contentView.layer removeAnimationForKey:@"opacity"];
                }];
                self.pendingAttributes = nil;
            }];
            
            if (self.calendar.delegate && ([self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)] || [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)])) {
                [UIView beginAnimations:@"delegateTranslation" context:"translation"];
                [UIView setAnimationsEnabled:YES];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [UIView setAnimationDuration:0.3];
                self.collectionView.fs_top = 0;
                [self boundingRectWillChange:self.pendingAttributes.sourceBounds animated:YES];
                [UIView commitAnimations];
            }
            break;
        }
        case FSCalendarTransitionWeekToMonth: {
            [self performAlphaAnimationFrom:progress to:0 duration:0.3 exception:self.pendingAttributes.focusedRowNumber];
            [self performPathAnimationFrom:self.calendar.maskLayer.path to:self.pendingAttributes.sourceMask.CGPath duration:0.3 completion:^{
                
                self.calendarScope = FSCalendarScopeWeek;
                self.calendarCurrentPage = self.pendingAttributes.sourcePage;
                
                [self performTransitionCompletion:FSCalendarTransitionMonthToWeek animated:YES];
            }];
            
            if (self.calendar.delegate && ([self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)] || [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)])) {
                [UIView beginAnimations:@"delegateTranslation" context:"translation"];
                [UIView setAnimationsEnabled:YES];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [UIView setAnimationDuration:0.3];
                self.collectionView.fs_top = (-self.pendingAttributes.focusedRowNumber*self.calendar.preferredRowHeight);
                [self boundingRectWillChange:self.pendingAttributes.sourceBounds animated:YES];
                [UIView commitAnimations];
            }
            break;
        }
        default:
            break;
    }
}

- (void)performAlphaAnimationFrom:(CGFloat)fromAlpha to:(CGFloat)toAlpha duration:(CGFloat)duration exception:(NSInteger)exception
{
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(FSCalendarCell *cell, NSUInteger idx, BOOL *stop) {
        if (CGRectContainsPoint(self.collectionView.bounds, cell.center)) {
            BOOL shouldPerformAlpha = NO;
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
            switch (self.collectionViewLayout.scrollDirection) {
                case UICollectionViewScrollDirectionHorizontal: {
                    shouldPerformAlpha = indexPath.item%6 != exception;
                    break;
                }
                case UICollectionViewScrollDirectionVertical: {
                    shouldPerformAlpha = indexPath.item/7 != exception;
                    break;
                }
            }
            if (shouldPerformAlpha) {
                CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
                opacity.duration = duration;
                opacity.fromValue = @(fromAlpha);
                opacity.toValue = @(toAlpha);
                opacity.removedOnCompletion = NO;
                opacity.fillMode = kCAFillModeForwards;
                [cell.contentView.layer addAnimation:opacity forKey:@"opacity"];
            }
        }
    }];
}

- (void)performPathAnimationFrom:(CGPathRef)fromPath to:(CGPathRef)toPath duration:(CGFloat)duration completion:(void (^)())completion
{
    CABasicAnimation *path = [CABasicAnimation animationWithKeyPath:@"path"];
    path.fromValue = (__bridge id)fromPath;
    path.toValue = (__bridge id)toPath;
    path.duration = duration;
    path.fillMode = kCAFillModeForwards;
    path.removedOnCompletion = NO;
    path.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    [CATransaction setAnimationDuration:duration];
    [self.calendar.maskLayer addAnimation:path forKey:@"path"];
    [CATransaction commit];
}

- (void)performAlphaAnimationWithProgress:(CGFloat)progress
{
    CGFloat opacity = self.transition == FSCalendarTransitionMonthToWeek ? 1-progress: progress;
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(FSCalendarCell *cell, NSUInteger idx, BOOL *stop) {
        if (CGRectContainsPoint(self.collectionView.bounds, cell.center)) {
            BOOL shouldPerformAlpha = NO;
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
            switch (self.collectionViewLayout.scrollDirection) {
                case UICollectionViewScrollDirectionHorizontal: {
                    shouldPerformAlpha = indexPath.item%6 != self.pendingAttributes.focusedRowNumber;
                    break;
                }
                case UICollectionViewScrollDirectionVertical: {
                    shouldPerformAlpha = indexPath.item/7 != self.pendingAttributes.focusedRowNumber;
                    break;
                }
            }
            if (shouldPerformAlpha) {
                cell.contentView.layer.opacity = opacity;
            }
        }
    }];
}

- (void)performPathAnimationWithProgress:(CGFloat)progress
{
    CGFloat targetHeight = CGRectGetHeight(self.pendingAttributes.targetBounds);
    CGFloat sourceHeight = CGRectGetHeight(self.pendingAttributes.sourceBounds);
    CGFloat currentHeight = sourceHeight - (sourceHeight-targetHeight)*progress - self.calendar.scopeHandle.fs_height;
    CGRect currentPathRect = CGRectMake(0, 0, CGRectGetWidth(self.pendingAttributes.targetBounds), currentHeight);
    CGRect currentBounds = CGRectMake(0, 0, CGRectGetWidth(self.pendingAttributes.targetBounds), currentHeight+self.calendar.scopeHandle.fs_height);
    CGPathRef currentPath = [UIBezierPath bezierPathWithRect:currentPathRect].CGPath;
    self.calendar.maskLayer.path = currentPath;
    self.collectionView.fs_top = (-self.pendingAttributes.focusedRowNumber*self.calendar.preferredRowHeight)*(self.transition == FSCalendarTransitionMonthToWeek?progress:(1-progress));
    [self boundingRectWillChange:currentBounds animated:NO];
    if (self.transition == FSCalendarTransitionWeekToMonth) {
        self.calendar.contentView.fs_height = targetHeight;
    }
}

@end


@implementation FSCalendarTransitionAttributes


@end

