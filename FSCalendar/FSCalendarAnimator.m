//
//  FSCalendarAnimator.m
//  FSCalendar
//
//  Created by Wenchao Ding on 3/13/16.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendarAnimator.h"
#import <objc/runtime.h>
#import "UIView+FSExtension.h"

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
            
            CGSize contentSize = [self.calendar sizeThatFits:self.calendar.frame.size scope:FSCalendarScopeWeek];
            CGRect targetBounds = (CGRect){CGPointZero,contentSize};
            
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
                // Perform alpha animation
                CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
                opacity.duration = duration*0.6;
                opacity.removedOnCompletion = NO;
                opacity.fillMode = kCAFillModeForwards;
                opacity.toValue = @0;
                [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(FSCalendarCell *cell, NSUInteger idx, BOOL *stop) {
                    if (CGRectContainsPoint(self.collectionView.bounds, cell.center)) {
                        BOOL shouldPerformAlpha = NO;
                        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
                        switch (self.collectionViewLayout.scrollDirection) {
                            case UICollectionViewScrollDirectionHorizontal: {
                                shouldPerformAlpha = indexPath.item%6 != focusedRowNumber;
                                break;
                            }
                            case UICollectionViewScrollDirectionVertical: {
                                shouldPerformAlpha = indexPath.item/7 != focusedRowNumber;
                                break;
                            }
                        }
                        if (shouldPerformAlpha) {
                            [cell.contentView.layer addAnimation:opacity forKey:@"opacity"];
                        }
                    }
                }];
                
                // Perform path and frame animation
                CABasicAnimation *path = [CABasicAnimation animationWithKeyPath:@"path"];
                path.fromValue = (id)self.calendar.maskLayer.path;
                path.toValue = (id)[UIBezierPath bezierPathWithRect:targetBounds].CGPath;
                path.duration = duration;
                path.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    self.state = FSCalendarTransitionStateIdle;
                    self.transition = FSCalendarTransitionNone;
                    self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
                    self.calendar.header.scrollDirection = self.collectionViewLayout.scrollDirection;
                    self.calendar.maskLayer.path = [UIBezierPath bezierPathWithRect:targetBounds].CGPath;
                    [self.collectionView reloadData];
                    [self.collectionView layoutIfNeeded];
                    [self.calendar.header reloadData];
                    [self.calendar.header layoutIfNeeded];
                    self.calendar.needsAdjustingMonthPosition = YES;
                    self.calendar.needsAdjustingViewFrame = YES;
                    [self.calendar setNeedsLayout];
                    self.calendar.contentView.clipsToBounds = NO;
                    self.calendar.daysContainer.clipsToBounds = NO;
                }];
                [CATransaction setAnimationDuration:duration];
                [self.calendar.maskLayer addAnimation:path forKey:@"path"];
                [CATransaction commit];
                
                if (self.calendar.delegate && ([self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)] || [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)])) {
                    
                    [UIView beginAnimations:@"delegateTranslation" context:"translation"];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    [UIView setAnimationDuration:duration];
                    self.collectionView.fs_top = -focusedRowNumber*self.calendar.preferredRowHeight;
                    self.calendar.bottomBorder.fs_top = CGRectGetMaxY(targetBounds);
                    if ([self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)]) {
                        [self.calendar.delegate calendar:self.calendar boundingRectWillChange:targetBounds animated:animated];
                    } else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                        [self.calendar.delegate calendarCurrentScopeWillChange:self.calendar animated:animated];
#pragma GCC diagnostic pop
                    }
                    [UIView commitAnimations];
                }
                
            } else {
                
                self.state = FSCalendarTransitionStateIdle;
                self.transition = FSCalendarTransitionNone;
                self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
                self.calendar.header.scrollDirection = self.collectionViewLayout.scrollDirection;
                self.calendar.needsAdjustingViewFrame = YES;
                self.calendar.bottomBorder.frame = CGRectMake(0, contentSize.height, self.calendar.fs_width, 1);
                self.calendar.maskLayer.path = [UIBezierPath bezierPathWithRect:targetBounds].CGPath;
                self.calendar.bottomBorder.fs_top = CGRectGetMaxY(targetBounds);
                [self.collectionView reloadData];
                [self.collectionView layoutIfNeeded];
                [self.calendar.header reloadData];
                [self.calendar.header layoutIfNeeded];
                self.calendar.needsAdjustingMonthPosition = YES;
                self.calendar.needsAdjustingViewFrame = YES;
                [self.calendar setNeedsLayout];
                
                self.calendar.contentView.clipsToBounds = NO;
                self.calendar.daysContainer.clipsToBounds = NO;
                
                if (self.calendar.delegate && [self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)]) {
                    [self.calendar.delegate calendar:self.calendar boundingRectWillChange:targetBounds animated:animated];
                } else if (self.calendar.delegate && [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)]) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                    [self.calendar.delegate calendarCurrentScopeWillChange:self.calendar animated:animated];
