//
//  FSCalendarViewUnit.m
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import "FSCalendarUnit.h"
#import "FSCalendarPage.h"
#import "NSDate+FSExtension.h"
#import "UIView+FSExtension.h"

#define kAnimationDuration 0.12
#define kPink [UIColor colorWithRed:198/255.0 green:51/255.0 blue:42/255.0 alpha:1.0]
#define kBlue [UIColor colorWithRed:31/255.0 green:119/255.0 blue:219/255.0 alpha:1.0]

@interface FSCalendarUnit ()

@property (strong, nonatomic) UILabel *titleLabel;

@property (readonly, nonatomic) FSCalendarUnitState absoluteState;
@property (readonly, nonatomic) CGFloat diameter;

@property (strong, nonatomic) NSMutableDictionary *unitColors;
@property (strong, nonatomic) NSMutableDictionary *titleColors;
@property (strong, nonatomic) NSMutableDictionary *subtitleColors;

@property (strong, nonatomic) CAShapeLayer *animLayer;
@property (strong, nonatomic) CAShapeLayer *eventLayer;

- (void)handleTap:(FSCalendarUnit *)unit;

@end

@implementation FSCalendarUnit

@synthesize titleFont = _titleFont, diameter = _diameter;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:_titleLabel];

        _titleFont = _titleLabel.font;
        _subtitleFont = [_titleFont fontWithSize:11];
        
        _unitColors = [NSMutableDictionary dictionaryWithCapacity:4];
        _unitColors[@(FSCalendarUnitStateNormal)] = [UIColor clearColor];
        _unitColors[@(FSCalendarUnitStateSelected)] = kBlue;
        _unitColors[@(FSCalendarUnitStateDisabled)] = [UIColor clearColor];
        _unitColors[@(FSCalendarUnitStatePlaceholder)] = [UIColor clearColor];
        _unitColors[@(FSCalendarUnitStateToday)] = kPink;
        
        _titleColors = [NSMutableDictionary dictionaryWithCapacity:4];
        _titleColors[@(FSCalendarUnitStateNormal)] = [UIColor darkTextColor];
        _titleColors[@(FSCalendarUnitStateWeekend)] = [UIColor darkTextColor];
        _titleColors[@(FSCalendarUnitStateSelected)] = [UIColor whiteColor];
        _titleColors[@(FSCalendarUnitStateDisabled)] = [UIColor grayColor];
        _titleColors[@(FSCalendarUnitStatePlaceholder)] = [UIColor lightGrayColor];
        _titleColors[@(FSCalendarUnitStateToday)] = [UIColor whiteColor];
        
        _subtitleColors = [NSMutableDictionary dictionaryWithCapacity:4];
        _subtitleColors[@(FSCalendarUnitStateNormal)] = [UIColor darkGrayColor];
        _subtitleColors[@(FSCalendarUnitStateWeekend)] = [UIColor darkGrayColor];
        _subtitleColors[@(FSCalendarUnitStateSelected)] = [UIColor whiteColor];
        _subtitleColors[@(FSCalendarUnitStateDisabled)] = [UIColor lightGrayColor];
        _subtitleColors[@(FSCalendarUnitStatePlaceholder)] = [UIColor lightGrayColor];
        _subtitleColors[@(FSCalendarUnitStateToday)] = [UIColor whiteColor];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        tapGesture.cancelsTouchesInView = NO;
        tapGesture.delaysTouchesBegan = NO;
        [self addGestureRecognizer:tapGesture];
        
        _animation = FSCalendarUnitAnimationScale;
        
        _eventLayer = [CAShapeLayer layer];
        _eventLayer.backgroundColor = [UIColor clearColor].CGColor;
        _eventLayer.fillColor = [UIColor cyanColor].CGColor;
        _eventLayer.path = [UIBezierPath bezierPathWithOvalInRect:_eventLayer.bounds].CGPath;
        [self.layer addSublayer:_eventLayer];
        
        _animLayer = [CAShapeLayer layer];
        [self.layer insertSublayer:_animLayer below:_titleLabel.layer];
        _style = FSCalendarUnitStyleCircle;
        
        self.clipsToBounds  = NO;
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    if (layer == self.layer) {
        CGFloat diameter = self.diameter;
        _animLayer.frame = CGRectMake((self.fs_width-diameter)/2, (_titleLabel.fs_height-diameter)/2, diameter, diameter);
        switch (self.style) {
            case FSCalendarUnitStyleCircle:
                _animLayer.path = [UIBezierPath bezierPathWithOvalInRect:_animLayer.bounds].CGPath;
                break;
            case FSCalendarUnitStyleRectangle:
                _animLayer.path = [UIBezierPath bezierPathWithRect:_animLayer.bounds].CGPath;
                break;
            default:
                break;
        }
        _animLayer.fillColor = [self unitColorForState:self.absoluteState].CGColor;
        
        
        _eventLayer.frame = CGRectMake((_animLayer.frame.size.width-5)/2+_animLayer.frame.origin.x, CGRectGetMaxY(_animLayer.frame), 5, 5);
        _eventLayer.path = [UIBezierPath bezierPathWithOvalInRect:_eventLayer.bounds].CGPath;
        _eventLayer.hidden = ![self.dataSource hasEventForUnit:self];
        
        if ([self isSelected]) {
            [self showAnimation];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _titleLabel.frame = self.bounds;
    _titleLabel.fs_left = (self.fs_width - _titleLabel.fs_width)/2.0;
    
    
    if (_date) {
        // set attribute title
        _titleLabel.numberOfLines = 1;
        
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", @(_date.fs_day)] attributes:
                                                      @{NSForegroundColorAttributeName:[self titleColorForState:self.absoluteState],NSFontAttributeName:_titleFont}];
        NSString *subtitle = [_dataSource subtitleForUnit:self];
        if (subtitle && ![subtitle isEqualToString:@""]) {
            _titleLabel.numberOfLines = 2;
            NSAttributedString *subtitleString = [[NSAttributedString alloc] initWithString:subtitle attributes:@{NSForegroundColorAttributeName:[self subtitleColorForState:self.absoluteState], NSFontAttributeName: _subtitleFont}];
            [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            [attributeString appendAttributedString:subtitleString];
        }
        
        NSMutableParagraphStyle *paragraph = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraph.lineSpacing = 0;
        paragraph.alignment = NSTextAlignmentCenter;
        paragraph.maximumLineHeight = _titleFont.lineHeight * 0.6;
        [attributeString addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, attributeString.length)];
        
        _titleLabel.attributedText = attributeString;
        _titleLabel.fs_top += _titleFont.lineHeight * 0.1;
    }
}

