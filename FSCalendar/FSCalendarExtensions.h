//
//  FSCalendarExtensions.h
//  FSCalendar
//
//  Created by dingwenchao on 10/8/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface UIView (FSCalendarExtensions)

@property (nonatomic) CGFloat fs_width;
@property (nonatomic) CGFloat fs_height;

@property (nonatomic) CGFloat fs_top;
@property (nonatomic) CGFloat fs_left;
@property (nonatomic) CGFloat fs_bottom;
@property (nonatomic) CGFloat fs_right;

@end



@interface CALayer (FSCalendarExtensions)

@property (nonatomic) CGFloat fs_width;
@property (nonatomic) CGFloat fs_height;

@property (nonatomic) CGFloat fs_top;
@property (nonatomic) CGFloat fs_left;
@property (nonatomic) CGFloat fs_bottom;
@property (nonatomic) CGFloat fs_right;

@end


@interface NSObject (FSCalendarExtensions)

- (id)fs_performSelector:(SEL)selector withObjects:(nullable id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

@end

NS_ASSUME_NONNULL_END
