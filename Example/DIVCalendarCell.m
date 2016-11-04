//
//  DIVCalendarCell.m
//  FSCalendar
//
//  Created by dingwenchao on 02/11/2016.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "DIVCalendarCell.h"
#import "FSCalendarExtensions.h"

@implementation DIVCalendarCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *divImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle"]];
        [self.contentView insertSubview:divImageView atIndex:0];
        self.divImageView = divImageView;
        
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundView.frame = CGRectInset(self.bounds, 1, 0.5);
    self.divImageView.frame = self.backgroundView.frame;
    
    self.titleLabel.fs_top += 3;
    self.shapeLayer.fs_top += 3;
}

- (void)configureSubviews
{
    [super configureSubviews];
    // Configure your 'selected' and 'unselected' state
    if (self.selected) {
        
    } else {
        
    }
}

@end
