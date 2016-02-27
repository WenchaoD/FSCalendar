//
//  FSCalendarAnimationLayout.m
//  FSCalendar
//
//  Created by dingwenchao on 1/3/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "FSCalendarFlowLayout.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendar.h"
#import "UIView+FSExtension.h"
#import <objc/runtime.h>

@interface FSCalendarFlowLayout ()

@property (assign, nonatomic) BOOL originalClipsToBounds;

@end

@implementation FSCalendarFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumInteritemSpacing = 0;
        self.minimumLineSpacing = 0;
        self.itemSize = CGSizeMake(1, 1);
        self.sectionInset = UIEdgeInsetsZero;
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    CGFloat rowHeight = self.calendar.preferredRowHeight;
    
    if (!self.calendar.floatingMode) {
        
        self.headerReferenceSize = CGSizeZero;
        
        switch (self.calendar.scope) {
                
            case FSCalendarScopeMonth: {
                
                CGSize itemSize = CGSizeMake(
                                             self.collectionView.fs_width/7-(self.scrollDirection == UICollectionViewScrollDirectionVertical)*0.1,
                                             rowHeight
                                             );
                self.itemSize = itemSize;
                
                CGFloat padding = self.calendar.preferredWeekdayHeight*0.1;
                self.sectionInset = UIEdgeInsetsMake(padding, 0, padding, 0);
                break;
            }
            case FSCalendarScopeWeek: {
                
                CGSize itemSize = CGSizeMake(self.collectionView.fs_width/7, rowHeight);
                self.itemSize = itemSize;
                
                CGFloat padding = self.calendar.preferredWeekdayHeight*0.1;
                self.sectionInset = UIEdgeInsetsMake(padding, 0, padding, 0);
                
                break;
                
            }
                
        }
    } else {
        
        CGFloat headerHeight = self.calendar.preferredWeekdayHeight*1.5+self.calendar.preferredHeaderHeight;
        self.headerReferenceSize = CGSizeMake(self.collectionView.fs_width, headerHeight);
        
        CGSize itemSize = CGSizeMake(
                                     self.collectionView.fs_width/7-(self.scrollDirection == UICollectionViewScrollDirectionVertical)*0.1,
                                     rowHeight
                                     );
        self.itemSize = itemSize;
        
        self.sectionInset = UIEdgeInsetsZero;
        
    }
    
}

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
    
    [self performTransition:animated];
    
}

#pragma mark - Private methdos

