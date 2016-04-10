//
//  FSCalendarCell.m
//  Pods
//
//  Created by Wenchao Ding on 12/3/15.
//
//

#import "FSCalendarCell.h"
#import "FSCalendar.h"
#import "UIView+FSExtension.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarConstance.h"

@interface FSCalendarCell ()

@property (readonly, nonatomic) UIColor *colorForCellFill;
@property (readonly, nonatomic) UIColor *colorForTitleLabel;
@property (readonly, nonatomic) UIColor *colorForSubtitleLabel;
@property (readonly, nonatomic) UIColor *colorForCellBorder;
@property (readonly, nonatomic) FSCalendarCellShape cellShape;

@end

@implementation FSCalendarCell

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _needsAdjustingViewFrame = YES;
        
        UILabel *label;
        CAShapeLayer *shapeLayer;
        UIImageView *imageView;
        FSCalendarEventIndicator *eventIndicator;
        
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        [self.contentView addSubview:label];
        self.titleLabel = label;
        
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:label];
        self.subtitleLabel = label;
        
        shapeLayer = [CAShapeLayer layer];
        shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
        shapeLayer.hidden = YES;
        [self.contentView.layer insertSublayer:shapeLayer below:_titleLabel.layer];
        self.shapeLayer = shapeLayer;
        
        eventIndicator = [[FSCalendarEventIndicator alloc] initWithFrame:CGRectZero];
        eventIndicator.backgroundColor = [UIColor clearColor];
        eventIndicator.hidden = YES;
        [self.contentView addSubview:eventIndicator];
        self.eventIndicator = eventIndicator;
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.contentMode = UIViewContentModeBottom|UIViewContentModeCenter;
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        
        self.clipsToBounds = NO;
        self.contentView.clipsToBounds = NO;
        
    }
    return self;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    CGFloat titleHeight = self.bounds.size.height*5.0/6.0;
    CGFloat diameter = MIN(self.bounds.size.height*5.0/6.0,self.bounds.size.width);
    diameter = diameter > FSCalendarStandardCellDiameter ? (diameter - (diameter-FSCalendarStandardCellDiameter)*0.5) : diameter;
    _shapeLayer.frame = CGRectMake((self.bounds.size.width-diameter)/2,
                                        (titleHeight-diameter)/2,
                                        diameter,
                                        diameter);
    _shapeLayer.borderWidth = 1.0;
    _shapeLayer.borderColor = [UIColor clearColor].CGColor;
    
    CGFloat eventSize = _shapeLayer.frame.size.height/6.0;
    _eventIndicator.frame = CGRectMake(0, CGRectGetMaxY(_shapeLayer.frame)+eventSize*0.17, bounds.size.width, eventSize*0.83);
    _imageView.frame = self.contentView.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self configureCell];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [CATransaction setDisableActions:YES];
    _shapeLayer.hidden = YES;
    [self.contentView.layer removeAnimationForKey:@"opacity"];
}

#pragma mark - Public

- (void)performSelecting
{
    _shapeLayer.hidden = NO;
    
#define kAnimationDuration FSCalendarDefaultBounceAnimationDuration
    
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
    [_shapeLayer addAnimation:group forKey:@"bounce"];
    [self configureCell];
    
#undef kAnimationDuration
    
}

#pragma mark - Private

