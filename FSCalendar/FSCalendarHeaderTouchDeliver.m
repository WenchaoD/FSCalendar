//
//  FSCalendarHeaderTouchDeliver.m
//  Pods
//
//  Created by dingwenchao on 8/17/15.
//
//

#import "FSCalendarHeaderTouchDeliver.h"
#import "FSCalendar.h"
#import "FSCalendarHeader.h"
#import "FSCalendarDynamicHeader.h"

@implementation FSCalendarHeaderTouchDeliver

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return _calendar.collectionView ?: hitView;
    }
    return hitView;
}

@end
