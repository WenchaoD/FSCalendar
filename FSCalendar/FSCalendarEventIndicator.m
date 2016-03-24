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
@property (assign, nonatomic) BOOL needsInvalidatingColor;

- (UIImage *)dotImageWithColor:(UIColor *)color diameter:(CGFloat)diameter;

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
                CALayer *layer = self.eventLayers[i];
                layer.hidden = i >= self.numberOfEvents;
                if (!layer.hidden) {
                    layer.frame = CGRectMake(2*i*diameter, (self.fs_height-diameter)*0.5, diameter, diameter);
                    layer.cornerRadius = diameter * 0.5;
                }
            }
        }
        if (_needsInvalidatingColor) {
            _needsInvalidatingColor = NO;
            CGFloat diameter = MIN(MIN(self.fs_width, self.fs_height),FSCalendarMaximumEventDotDiameter);
            if ([_color isKindOfClass:[UIColor class]]) {
                UIImage *dotImage = [self dotImageWithColor:_color diameter:diameter];
                [self.eventLayers makeObjectsPerformSelector:@selector(setContents:) withObject:(id)dotImage.CGImage];
            } else if ([_color isKindOfClass:[NSArray class]]) {
                NSArray *colors = (NSArray *)_color;
                if (colors.count) {
                    UIColor *lastColor = colors.firstObject;
                    for (int i = 0; i < self.numberOfEvents; i++) {
                        if (i < colors.count) {
                            lastColor = colors[i];
                        }
                        CALayer *layer = self.eventLayers[i];
                        UIImage *dotImage = [self dotImageWithColor:lastColor diameter:diameter];
                        layer.contents = (id)dotImage.CGImage;
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

- (UIImage *)dotImageWithColor:(UIColor *)color diameter:(CGFloat)diameter
{
    CGRect bounds = CGRectMake(0, 0, diameter, diameter);
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, bounds);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
