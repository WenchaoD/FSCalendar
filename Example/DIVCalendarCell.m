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
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.divImageView.frame = self.shapeLayer.frame;
}

@end
