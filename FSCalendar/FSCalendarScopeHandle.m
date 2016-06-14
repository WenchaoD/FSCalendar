//
//  FSCalendarScopeHandle.m
//  FSCalendar
//
//  Created by dingwenchao on 4/29/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "FSCalendarScopeHandle.h"
#import "FSCalendar.h"
#import "FSCalendarAnimator.h"
#import "UIView+FSExtension.h"

@interface FSCalendarScopeHandle () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) UIView *topBorder;
@property (weak, nonatomic) UIView *handleIndicator;

@property (weak, nonatomic) FSCalendarAppearance *appearance;

@property (assign, nonatomic) CGFloat lastTranslation;

- (void)handlePan:(id)sender;

@end

@implementation FSCalendarScopeHandle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *view;
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
        view.backgroundColor = FSCalendarStandardSeparatorColor;
        [self addSubview:view];
        self.topBorder = view;
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 6)];
        view.layer.shouldRasterize = YES;
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 3;
        view.layer.backgroundColor = FSCalendarStandardScopeHandleColor.CGColor;
        [self addSubview:view];
        self.handleIndicator = view;

        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panGesture.minimumNumberOfTouches = 1;
        panGesture.maximumNumberOfTouches = 2;
        panGesture.delegate = self;
        [self addGestureRecognizer:panGesture];
        self.panGesture = panGesture;
                
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.topBorder.frame = CGRectMake(0, 0, self.fs_width, 1);
    self.handleIndicator.center = CGPointMake(self.fs_width/2, self.fs_height/2-0.5);
}

#pragma mark - Target actions

- (void)handlePan:(id)sender
{
    switch (self.panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(scopeHandleDidBegin:)]) {
                [self.delegate scopeHandleDidBegin:self];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(scopeHandleDidUpdate:)]) {
                [self.delegate scopeHandleDidUpdate:self];
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(scopeHandleDidEnd:)]) {
                [self.delegate scopeHandleDidEnd:self];
            }
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(scopeHandleDidEnd:)]) {
                [self.delegate scopeHandleDidEnd:self];
            }
            break;
        }
        case UIGestureRecognizerStateFailed: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(scopeHandleDidEnd:)]) {
                [self.delegate scopeHandleDidEnd:self];
            }
            break;
        }
        default: {
            break;
        }
    }
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scopeHandleShouldBegin:)]) {
        return [self.delegate scopeHandleShouldBegin:self];
    }
    return NO;
}

@end