- (void)performTransition:(BOOL)animated
{
    self.state = FSCalendarTransitionStateInProgress;
    
    switch (self.transition) {
            
        case FSCalendarTransitionMonthToWeek: {
            
            NSInteger focusedRowNumber = 0;
            if (self.calendar.focusOnSingleSelectedDate) {
                NSDate *focusedDate = self.calendar.selectedDate;
                if (focusedDate) {
                    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[self.calendar indexPathForDate:focusedDate scope:FSCalendarScopeMonth]];
                    CGPoint focuedCenter = attributes.center;
                    if (CGRectContainsPoint(self.collectionView.bounds, focuedCenter)) {
                        switch (self.scrollDirection) {
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
                        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[self.calendar indexPathForDate:focusedDate scope:FSCalendarScopeMonth]];
                        CGPoint focuedCenter = attributes.center;
                        if (CGRectContainsPoint(self.collectionView.bounds, focuedCenter)) {
                            switch (self.scrollDirection) {
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
            
            CGSize size = [self.calendar sizeThatFits:self.calendar.frame.size scope:FSCalendarScopeWeek];
            self.calendar.contentView.clipsToBounds = YES;
            self.calendar.daysContainer.clipsToBounds = YES;
            BOOL oldClipsToBounds = self.calendar.clipsToBounds;
            self.calendar.clipsToBounds = YES;
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
                        switch (self.scrollDirection) {
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
                path.toValue = (id)[UIBezierPath bezierPathWithRect:(CGRect){CGPointZero,size}].CGPath;
                path.duration = duration;
                path.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    self.state = FSCalendarTransitionStateIdle;
                    self.transition = FSCalendarTransitionNone;
                    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
                    self.calendar.header.scrollDirection = self.scrollDirection;
                    self.calendar.maskLayer.path = [UIBezierPath bezierPathWithRect:(CGRect){CGPointZero,size}].CGPath;
                    [self.collectionView reloadData];
                    [self.collectionView layoutIfNeeded];
                    [self.calendar.header reloadData];
                    [self.calendar.header layoutIfNeeded];
                    self.calendar.needsAdjustingMonthPosition = YES;
                    self.calendar.needsAdjustingViewFrame = YES;
                    [self.calendar setNeedsLayout];
                    self.calendar.contentView.clipsToBounds = NO;
                    self.calendar.daysContainer.clipsToBounds = NO;
                    self.calendar.clipsToBounds = oldClipsToBounds;
                }];
                [CATransaction setAnimationDuration:duration];
                [self.calendar.maskLayer addAnimation:path forKey:@"path"];
                [CATransaction commit];
                
                if (self.calendar.delegate && [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)]) {
                    [UIView beginAnimations:@"delegateTranslation" context:"translation"];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    [UIView setAnimationDuration:duration];
                    self.collectionView.fs_top = -focusedRowNumber*self.calendar.preferredRowHeight;
                    self.calendar.bottomBorder.frame = CGRectMake(0, size.height, self.calendar.fs_width, 1);
                    [self.calendar.delegate calendarCurrentScopeWillChange:self.calendar animated:animated];
                    [UIView commitAnimations];
                }
                
            } else {
                
                self.state = FSCalendarTransitionStateIdle;
                self.transition = FSCalendarTransitionNone;
                self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
                self.calendar.header.scrollDirection = self.scrollDirection;
                self.calendar.needsAdjustingViewFrame = YES;
                self.calendar.bottomBorder.frame = CGRectMake(0, size.height, self.calendar.fs_width, 1);
                self.calendar.maskLayer.path = [UIBezierPath bezierPathWithRect:(CGRect){CGPointZero,size}].CGPath;
                
                [self.collectionView reloadData];
                [self.collectionView layoutIfNeeded];
                [self.calendar.header reloadData];
                [self.calendar.header layoutIfNeeded];
                self.calendar.needsAdjustingMonthPosition = YES;
                self.calendar.needsAdjustingViewFrame = YES;
                [self.calendar setNeedsLayout];
                
                self.calendar.contentView.clipsToBounds = NO;
                self.calendar.daysContainer.clipsToBounds = NO;
                self.calendar.clipsToBounds = oldClipsToBounds;
                
                if (self.calendar.delegate && [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)]) {
                    [self.calendar.delegate calendarCurrentScopeWillChange:self.calendar animated:animated];
                }
            }
            
            break;
        }
            
        case FSCalendarTransitionWeekToMonth: {
            
            NSInteger focusedRowNumber = 0;
            NSDate *currentPage = self.calendar.currentPage;
            NSDate *firstDayOfMonth = nil;
            if (self.calendar.focusOnSingleSelectedDate) {
                NSDate *focusedDate = self.calendar.selectedDate;
                if (focusedDate) {
                    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[self.calendar indexPathForDate:focusedDate scope:FSCalendarScopeWeek]];
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
                        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[self.calendar indexPathForDate:focusedDate scope:FSCalendarScopeWeek]];
                        CGPoint focuedCenter = attributes.center;
                        if (CGRectContainsPoint(self.collectionView.bounds, focuedCenter)) {
                            firstDayOfMonth = [self.calendar beginingOfMonthOfDate:focusedDate];
                        }
                    }
                };
            }
            firstDayOfMonth = firstDayOfMonth ?: [self.calendar beginingOfMonthOfDate:currentPage];
            NSInteger weekdayOfFirstDay = [self.calendar weekdayOfDate:firstDayOfMonth];
            NSInteger numberOfPlaceholdersForPrev = ((weekdayOfFirstDay - self.calendar.firstWeekday) + 7) % 7 ?: 7;
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
            
            self.scrollDirection = (UICollectionViewScrollDirection)self.calendar.scrollDirection;
            self.calendar.header.scrollDirection = self.scrollDirection;
            
            self.calendar.needsAdjustingMonthPosition = YES;
            self.calendar.needsAdjustingViewFrame = YES;
            [self.calendar layoutSubviews];
            [self.collectionView reloadData];
            [self.collectionView layoutIfNeeded];
            [self.calendar.header reloadData];
            [self.calendar.header layoutIfNeeded];
            
            self.calendar.contentView.clipsToBounds = YES;
            self.calendar.daysContainer.clipsToBounds = YES;
            
            CGSize size = [self.calendar sizeThatFits:self.calendar.frame.size scope:FSCalendarScopeMonth];
            if (animated) {
                
                CGFloat duration = 0.3;
                // Perform alpha animation
                CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
                opacity.duration = duration;
                opacity.fromValue = @0;
                opacity.toValue = @1;
                [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(FSCalendarCell *cell, NSUInteger idx, BOOL *stop) {
                    if (CGRectContainsPoint(self.collectionView.bounds, cell.center)) {
                        BOOL shouldPerformAlpha = NO;
                        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
                        switch (self.scrollDirection) {
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
                path.toValue = (id)[UIBezierPath bezierPathWithRect:(CGRect){CGPointZero,size}].CGPath;
                path.duration = duration;
                path.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    self.state = FSCalendarTransitionStateIdle;
                    self.transition = FSCalendarTransitionNone;
                    self.calendar.maskLayer.path = [UIBezierPath bezierPathWithRect:(CGRect){CGPointZero,size}].CGPath;
                    self.calendar.contentView.clipsToBounds = NO;
                    self.calendar.daysContainer.clipsToBounds = NO;
                }];
                [CATransaction setAnimationDuration:duration];
                
                self.calendar.needsAdjustingViewFrame = YES;
                [self.calendar.maskLayer addAnimation:path forKey:@"path"];
                
                [CATransaction commit];
                
                if (self.calendar.delegate && [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)]) {
                    self.collectionView.fs_top = -focusedRowNumber*self.calendar.preferredRowHeight;
                    [UIView setAnimationsEnabled:YES];
                    [UIView beginAnimations:@"delegateTranslation" context:"translation"];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    [UIView setAnimationDuration:duration];
                    self.collectionView.fs_top = 0;
                    self.self.calendar.bottomBorder.frame = CGRectMake(0, size.height, self.calendar.fs_width, 1);
                    [self.calendar.delegate calendarCurrentScopeWillChange:self.calendar animated:animated];
                    [UIView commitAnimations];
                }
                [CATransaction setDisableActions:oldDisableActions];
                
            } else {
                
                self.state = FSCalendarTransitionStateIdle;
                self.transition = FSCalendarTransitionNone;
                self.calendar.needsAdjustingViewFrame = YES;
                self.calendar.bottomBorder.frame = CGRectMake(0, size.height, self.calendar.fs_width, 1);
                self.calendar.maskLayer.path = [UIBezierPath bezierPathWithRect:(CGRect){CGPointZero,size}].CGPath;
                self.calendar.contentView.clipsToBounds = NO;
                self.calendar.daysContainer.clipsToBounds = NO;
                
                if (self.calendar.delegate && [self.calendar.delegate respondsToSelector:@selector(calendarCurrentScopeWillChange:animated:)]) {
                    [self.calendar.delegate calendarCurrentScopeWillChange:self.calendar animated:animated];
                }
                
            }
            break;
        }
        default:
            break;
    }
    
}

@end
