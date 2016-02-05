//
//  CALayer+FSExtension.m
//  FSCalendar
//
//  Created by dingwenchao on 2/3/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "CALayer+FSExtension.h"

@implementation CALayer (FSExtension)

- (CGFloat)fs_width
{
    return CGRectGetWidth(self.frame);
}

- (void)setFs_width:(CGFloat)fs_width
{
    self.frame = CGRectMake(self.fs_left, self.fs_top, fs_width, self.fs_height);
}

- (CGFloat)fs_height
{
    return CGRectGetHeight(self.frame);
}

- (void)setFs_height:(CGFloat)fs_height
{
    self.frame = CGRectMake(self.fs_left, self.fs_top, self.fs_width, fs_height);
}

- (CGFloat)fs_top
{
    return CGRectGetMinY(self.frame);
}

- (void)setFs_top:(CGFloat)fs_top
{
    self.frame = CGRectMake(self.fs_left, fs_top, self.fs_width, self.fs_height);
}

- (CGFloat)fs_bottom
{
    return CGRectGetMaxY(self.frame);
}

- (void)setFs_bottom:(CGFloat)fs_bottom
{
    self.fs_top = fs_bottom - self.fs_height;
}

- (CGFloat)fs_left
{
    return CGRectGetMinX(self.frame);
}

- (void)setFs_left:(CGFloat)fs_left
{
    self.frame = CGRectMake(fs_left, self.fs_top, self.fs_width, self.fs_height);
}

- (CGFloat)fs_right
{
    return CGRectGetMaxX(self.frame);
}

- (void)setFs_right:(CGFloat)fs_right
{
    self.fs_left = self.fs_right - self.fs_width;
}

@end