- (void)configureCell
{
    self.contentView.hidden = self.dateIsPlaceholder && !self.calendar.showsPlaceholders;
    if (self.contentView.hidden) {
        return;
    }
    _titleLabel.text = [NSString stringWithFormat:@"%@",@([_calendar dayOfDate:_date])];
    if (_subtitle) {
        _subtitleLabel.text = _subtitle;
        if (_subtitleLabel.hidden) {
            _subtitleLabel.hidden = NO;
        }
    } else {
        if (!_subtitleLabel.hidden) {
            _subtitleLabel.hidden = YES;
        }
    }
    if (_needsAdjustingViewFrame || CGSizeEqualToSize(_titleLabel.frame.size, CGSizeZero)) {
        _needsAdjustingViewFrame = NO;
        
        if (_subtitle) {
            CGFloat titleHeight = [@"1" sizeWithAttributes:@{NSFontAttributeName:_titleLabel.font}].height;
            CGFloat subtitleHeight = [@"1" sizeWithAttributes:@{NSFontAttributeName:_subtitleLabel.font}].height;

            CGFloat height = titleHeight + subtitleHeight;
            _titleLabel.frame = CGRectMake(0,
                                           (self.contentView.fs_height*5.0/6.0-height)*0.5+_appearance.titleVerticalOffset,
                                           self.fs_width,
                                           titleHeight);
            
            _subtitleLabel.frame = CGRectMake(0,
                                              _titleLabel.fs_bottom - (_titleLabel.fs_height-_titleLabel.font.pointSize)+_appearance.subtitleVerticalOffset,
                                              self.fs_width,
                                              subtitleHeight);
        } else {
            _titleLabel.frame = CGRectMake(0, _appearance.titleVerticalOffset, self.contentView.fs_width, floor(self.contentView.fs_height*5.0/6.0));
        }
        
    }
    
    UIColor *textColor = self.colorForTitleLabel;
    if (![textColor isEqual:_titleLabel.textColor]) {
        _titleLabel.textColor = textColor;
    }
    if (_subtitle) {
        textColor = self.colorForSubtitleLabel;
        if (![textColor isEqual:_subtitleLabel.textColor]) {
            _subtitleLabel.textColor = textColor;
        }
    }
    
    UIColor *borderColor = self.colorForCellBorder;
    UIColor *fillColor = self.colorForCellFill;

    BOOL shouldHideShapeLayer = !self.selected && !self.dateIsToday && !self.dateIsSelected && !borderColor && !fillColor;
    
    if (_shapeLayer.hidden != shouldHideShapeLayer) {
        _shapeLayer.hidden = shouldHideShapeLayer;
    }
    if (!shouldHideShapeLayer) {
        
        CGPathRef path = self.cellShape == FSCalendarCellShapeCircle ?
        [UIBezierPath bezierPathWithOvalInRect:_shapeLayer.bounds].CGPath :
        [UIBezierPath bezierPathWithRect:_shapeLayer.bounds].CGPath;
        if (!CGPathEqualToPath(_shapeLayer.path,path)) {
            _shapeLayer.path = path;
        }
        
        CGColorRef fillColor = self.colorForCellFill.CGColor;
        if (!CGColorEqualToColor(_shapeLayer.fillColor, fillColor)) {
            _shapeLayer.fillColor = fillColor;
        }
        
        CGColorRef borderColor = self.colorForCellBorder.CGColor;
        if (!CGColorEqualToColor(_shapeLayer.strokeColor, borderColor)) {
            _shapeLayer.strokeColor = borderColor;
        }
        
    }
    
    if (![_image isEqual:_imageView.image]) {
        [self invalidateImage];
    }
    
    if (_eventIndicator.hidden == (_numberOfEvents > 0)) {
        _eventIndicator.hidden = !_numberOfEvents;
    }
    _eventIndicator.numberOfEvents = self.numberOfEvents;
    _eventIndicator.color = self.preferredEventColor ?: _appearance.eventColor;
}

- (BOOL)isWeekend
{
    return _date && ([_calendar weekdayOfDate:_date] == 1 || [_calendar weekdayOfDate:_date] == 7);
}

- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary
{
    if (self.isSelected || self.dateIsSelected) {
        if (self.dateIsToday) {
            return dictionary[@(FSCalendarCellStateSelected|FSCalendarCellStateToday)] ?: dictionary[@(FSCalendarCellStateSelected)];
        }
        return dictionary[@(FSCalendarCellStateSelected)];
    }
    if (self.dateIsToday && [[dictionary allKeys] containsObject:@(FSCalendarCellStateToday)]) {
        return dictionary[@(FSCalendarCellStateToday)];
    }
    if (self.dateIsPlaceholder && [[dictionary allKeys] containsObject:@(FSCalendarCellStatePlaceholder)]) {
        return dictionary[@(FSCalendarCellStatePlaceholder)];
    }
    if (self.isWeekend && [[dictionary allKeys] containsObject:@(FSCalendarCellStateWeekend)]) {
        return dictionary[@(FSCalendarCellStateWeekend)];
    }
    return dictionary[@(FSCalendarCellStateNormal)];
}

