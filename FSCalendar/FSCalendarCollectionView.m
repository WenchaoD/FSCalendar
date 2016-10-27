//
//  FSCalendarCollectionView.m
//  FSCalendar
//
//  Created by Wenchao Ding on 10/25/15.
//  Copyright (c) 2015 wenchaoios. All rights reserved.
//

#import "FSCalendarCollectionView.h"
#import "FSCalendarExtensions.h"
#import "FSCalendarConstants.h"

@interface FSCalendarCollectionView ()

- (void)initialize;

@end

@implementation FSCalendarCollectionView

@synthesize scrollsToTop = _scrollsToTop, contentInset = _contentInset;

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.scrollsToTop = NO;
    self.contentInset = UIEdgeInsetsZero;
    
#ifdef __IPHONE_9_0
    if ([self respondsToSelector:@selector(setSemanticContentAttribute:)]) {
        self.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    }
#endif
    
#ifdef __IPHONE_10_0
    SEL selector = NSSelectorFromString(@"setPrefetchingEnabled:");
    if (selector && [self respondsToSelector:selector]) {
        [self fs_performSelector:selector withObjects:@NO, nil];
    }
#endif
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:UIEdgeInsetsZero];
}

- (void)setScrollsToTop:(BOOL)scrollsToTop
{
    [super setScrollsToTop:NO];
}

@end


@implementation FSCalendarSeparator

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = FSCalendarStandardSeparatorColor;
    }
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    self.frame = layoutAttributes.frame;
}

@end



