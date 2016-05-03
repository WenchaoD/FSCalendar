//
//  FSCalendarAnimator.m
//  FSCalendar
//
//  Created by Wenchao Ding on 3/13/16.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendarAnimator.h"
#import "FSCalendarConstance.h"
#import "UIView+FSExtension.h"
#import <objc/runtime.h>

@interface FSCalendarAnimator ()

- (void)performMonthToWeekCompletion;
- (void)performAlphaAnimationFrom:(CGFloat)fromAlpha to:(CGFloat)toAlpha duration:(CGFloat)duration exception:(NSInteger)exception;
- (void)performPathAnimationFrom:(CGPathRef)fromPath to:(CGPathRef)toPath duration:(CGFloat)duration completion:(void(^)())completion;

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
    
    switch (self.transition) {
            
        case FSCalendarTransitionMonthToWeek: {
            
            self.cachedMonthSize = self.calendar.frame.size;
            CGRect targetBounds = [self boundingRectForScope:FSCalendarScopeWeek];;
            
            NSInteger focusedRowNumber = 0;
            if (self.calendar.focusOnSingleSelectedDate) {
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
            }
            
            NSDate *currentPage = self.calendar.currentPage;
            NSDate *minimumPage = [self.calendar beginingOfMonthOfDate:self.calendar.minimumDate];
            NSInteger visibleSection = [self.calendar monthsFromDate:minimumPage toDate:currentPage];
            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:visibleSection];
            NSDate *firstDate = [self.calendar dateForIndexPath:firstIndexPath scope:FSCalendarScopeMonth];
            currentPage = [self.calendar dateByAddingDays:focusedRowNumber*7 toDate:firstDate];
            
            Ivar currentPageIvar = class_getInstanceVariable(FSCalendar.class, "_currentPage");
            object_setIvar(self.calendar, currentPageIvar, currentPage);
            
            self.calendar.contentView.clipsToBounds = YES;
            self.calendar.daysContainer.clipsToBounds = YES;
            
            if (animated) {
                CGFloat duration = 0.3;
                
                [self performAlphaAnimationFrom:1 to:0 duration:0.22 exception:focusedRowNumber];
                [self performPathAnimationFrom:self.calendar.maskLayer.path to:[UIBezierPath bezierPathWithRect:targetBounds].CGPath duration:duration completion:^{
                    [self performMonthToWeekCompletion];
                }];
                
                if (self.calendar.delegate && ([self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)] || [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)])) {
                    [UIView beginAnimations:@"delegateTranslation" context:"translation"];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    [UIView setAnimationDuration:duration];
                    self.collectionView.fs_top = -focusedRowNumber*self.calendar.preferredRowHeight;
                    self.calendar.bottomBorder.fs_top = CGRectGetMaxY(targetBounds);
                    [self boundingRectWillChange:targetBounds animated:animated];
                    [UIView commitAnimations];
                }
                
            } else {

                [self performMonthToWeekCompletion];
                [self boundingRectWillChange:targetBounds animated:animated];
                
            }
            
            break;
        }
            
        case FSCalendarTransitionWeekToMonth: {
            
            CGSize contentSize = self.cachedMonthSize;
            self.cachedMonthSize = CGSizeZero;
            
            CGRect targetBounds = (CGRect){CGPointZero,contentSize};
            
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
            
            Ivar currentPageIvar = class_getInstanceVariable(FSCalendar.class, "_currentPage");
            object_setIvar(self.calendar, currentPageIvar, currentPage);
            
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
            self.calendar.daysContainer.clipsToBounds = YES;
            
            if (animated) {
                
                [self performAlphaAnimationFrom:0 to:1 duration:0.4 exception:focusedRowNumber];
                
                CGFloat duration = 0.3;
                BOOL oldDisableActions = [CATransaction disableActions];
                [CATransaction setDisableActions:NO];
                
                [self performPathAnimationFrom:self.calendar.maskLayer.path to:[UIBezierPath bezierPathWithRect:targetBounds].CGPath duration:duration completion:^{
                    self.state = FSCalendarTransitionStateIdle;
                    self.transition = FSCalendarTransitionNone;
                    self.calendar.maskLayer.path = [UIBezierPath bezierPathWithRect:targetBounds].CGPath;
                    self.calendar.contentView.clipsToBounds = NO;
                    self.calendar.daysContainer.clipsToBounds = NO;
                }];
                
                if (self.calendar.delegate && ([self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)] || [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)])) {
                    self.collectionView.fs_top = -focusedRowNumber*self.calendar.preferredRowHeight;
                    [UIView setAnimationsEnabled:YES];
                    [UIView beginAnimations:@"delegateTranslation" context:"translation"];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    [UIView setAnimationDuration:duration];
                    self.collectionView.fs_top = 0;
                    self.self.calendar.bottomBorder.frame = CGRectMake(0, contentSize.height, self.calendar.fs_width, 1);
                    [self boundingRectWillChange:targetBounds animated:animated];
                    [UIView commitAnimations];
                }
                [CATransaction setDisableActions:oldDisableActions];
                
            } else {
                
                self.state = FSCalendarTransitionStateIdle;
                self.transition = FSCalendarTransitionNone;
                self.calendar.needsAdjustingViewFrame = YES;
                self.calendar.bottomBorder.frame = CGRectMake(0, contentSize.height, self.calendar.fs_width, 1);
                self.calendar.maskLayer.path = [UIBezierPath bezierPathWithRect:targetBounds].CGPath;
                self.calendar.contentView.clipsToBounds = NO;
                self.calendar.daysContainer.clipsToBounds = NO;
                [self boundingRectWillChange:targetBounds animated:animated];
                
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
            if (self.calendar.delegate && [self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)]) {
                if (!CGRectEqualToRect((CGRect){CGPointZero,self.calendar.frame.size}, bounds)) {
                    [self.calendar.delegate calendar:self.calendar boundingRectWillChange:bounds animated:YES];
                }
            }
            self.calendar.bottomBorder.fs_top = CGRectGetMaxY(bounds);
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

