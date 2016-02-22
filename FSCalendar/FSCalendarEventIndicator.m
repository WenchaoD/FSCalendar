//
//  FSCalendarEventView.m
//  FSCalendar
//
//  Created by dingwenchao on 2/3/16.
//  Copyright © 2016 wenchaoios. All rights reserved.
//

#import "FSCalendarEventIndicator.h"
#import "FSCalendarConstance.h"
#import "UIView+FSExtension.h"
#import "CALayer+FSExtension.h"

@interface FSCalendarEventIndicator ()

@property (weak, nonatomic) UIView *contentView;

@property (strong, nonatomic) NSMutableArray *eventLayers;

- (void)invalidateColor;

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
            layer.masksToBounds = YES;
            layer.backgroundColor = FSCalendarStandardEventDotColor.CGColor;
            [self.eventLayers addObject:layer];
            [self.contentView.layer addSublayer:layer];
        }
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat diameter = MIN(MIN(self.fs_width, self.fs_height),FSCalendarMaximumEventDotDiameter);
    self.contentView.fs_height = self.fs_height;
    self.contentView.fs_width = (self.numberOfEvents*2-1)*diameter;
    self.contentView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    if (layer == self.layer) {
        CGFloat diameter = MIN(MIN(self.fs_width, self.fs_height),FSCalendarMaximumEventDotDiameter);
        for (int i = 0; i < self.eventLayers.count; i++) {
            CALayer *layer = self.eventLayers[i];
            layer.hidden = i >= self.numberOfEvents;
            if (!layer.hidden) {
                layer.frame = CGRectMake(2*i*diameter, (self.fs_height-diameter)*0.5, diameter, diameter);
                layer.cornerRadius = diameter * 0.5;
            }
        }
    }
}

- (void)setColor:(UIColor *)color
{
    if (![_color isEqual:color]) {
        _color = color;
        [self invalidateColor];
    }
}

- (void)setNumberOfEvents:(NSInteger)numberOfEvents
{
    if (_numberOfEvents != numberOfEvents) {
        _numberOfEvents = MIN(MAX(numberOfEvents,0),3);
        [self setNeedsLayout];
    }
}

- (void)invalidateColor
{
    [self.eventLayers makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:(id)self.color.CGColor];
}

@end
