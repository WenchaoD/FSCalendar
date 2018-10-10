//
//  FSCalendarSeparatorDecorationView.m
//  FSCalendar
//
//  Created by 丁文超 on 2018/10/10.
//  Copyright © 2018 wenchaoios. All rights reserved.
//

#import "FSCalendarSeparatorDecorationView.h"
#import "FSCalendarConstants.h"

@implementation FSCalendarSeparatorDecorationView

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