#pragma mark - Private properties

- (void)performMonthToWeekCompletion
{
    CGRect targetBounds = [self boundingRectForScope:FSCalendarScopeWeek];
    self.state = FSCalendarTransitionStateIdle;
    self.transition = FSCalendarTransitionNone;
    self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.calendar.header.scrollDirection = self.collectionViewLayout.scrollDirection;
    self.calendar.needsAdjustingViewFrame = YES;
    self.calendar.bottomBorder.frame = CGRectMake(0, targetBounds.size.height, self.calendar.fs_width, 1);
    self.calendar.maskLayer.path = [UIBezierPath bezierPathWithRect:targetBounds].CGPath;
    self.calendar.bottomBorder.fs_top = CGRectGetMaxY(targetBounds);
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    [self.calendar.header reloadData];
    [self.calendar.header layoutIfNeeded];
    self.calendar.needsAdjustingMonthPosition = YES;
    [self.calendar setNeedsLayout];
    self.calendar.contentView.clipsToBounds = NO;
    self.calendar.daysContainer.clipsToBounds = NO;
}

- (CGSize)cachedMonthSize
{
    if (!CGSizeEqualToSize(CGSizeZero, _cachedMonthSize)) {
        return [self.calendar sizeThatFits:self.calendar.frame.size scope:FSCalendarScopeMonth];
    }
    return _cachedMonthSize;
}

#pragma mark - Private methods

- (CGRect)boundingRectForScope:(FSCalendarScope)scope
{
    CGSize contentSize = [self.calendar sizeThatFits:self.calendar.frame.size scope:scope];
    return (CGRect){CGPointZero,contentSize};
}

- (void)boundingRectWillChange:(CGRect)targetBounds animated:(BOOL)animated
{
    if (self.calendar.delegate && [self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)]) {
        [self.calendar.delegate calendar:self.calendar boundingRectWillChange:targetBounds animated:animated];
    } else if (self.calendar.delegate && [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)]) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [self.calendar.delegate calendarCurrentScopeWillChange:self.calendar animated:animated];
#pragma GCC diagnostic pop
    }
}

- (void)performAlphaAnimationFrom:(CGFloat)fromAlpha to:(CGFloat)toAlpha duration:(CGFloat)duration exception:(NSInteger)exception
{
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.duration = duration;
    opacity.fromValue = @(fromAlpha);
    opacity.toValue = @(toAlpha);
    opacity.removedOnCompletion = NO;
    opacity.fillMode = kCAFillModeForwards;
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
    path.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    [CATransaction setAnimationDuration:duration];
    [self.calendar.maskLayer addAnimation:path forKey:@"path"];
    [CATransaction commit];
    
}

@end
