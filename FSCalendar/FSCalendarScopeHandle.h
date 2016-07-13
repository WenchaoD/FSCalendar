//
//  FSCalendarScopeHandle.h
//  FSCalendar
//
//  Created by dingwenchao on 4/29/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class FSCalendar, FSCalendarScopeHandle;
//
//@protocol FSCalendarScopeHandleDelegate <NSObject>
//
//@optional
//- (BOOL)scopeHandleShouldBegin:(FSCalendarScopeHandle *)scopeHandle;
//- (void)scopeHandleDidBegin:(FSCalendarScopeHandle *)scopeHandle;
//- (void)scopeHandleDidUpdate:(FSCalendarScopeHandle *)scopeHandle;;
//- (void)scopeHandleDidEnd:(FSCalendarScopeHandle *)scopeHandle;
//@end

@class FSCalendar;

@interface FSCalendarScopeHandle : UIView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) UIPanGestureRecognizer *panGesture;
@property (weak, nonatomic) FSCalendar *calendar;

- (void)handlePan:(id)sender;

@end
