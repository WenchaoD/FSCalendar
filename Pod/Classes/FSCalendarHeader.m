//
//  FSCalendarHeader.m
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import "FSCalendarHeader.h"
#import "FSCalendar.h"
#import "UIView+FSExtension.h"
#import "NSDate+FSExtension.h"

@interface FSCalendarHeader ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSMutableArray *labels;

@property (readonly, nonatomic) BOOL needUpdate;

@property (assign, nonatomic) CGFloat lastOffset;

@end

@implementation FSCalendarHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _dateFormat = @"yyyy-M";
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat = _dateFormat;
    _minDissolveAlpha = 0.2;
    _titleFont = [UIFont systemFontOfSize:15];
    _titleColor = [self tintColor];
    _labels = [NSMutableArray arrayWithCapacity:5];
    for (int i = 0; i < 5; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textColor = _titleColor;
        label.font = _titleFont;
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.5;
        [_labels addObject:label];
        [self addSubview:label];
        [label addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
}

- (void)dealloc
{
    [_labels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeObserver:self forKeyPath:@"frame"];
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    int width = self.fs_width/2;
    int height = self.fs_height;
    int top = 0;
    [_labels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILabel *label = obj;
        // update position
        int left = width*((int)idx-1.5) - _scrollOffset*width;
        left = (left+(int)(1.5*width)+5*width*abs(_scrollOffset))%(5*width)-(int)(1.5*width);
        label.frame = CGRectMake(left, top, width, height);
        
        // update alpha
        CGFloat center = left + width/2;
        CGFloat alpha = 1.0 - ABS(center-width)/width*(1-_minDissolveAlpha);
        label.alpha = alpha;
    }];
    
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[UILabel class]] && [keyPath isEqualToString:@"frame"]) {
        CGRect oldFrame = [change[NSKeyValueChangeOldKey] CGRectValue];
        if (CGRectEqualToRect(oldFrame, CGRectZero)) {
            return;
        }
        CGRect newFrame = [change[NSKeyValueChangeNewKey] CGRectValue];
        CGFloat distance = newFrame.origin.x - oldFrame.origin.x;
        if (ABS(distance) > self.fs_width) {
            UILabel *label = object;
            NSDate *date = [_dateFormatter dateFromString:label.text];
            if (distance < 0) {
                label.text = [_dateFormatter stringFromDate:[date fs_dateByAddingMonths:-5]];
            } else {
                label.text = [_dateFormatter stringFromDate:[date fs_dateByAddingMonths:5]];
            }
        }
    }
}

#pragma mark - Setter & Getter

- (void)setScrollOffset:(CGFloat)scrollOffset
{
    if (_scrollOffset != scrollOffset) {
        _lastOffset = _scrollOffset;
        _scrollOffset = scrollOffset;
        [self setNeedsLayout];
    }
}

- (void)setCalendar:(FSCalendar *)calendarView
{
    if (_calendar != calendarView) {
        _calendar = calendarView;
        if (!calendarView) {
            return;
        }
        NSDate *currentDate = calendarView.currentMonth;
        NSArray *sortedLabels = [_labels sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSNumber *l1 = @([obj1 fs_left]);
            NSNumber *l2 = @([obj2 fs_left]);
            return [l1 compare:l2];
        }];
        [sortedLabels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setText: [_dateFormatter stringFromDate:[currentDate fs_dateByAddingMonths:idx-2]]];
        }];
    }
}

#pragma mark - Appearance

- (void)setTitleFont:(UIFont *)titleFont
{
    if (![_titleFont isEqual:titleFont]) {
        _titleFont = titleFont;
        [self.labels setValue:titleFont forKeyPath:@"font"];
    }
}

- (void)setTitleColor:(UIColor *)titleColor
{
    if (![_titleColor isEqual:titleColor]) {
        _titleColor = titleColor;
        [self.labels setValue:titleColor forKeyPath:@"textColor"];
    }
}

- (void)setDateFormat:(NSString *)dateFormat
{
    if (![_dateFormat isEqualToString:dateFormat]) {
        [_labels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            _dateFormatter.dateFormat = _dateFormat;
            NSDate *currentDate = [_dateFormatter dateFromString:[obj text]];
            _dateFormatter.dateFormat = dateFormat;
            [obj setText: [_dateFormatter stringFromDate:currentDate]];
        }];
        _dateFormat = [dateFormat copy];
        _dateFormatter.dateFormat = dateFormat;
    }
}

- (void)setMinDissolveAlpha:(CGFloat)minDissolveAlpha
{
    if (_minDissolveAlpha != minDissolveAlpha) {
        _minDissolveAlpha = minDissolveAlpha;
        [self setNeedsLayout];
    }
}

@end