#pragma GCC diagnostic pop
                }
                
            }
            
            break;
        }
            
        case FSCalendarTransitionWeekToMonth: {
            
            CGSize contentSize = [self.calendar sizeThatFits:self.calendar.frame.size scope:FSCalendarScopeMonth];
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
                // Perform alpha animation
                CGFloat duration = 0.3;
                CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
                opacity.duration = duration;
                opacity.fromValue = @0;
                opacity.toValue = @1;
                opacity.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(FSCalendarCell *cell, NSUInteger idx, BOOL *stop) {
                    if (CGRectContainsPoint(self.collectionView.bounds, cell.center)) {
                        BOOL shouldPerformAlpha = NO;
                        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
                        switch (self.collectionViewLayout.scrollDirection) {
                            case UICollectionViewScrollDirectionHorizontal: {
                                shouldPerformAlpha = indexPath.item%6 != focusedRowNumber;
                                break;
                            }
                            case UICollectionViewScrollDirectionVertical: {
                                shouldPerformAlpha = indexPath.item/7 != focusedRowNumber;
                                break;
                            }
                        }
                        if (shouldPerformAlpha) {
                            [cell.contentView.layer addAnimation:opacity forKey:@"opacity"];
                        }
                    }
                }];
                
                // Perform path and frame animation
                BOOL oldDisableActions = [CATransaction disableActions];
                [CATransaction setDisableActions:NO];
                
                CABasicAnimation *path = [CABasicAnimation animationWithKeyPath:@"path"];
                path.fromValue = (id)self.calendar.maskLayer.path;
                path.toValue = (id)[UIBezierPath bezierPathWithRect:targetBounds].CGPath;
                path.duration = duration;
                path.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    self.state = FSCalendarTransitionStateIdle;
                    self.transition = FSCalendarTransitionNone;
                    self.calendar.maskLayer.path = [UIBezierPath bezierPathWithRect:targetBounds].CGPath;
                    self.calendar.contentView.clipsToBounds = NO;
                    self.calendar.daysContainer.clipsToBounds = NO;
                }];
                [CATransaction setAnimationDuration:duration];
                
                self.calendar.needsAdjustingViewFrame = YES;
                [self.calendar.maskLayer addAnimation:path forKey:@"path"];
                
                [CATransaction commit];
                
                if (self.calendar.delegate && ([self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)] || [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)])) {
                    self.collectionView.fs_top = -focusedRowNumber*self.calendar.preferredRowHeight;
                    [UIView setAnimationsEnabled:YES];
                    [UIView beginAnimations:@"delegateTranslation" context:"translation"];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    [UIView setAnimationDuration:duration];
                    self.collectionView.fs_top = 0;
                    self.self.calendar.bottomBorder.frame = CGRectMake(0, contentSize.height, self.calendar.fs_width, 1);
                    if ([self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)]) {
                        [self.calendar.delegate calendar:self.calendar boundingRectWillChange:targetBounds animated:animated];
                    } else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                        [self.calendar.delegate calendarCurrentScopeWillChange:self.calendar animated:animated];
#pragma GCC diagnostic pop
                    }
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
                
                if (self.calendar.delegate && [self.calendar.delegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)]) {
                    [self.calendar.delegate calendar:self.calendar boundingRectWillChange:targetBounds animated:animated];
                } else if (self.calendar.delegate && [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)]) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                    [self.calendar.delegate calendarCurrentScopeWillChange:self.calendar animated:animated];
#pragma GCC diagnostic pop
                }
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


@end