#pragma mark - Public

- (void)setDate:(NSDate *)date
{
    if (![_date isEqualToDate:date]) {
        _date = [date copy];
    }
    [self setNeedsLayout];
}

- (void)setUnitColor:(UIColor *)backgroundColor forState:(FSCalendarUnitState)state
{
    if ([[self unitColorForState:state] isEqual:backgroundColor]) {
        return;
    }
    if (backgroundColor) {
        _unitColors[@(state)] = backgroundColor;
    } else {
        [_unitColors removeObjectForKey:@(state)];
    }
    [self setNeedsLayout];
}

- (UIColor *)unitColorForState:(FSCalendarUnitState)state
{
    return _unitColors[@(state)];
}

- (void)setTitleColor:(UIColor *)titleColor forState:(FSCalendarUnitState)state
{
    if ([[self titleColorForState:state] isEqual:titleColor]) {
        return;
    }
    if (titleColor) {
        _titleColors[@(state)] = titleColor;
    } else {
        [_titleColors removeObjectForKey:@(state)];
    }
    [self setNeedsLayout];
}

- (UIColor *)titleColorForState:(FSCalendarUnitState)state
{
    return _titleColors[@(state)];
}

- (void)setSubtitleColor:(UIColor *)subtitleColor forState:(FSCalendarUnitState)state
{
    if ([[self subtitleColorForState:state] isEqual:subtitleColor]) {
        return;
    }
    if (subtitleColor) {
        _subtitleColors[@(state)] = subtitleColor;
    } else {
        [_subtitleColors removeObjectForKey:@(state)];
    }
    [self setNeedsLayout];
}

- (UIColor *)subtitleColorForState:(FSCalendarUnitState)state
{
    return _subtitleColors[@(state)];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    if (_titleFont != titleFont) {
        _titleFont = titleFont;
        _diameter = [@"1\n1" boundingRectWithSize:self.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_titleFont} context:nil].size.height + 1;
        [self setNeedsLayout];
    }
}

- (void)setSubtitleFont:(UIFont *)subtitleFont
{
    if (_subtitleFont != subtitleFont) {
        _subtitleFont = subtitleFont;
        [self setNeedsLayout];
    }
}

- (void)setEventColor:(UIColor *)eventColor
{
    _eventLayer.fillColor = eventColor.CGColor;
}

- (UIColor *)eventColor
{
    return [UIColor colorWithCGColor:_eventLayer.fillColor];
}

- (void)setStyle:(FSCalendarUnitStyle)style
{
    if (_style != style) {
        _style = style;
        [self setNeedsLayout];
    }
}

#pragma mark - Target Action

- (void)handleTap:(id)sender
{
    [self.delegate handleUnitTap:self];
}

#pragma mark - Private

- (CGFloat)diameter
{
    if (!_diameter) {
        _diameter = [@"1\n1" boundingRectWithSize:self.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_titleFont} context:nil].size.height;
    }
    return _diameter;
}

- (BOOL)isSelected
{
    return [self.dataSource unitIsSelected:self];
}

- (BOOL)isPlaceholder
{
    return [_dataSource unitIsPlaceholder:self];
}

- (BOOL)isToday
{
    return [_dataSource unitIsToday:self];
}

- (BOOL)isWeekend
{
    return self.date.fs_weekday == 1 || self.date.fs_weekday == 7;
}

- (void)showAnimation
{
    if (_animation == FSCalendarUnitAnimationNone) {
        return;
    }
    if (_animation == FSCalendarUnitAnimationScale) {
        CAAnimationGroup *group = [CAAnimationGroup animation];
        CABasicAnimation *zoomOut = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        zoomOut.fromValue = @0.3;
        zoomOut.toValue = @1.2;
        zoomOut.duration = kAnimationDuration/4*3;
        CABasicAnimation *zoomIn = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        zoomIn.fromValue = @1.2;
        zoomIn.toValue = @1.0;
        zoomIn.beginTime = kAnimationDuration/4*3;
        zoomIn.duration = kAnimationDuration/4;
        group.duration = kAnimationDuration;
        group.animations = @[zoomOut, zoomIn];
        [_animLayer addAnimation:group forKey:@"bounce"];
        
    } else if (_animation == FSCalendarUnitAnimationShade) {
        [UIView transitionWithView:self duration:kAnimationDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self setNeedsLayout];
        } completion:nil];
    }
    
}

- (FSCalendarUnitState)absoluteState
{
    if (self.isSelected) {
        return FSCalendarUnitStateSelected;
    }
    if (self.isToday) {
        return FSCalendarUnitStateToday;
    }
    if (self.isPlaceholder) {
        return FSCalendarUnitStatePlaceholder;
    }
    if (self.isWeekend) {
        return FSCalendarUnitStateWeekend;
    }
    return FSCalendarUnitStateNormal;
}


@end


