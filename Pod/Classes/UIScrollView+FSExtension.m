//
//  UIScrollView+FSExtension.m
//  Pods
//
//  Created by Wenchao Ding on 5/3/15.
//
//

#import "UIScrollView+FSExtension.h"

@implementation UIScrollView (FSExtension)

- (void)fs_scrollBy:(CGPoint)offset animate:(BOOL)animate
{
    if (!animate) {
        self.contentOffset = CGPointMake(self.contentOffset.x+offset.x, self.contentOffset.y+offset.y);
    } else {
        
    }
}

@end
