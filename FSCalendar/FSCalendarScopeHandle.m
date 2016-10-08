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
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarExtensions.h"

@interface FSCalendarScopeHandle () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) UIView *topBorder;
@property (weak, nonatomic) UIView *handleIndicator;

@property (weak, nonatomic) FSCalendarAppearance *appearance;

@property (assign, nonatomic) CGFloat lastTranslation;

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
        [self addGestureRecognizer:panGesture];
        self.panGesture = panGesture;
        
        self.exclusiveTouch = YES;
                
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.topBorder.frame = CGRectMake(0, 0, self.fs_width, 1);
    self.handleIndicator.center = CGPointMake(self.fs_width/2, self.fs_height/2-0.5);
}

- (void)handlePan:(id)sender
{
    [self.calendar.animator handlePan:sender];
}

- (void)setCalendar:(FSCalendar *)calendar
{
    _calendar = calendar;
    self.panGesture.delegate = self.calendar.animator;
}

@end
