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
#import "NSDate+FSExtension.h"
#import "FSCalendarDynamicHeader.h"

#define kAnimationDuration 0.15

@interface FSCalendarCell ()

@property (weak, nonatomic) CAShapeLayer *backgroundLayer;
@property (weak, nonatomic) CAShapeLayer *eventLayer;
@property (weak, nonatomic) CALayer      *imageLayer;

@property (readonly, nonatomic) BOOL         today;
@property (readonly, nonatomic) BOOL         weekend;
@property (readonly, nonatomic) FSCalendar   *calendar;

@property (assign,   nonatomic) BOOL         deselecting;

- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary;

@end

@implementation FSCalendarCell

#pragma mark - Init and life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor darkTextColor];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        subtitleLabel.font = [UIFont systemFontOfSize:10];
        subtitleLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:subtitleLabel];
        self.subtitleLabel = subtitleLabel;
        
        CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
        backgroundLayer.backgroundColor = [UIColor clearColor].CGColor;
        backgroundLayer.hidden = YES;
        [self.contentView.layer insertSublayer:backgroundLayer atIndex:0];
        self.backgroundLayer = backgroundLayer;
        
        CAShapeLayer *eventLayer = [CAShapeLayer layer];
        eventLayer.backgroundColor = [UIColor clearColor].CGColor;
        eventLayer.fillColor = [UIColor cyanColor].CGColor;
        eventLayer.path = [UIBezierPath bezierPathWithOvalInRect:eventLayer.bounds].CGPath;
        eventLayer.hidden = YES;
        [self.contentView.layer addSublayer:eventLayer];
        self.eventLayer = eventLayer;
        
        CALayer *imageLayer = [CALayer layer];
        imageLayer.backgroundColor = [UIColor clearColor].CGColor;
        [self.contentView.layer addSublayer:imageLayer];
        self.imageLayer = imageLayer;
    }
    return self;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    CGFloat titleHeight = self.bounds.size.height*5.0/6.0;
    CGFloat diameter = MIN(self.bounds.size.height*5.0/6.0,self.bounds.size.width);
    _backgroundLayer.frame = CGRectMake((self.bounds.size.width-diameter)/2,
                                        (titleHeight-diameter)/2,
                                        diameter,
                                        diameter);
    
    CGFloat eventSize = _backgroundLayer.frame.size.height/6.0;
    _eventLayer.frame = CGRectMake((_backgroundLayer.frame.size.width-eventSize)/2+_backgroundLayer.frame.origin.x, CGRectGetMaxY(_backgroundLayer.frame)+eventSize*0.2, eventSize*0.8, eventSize*0.8);
    _eventLayer.path = [UIBezierPath bezierPathWithOvalInRect:_eventLayer.bounds].CGPath;
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
}

- (BOOL)isSelected
{
    return [super isSelected] || ([self.calendar.selectedDate fs_isEqualToDateForDay:_date] && !_deselecting);
}

#pragma mark - Public

- (void)performSelecting
{
    _backgroundLayer.hidden = NO;
    _backgroundLayer.path = [UIBezierPath bezierPathWithOvalInRect:_backgroundLayer.bounds].CGPath;
    _backgroundLayer.fillColor = [self colorForCurrentStateInDictionary:_appearance.backgroundColors].CGColor;
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
    [_backgroundLayer addAnimation:group forKey:@"bounce"];
    [self configureCell];
}

- (void)performDeselecting
{
    _deselecting = YES;
    [self configureCell];
    _deselecting = NO;
}

#pragma mark - Private

- (void)configureCell
{
    _titleLabel.font = _appearance.titleFont;
    _titleLabel.text = [NSString stringWithFormat:@"%@",@(_date.fs_day)];
    _subtitleLabel.font = _appearance.subtitleFont;
    _subtitleLabel.text = _subtitle;
    _titleLabel.textColor = [self colorForCurrentStateInDictionary:_appearance.titleColors];
    _subtitleLabel.textColor = [self colorForCurrentStateInDictionary:_appearance.subtitleColors];
    _backgroundLayer.fillColor = [self colorForCurrentStateInDictionary:_appearance.backgroundColors].CGColor;
    
    CGFloat titleHeight = [_titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].height;
    if (_subtitleLabel.text) {
        _subtitleLabel.hidden = NO;
        CGFloat subtitleHeight = [_subtitleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.subtitleLabel.font}].height;
        CGFloat height = titleHeight + subtitleHeight;
        _titleLabel.frame = CGRectMake(0,
                                       (self.contentView.fs_height*5.0/6.0-height)*0.5,
                                       self.fs_width,
                                       titleHeight);
        
        _subtitleLabel.frame = CGRectMake(0,
                                          _titleLabel.fs_bottom - (_titleLabel.fs_height-_titleLabel.font.pointSize),
                                          self.fs_width,
                                          subtitleHeight);
    } else {
        _titleLabel.frame = CGRectMake(0, 0, self.fs_width, floor(self.contentView.fs_height*5.0/6.0));
        _subtitleLabel.hidden = YES;
    }
    _backgroundLayer.hidden = !self.selected && !self.isToday;
    _backgroundLayer.path = _appearance.cellStyle == FSCalendarCellStyleCircle ?
    [UIBezierPath bezierPathWithOvalInRect:_backgroundLayer.bounds].CGPath :
    [UIBezierPath bezierPathWithRect:_backgroundLayer.bounds].CGPath;
    _eventLayer.hidden = !_hasEvent;
    _eventLayer.fillColor = _appearance.eventColor.CGColor;
    
    if (_image) {
        _imageLayer.hidden = NO;
        _imageLayer.frame = CGRectMake((self.fs_width-_image.size.width)*0.5, self.fs_height-_image.size.height, _image.size.width, _image.size.height);
        _imageLayer.contents = (id)_image.CGImage;
    } else {
        _imageLayer.hidden = YES;
        _imageLayer.contents = nil;
    }
}

- (BOOL)isPlaceholder
{
    return ![_date fs_isEqualToDateForMonth:_month];
}

- (BOOL)isToday
{
    return [_date fs_isEqualToDateForDay:self.calendar.currentDate];
}

- (BOOL)isWeekend
{
    return self.date.fs_weekday == 1 || self.date.fs_weekday == 7;
}

- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary
{
    if (self.isSelected) {
        return dictionary[@(FSCalendarCellStateSelected)];
    }
    if (self.isToday) {
        return dictionary[@(FSCalendarCellStateToday)];
    }
    if (self.isPlaceholder) {
        return dictionary[@(FSCalendarCellStatePlaceholder)];
    }
    if (self.isWeekend && [[dictionary allKeys] containsObject:@(FSCalendarCellStateWeekend)]) {
        return dictionary[@(FSCalendarCellStateWeekend)];
    }
    return dictionary[@(FSCalendarCellStateNormal)];
}

- (FSCalendar *)calendar
{
    UIView *superview = self.superview;
    while (superview && ![superview isKindOfClass:[FSCalendar class]]) {
        superview = superview.superview;
    }
    return (FSCalendar *)superview;
}

@end
