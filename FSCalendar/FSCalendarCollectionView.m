//
//  FSCalendarCollectionView.m
//  FSCalendar
//
//  Created by Wenchao Ding on 10/25/15.
//  Copyright (c) 2015 wenchaoios. All rights reserved.
//

#import "FSCalendarCollectionView.h"

@implementation FSCalendarCollectionView

@synthesize scrollsToTop = _scrollsToTop, contentInset = _contentInset;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollsToTop = NO;
        _contentInset = UIEdgeInsetsZero;
    }
    return self;
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:UIEdgeInsetsZero];
}

- (void)setScrollsToTop:(BOOL)scrollsToTop
{
    [super setScrollsToTop:NO];
}

- (void)reloadVisibleItems
{
    if (!self.indexPathsForVisibleItems.count || !self.dataSource) {
        return;
    }
    [self.indexPathsForVisibleItems enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [self.dataSource collectionView:self cellForItemAtIndexPath:indexPath];
    }];
}

@end