- (void)invalidateTitleFont
{
    _titleLabel.font = self.appearance.preferredTitleFont;
}

- (void)invalidateTitleTextColor
{
    _titleLabel.textColor = self.colorForTitleLabel;
}

- (void)invalidateSubtitleFont
{
    _subtitleLabel.font = self.appearance.preferredSubtitleFont;
}

- (void)invalidateSubtitleTextColor
{
    _subtitleLabel.textColor = self.colorForSubtitleLabel;
}

- (void)invalidateBorderColors
{
    _shapeLayer.strokeColor = self.colorForCellBorder.CGColor;
}

- (void)invalidateFillColors
{
    _shapeLayer.fillColor = self.colorForCellFill.CGColor;
}

- (void)invalidateEventColors
{
    _eventIndicator.color = self.preferredEventColor ?: _appearance.eventColor;
}

- (void)invalidateCellShapes
{
    CGPathRef path = self.cellShape == FSCalendarCellShapeCircle ?
    [UIBezierPath bezierPathWithOvalInRect:_shapeLayer.bounds].CGPath :
    [UIBezierPath bezierPathWithRect:_shapeLayer.bounds].CGPath;
    _shapeLayer.path = path;
}

- (void)invalidateImage
{
    _imageView.image = _image;
    _imageView.hidden = !_image;
}

#pragma mark - Properties

- (UIColor *)colorForCellFill
{
    if (self.dateIsSelected || self.isSelected) {
        return self.preferredFillSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.backgroundColors];
    }
    return self.preferredFillDefaultColor ?: [self colorForCurrentStateInDictionary:_appearance.backgroundColors];
}

- (UIColor *)colorForTitleLabel
{
    if (self.dateIsSelected || self.isSelected) {
        return self.preferredTitleSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.titleColors];
    }
    return self.preferredTitleDefaultColor ?: [self colorForCurrentStateInDictionary:_appearance.titleColors];
}

- (UIColor *)colorForSubtitleLabel
{
    if (self.dateIsSelected || self.isSelected) {
        return self.preferredSubtitleSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.subtitleColors];
    }
    return self.preferredSubtitleDefaultColor ?: [self colorForCurrentStateInDictionary:_appearance.subtitleColors];
}

- (UIColor *)colorForCellBorder
{
    if (self.dateIsSelected || self.isSelected) {
        return _preferredBorderSelectionColor ?: _appearance.borderSelectionColor;
    }
    return _preferredBorderDefaultColor ?: _appearance.borderDefaultColor;
}

- (FSCalendarCellShape)cellShape
{
    return _preferredCellShape ?: _appearance.cellShape;
}

- (void)setCalendar:(FSCalendar *)calendar
{
    if (![_calendar isEqual:calendar]) {
        _calendar = calendar;
    }
    if (![_appearance isEqual:calendar.appearance]) {
        _appearance = calendar.appearance;
        [self invalidateTitleFont];
        [self invalidateSubtitleFont];
        [self invalidateTitleTextColor];
        [self invalidateSubtitleTextColor];
        [self invalidateEventColors];
    }
}

- (void)setSubtitle:(NSString *)subtitle
{
    if (![_subtitle isEqualToString:subtitle]) {
        _needsAdjustingViewFrame = !(_subtitle.length && subtitle.length);
        _subtitle = subtitle;
        if (_needsAdjustingViewFrame) {
            [self setNeedsLayout];
        }
    }
}

- (void)setNeedsAdjustingViewFrame:(BOOL)needsAdjustingViewFrame
{
    if (_needsAdjustingViewFrame != needsAdjustingViewFrame) {
        _needsAdjustingViewFrame = needsAdjustingViewFrame;
        _eventIndicator.needsAdjustingViewFrame = needsAdjustingViewFrame;
    }
}

@end



