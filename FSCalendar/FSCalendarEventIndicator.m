//
//  FSCalendarEventView.m
//  FSCalendar
//
//  Created by dingwenchao on 2/3/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "FSCalendarEventIndicator.h"
#import "FSCalendarConstance.h"
#import "FSCalendarExtensions.h"

@interface FSCalendarEventIndicator ()

@property (weak, nonatomic) UIView *contentView;

@property (strong, nonatomic) NSMutableArray *eventLayers;
@property (assign, nonatomic) BOOL needsInvalidatingColor;

@end

@implementation FSCalendarEventIndicator

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:view];
        self.contentView = view;
        
        self.eventLayers = [NSMutableArray arrayWithCapacity:3];
        for (int i = 0; i < 3; i++) {
            CALayer *layer = [CALayer layer];
            layer.backgroundColor = [UIColor clearColor].CGColor;
            [self.eventLayers addObject:layer];
            [self.contentView.layer addSublayer:layer];
        }
        
        _needsInvalidatingColor = YES;
        _needsAdjustingViewFrame = YES;
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_needsAdjustingViewFrame) {
        CGFloat diameter = MIN(MIN(self.fs_width, self.fs_height),FSCalendarMaximumEventDotDiameter);
        self.contentView.fs_height = self.fs_height;
        self.contentView.fs_width = (self.numberOfEvents*2-1)*diameter;
        self.contentView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    if (layer == self.layer) {
        if (_needsAdjustingViewFrame) {
            _needsAdjustingViewFrame = NO;
            CGFloat diameter = MIN(MIN(self.fs_width, self.fs_height),FSCalendarMaximumEventDotDiameter);
            for (int i = 0; i < self.eventLayers.count; i++) {
                CALayer *eventLayer = self.eventLayers[i];
                eventLayer.hidden = i >= self.numberOfEvents;
                if (!eventLayer.hidden) {
                    eventLayer.frame = CGRectMake(2*i*diameter, (self.fs_height-diameter)*0.5, diameter, diameter);
                    if (eventLayer.cornerRadius != diameter/2) {
                        eventLayer.cornerRadius = diameter/2;
                    }
                }
            }
        }
        if (_needsInvalidatingColor) {
            _needsInvalidatingColor = NO;
            if ([_color isKindOfClass:[UIColor class]]) {
                [self.eventLayers makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:(id)[_color CGColor]];
            } else if ([_color isKindOfClass:[NSArray class]]) {
                NSArray *colors = (NSArray *)_color;
                if (colors.count) {
                    UIColor *lastColor = colors.firstObject;
                    for (int i = 0; i < self.eventLayers.count; i++) {
                        if (i < colors.count) {
                            lastColor = colors[i];
                        }
                        CALayer *eventLayer = self.eventLayers[i];
                        eventLayer.backgroundColor = lastColor.CGColor;
                    }
                }
            }
        }
    }
}

- (void)setColor:(id)color
{
    if (![_color isEqual:color]) {
        _color = color;
        _needsInvalidatingColor = YES;
        [self setNeedsLayout];
    }
}

- (void)setNumberOfEvents:(NSInteger)numberOfEvents
{
    if (_numberOfEvents != numberOfEvents) {
        _numberOfEvents = MIN(MAX(numberOfEvents,0),3);
        _needsAdjustingViewFrame = YES;
        [self setNeedsLayout];
    }
}

- (void)setNeedsAdjustingViewFrame:(BOOL)needsAdjustingViewFrame
{
    if (_needsAdjustingViewFrame != needsAdjustingViewFrame) {
        _needsAdjustingViewFrame = needsAdjustingViewFrame;
        if (needsAdjustingViewFrame) {
            [self setNeedsLayout];
        }
    }
}

@end
