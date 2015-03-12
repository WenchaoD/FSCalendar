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

#define kAnimationDuration 0.15

#define kTitleHeight self.contentView.fs_height*5.0/6.0
#define kDiameter MIN(self.contentView.fs_height*5.0/6.0,self.contentView.fs_width)

@interface FSCalendarCell ()

@property (readonly, nonatomic) UICollectionView *collectionView;
@property (readonly, nonatomic) FSCalendar *calendar;

@property (strong, nonatomic) CAShapeLayer *backgroundLayer;
@property (strong, nonatomic) CAShapeLayer *eventLayer;

@property (nonatomic, readonly, getter = isPlaceholder) BOOL placeholder;
@property (nonatomic, readonly, getter = isToday) BOOL today;
@property (nonatomic, readonly, getter = isWeekend) BOOL weekend;

- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary;

- (void)configureCell;

@end

@implementation FSCalendarCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor darkTextColor];
        [self.contentView addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.font = [UIFont systemFontOfSize:10];
        _subtitleLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_subtitleLabel];
        
        _backgroundLayer = [CAShapeLayer layer];
        _backgroundLayer.backgroundColor = [UIColor clearColor].CGColor;
        _backgroundLayer.hidden = YES;
        _backgroundLayer.anchorPoint = CGPointMake(0.5, 0.5);
        [self.contentView.layer insertSublayer:_backgroundLayer below:_titleLabel.layer];
        
        _eventLayer = [CAShapeLayer layer];
        _eventLayer.backgroundColor = [UIColor clearColor].CGColor;
        _eventLayer.fillColor = [UIColor cyanColor].CGColor;
        _eventLayer.path = [UIBezierPath bezierPathWithOvalInRect:_eventLayer.bounds].CGPath;
        [self.contentView.layer addSublayer:_eventLayer];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _backgroundLayer.frame = CGRectMake((self.contentView.fs_width-kDiameter)/2,
                                        (kTitleHeight-kDiameter)/2,
                                        kDiameter,
                                        kDiameter);
    
    CGFloat eventSize = _backgroundLayer.frame.size.height/6.0;
    _eventLayer.frame = CGRectMake((_backgroundLayer.frame.size.width-eventSize)/2+_backgroundLayer.frame.origin.x, CGRectGetMaxY(_backgroundLayer.frame)+eventSize*0.2, eventSize*0.8, eventSize*0.8);
    _eventLayer.path = [UIBezierPath bezierPathWithOvalInRect:_eventLayer.bounds].CGPath;
}

#pragma mark - Setters

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (!_backgroundLayer.hidden) {
        _backgroundLayer.hidden = YES;
    }
    if (selected) {
        [self showAnimation];
    }
    [self configureCell];
}

- (void)setDate:(NSDate *)date
{
    if (![_date isEqualToDate:date]) {
        _date = date;
    }
    [self configureCell];
}



#pragma mark - Private

- (UICollectionView *)collectionView
{
    UIView *superview = self.superview;
    while (superview && ![superview isKindOfClass:[UICollectionView class]]) {
        superview = superview.superview;
    }
    return (UICollectionView *)superview;
}

- (FSCalendar *)calendar
{
    return (FSCalendar *)self.collectionView.superview;
}

- (void)configureCell
{
    _titleLabel.text = [NSString stringWithFormat:@"%@",@(_date.fs_day)];
    if (self.calendar.dataSource && [self.calendar.dataSource respondsToSelector:@selector(calendar:subtitleForDate:)]) {
        _subtitleLabel.text = [self.calendar.dataSource calendar:self.calendar subtitleForDate:_date];
    } else {
        _subtitleLabel.text = nil;
    }
    _titleLabel.textColor = [self colorForCurrentStateInDictionary:_titleColors];
    _subtitleLabel.textColor = [self colorForCurrentStateInDictionary:_subtitleColors];
    _backgroundLayer.fillColor = [self colorForCurrentStateInDictionary:_backgroundColors].CGColor;
    
    CGFloat titleHeight = [_titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].height;
    if (_subtitleLabel.text) {
        _subtitleLabel.hidden = NO;
        CGFloat subtitleHeight = [_subtitleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.subtitleLabel.font}].height;
        CGFloat height = titleHeight + subtitleHeight;
        _titleLabel.frame = CGRectMake(0,
                                       (kTitleHeight-height)*0.5,
                                       self.fs_width,
                                       titleHeight);
        
        _subtitleLabel.frame = CGRectMake(0,
                                          height-subtitleHeight,
                                          self.fs_width,
                                          subtitleHeight);
        _subtitleLabel.textColor = [self colorForCurrentStateInDictionary:_subtitleColors];
    } else {
        _titleLabel.frame = CGRectMake(0, 0, self.fs_width, floor(kTitleHeight));
        _subtitleLabel.hidden = YES;
    }
        if (self.calendar.dataSource && [self.calendar.dataSource respondsToSelector:@selector(calendar:hasEventForDate:)]) {
        _eventLayer.hidden = [self.calendar.dataSource calendar:self.calendar hasEventForDate:_date];
    } else {
        _eventLayer.hidden = YES;
    }
}

- (BOOL)isPlaceholder
{
    return !(_date.fs_year == _month.fs_year && _date.fs_month == _month.fs_month);
}

- (BOOL)isToday
{
    return _date.fs_year == self.calendar.currentDate.fs_year && _date.fs_month == self.calendar.currentDate.fs_month && _date.fs_day == self.calendar.currentDate.fs_day;
}

- (BOOL)isWeekend
{
    return self.date.fs_weekday == 1 || self.date.fs_weekday == 7;
}

- (void)showAnimation
{
    _backgroundLayer.hidden = NO;
    _backgroundLayer.path = [UIBezierPath bezierPathWithOvalInRect:_backgroundLayer.bounds].CGPath;
    _backgroundLayer.fillColor = [self colorForCurrentStateInDictionary:_backgroundColors].CGColor;
    _backgroundLayer.anchorPoint = CGPointMake(0.5, 0.5);
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
}

- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary
{
    if (self.isSelected) {
        return dictionary[@(FSCalendarUnitStateSelected)];
    }
    if (self.isToday) {
        return dictionary[@(FSCalendarUnitStateToday)];
    }
    if (self.isPlaceholder) {
        return dictionary[@(FSCalendarUnitStatePlaceholder)];
    }
    if (self.isWeekend) {
        return dictionary[@(FSCalendarUnitStateWeekend)];
    }
    return dictionary[@(FSCalendarUnitStateNormal)];
}

@end
