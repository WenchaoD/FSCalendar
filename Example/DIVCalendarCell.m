//
//  DIVCalendarCell.m
//  FSCalendar
//
//  Created by dingwenchao on 02/11/2016.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "DIVCalendarCell.h"

@implementation DIVCalendarCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *divImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_cat"]];
        [self.contentView addSubview:divImageView];
        self.divImageView = divImageView;
        
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.divImageView.frame = self.shapeLayer.frame;
    self.backgroundView.frame = CGRectInset(self.bounds, 1, 0.5);
}
}

@end
