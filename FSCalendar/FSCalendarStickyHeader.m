//
//  FSCalendarStaticHeader.m
//  FSCalendar
//
//  Created by dingwenchao on 9/17/15.
//  Copyright (c) 2015 wenchaoios. All rights reserved.
//

#import "FSCalendarStickyHeader.h"
#import "FSCalendar.h"
#import "FSCalendarExtensions.h"
#import "FSCalendarConstants.h"
#import "FSCalendarDynamicHeader.h"

@interface FSCalendarStickyHeader ()

@property (weak  , nonatomic) UIView      *contentView;
@property (weak  , nonatomic) UIView      *bottomBorder;
@property (weak  , nonatomic) UIImageView *weekdayView;

@property (assign, nonatomic) BOOL needsAdjustingViewFrame;

@end

@implementation FSCalendarStickyHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _needsAdjustingViewFrame = YES;
        
        UIView *view;
        UILabel *label;
        
        view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor clearColor];
        [self addSubview:view];
        self.contentView = view;
        
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        [_contentView addSubview:label];
        self.titleLabel = label;
        
        view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = FSCalendarStandardLineColor;
        [_contentView addSubview:view];
        self.bottomBorder = view;
        
        NSMutableArray *weekdayLabels = [NSMutableArray arrayWithCapacity:7];
        for (int i = 0; i < 7; i++) {
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.textAlignment = NSTextAlignmentCenter;
            [_contentView addSubview:label];
            [weekdayLabels addObject:label];
        }
        self.weekdayLabels = weekdayLabels.copy;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_needsAdjustingViewFrame) {
        
        _needsAdjustingViewFrame = NO;
        _contentView.frame = self.bounds;

        CGFloat weekdayWidth = self.fs_width / 7.0;
        CGFloat weekdayHeight = _calendar.preferredWeekdayHeight;
        CGFloat weekdayMargin = weekdayHeight * 0.1;
        CGFloat titleWidth = _contentView.fs_width;
        
        [_weekdayLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) { \
            label.frame = CGRectMake(index*weekdayWidth, _contentView.fs_height-weekdayHeight-weekdayMargin, weekdayWidth, weekdayHeight);
        }];
        
        CGFloat titleHeight = [@"1" sizeWithAttributes:@{NSFontAttributeName:_appearance.preferredHeaderTitleFont}].height*1.5 + weekdayMargin*3;
        
        _bottomBorder.frame = CGRectMake(0, _contentView.fs_height-weekdayHeight-weekdayMargin*2, _contentView.fs_width, 1.0);
        _titleLabel.frame = CGRectMake(0, _bottomBorder.fs_bottom-titleHeight-weekdayMargin, titleWidth,titleHeight);
        
        self.weekdayView.frame = CGRectMake(self.weekdayLabels.firstObject.fs_left, self.weekdayLabels.firstObject.fs_top, self.weekdayLabels.lastObject.fs_right, self.weekdayLabels.firstObject.fs_height);
        
    }
    
    [self reloadData];
}

#pragma mark - Properties

- (void)setCalendar:(FSCalendar *)calendar
{
    if (![_calendar isEqual:calendar]) {
        _calendar = calendar;
    }
    if (![_appearance isEqual:calendar.appearance]) {
        _appearance = calendar.appearance;
        [self invalidateHeaderFont];
        [self invalidateHeaderTextColor];
        [self invalidateWeekdayFont];
        [self invalidateWeekdayTextColor];
        [self invalidateWeekdayBackground];
    }
}

#pragma mark - Public methods

- (void)reloadData
{
    [self invalidateWeekdaySymbols];
    _calendar.formatter.dateFormat = _appearance.headerDateFormat;
    BOOL usesUpperCase = (_appearance.caseOptions & 15) == FSCalendarCaseOptionsHeaderUsesUpperCase;
    NSString *text = [_calendar.formatter stringFromDate:_month];
    text = usesUpperCase ? text.uppercaseString : text;
    _titleLabel.text = text;
}

#pragma mark - Private methods

- (void)invalidateHeaderFont
{
    _titleLabel.font = _appearance.preferredHeaderTitleFont;
}

- (void)invalidateHeaderTextColor
{
    _titleLabel.textColor = _appearance.headerTitleColor;
}

- (void)invalidateWeekdayFont
{
    [_weekdayLabels makeObjectsPerformSelector:@selector(setFont:) withObject:_appearance.weekdayFont];
}

- (void)invalidateWeekdayTextColor
{
    [_weekdayLabels makeObjectsPerformSelector:@selector(setTextColor:) withObject:_appearance.weekdayTextColor];
}

- (void)invalidateWeekdaySymbols
{
    BOOL useVeryShortWeekdaySymbols = (_appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    NSArray *weekdaySymbols = useVeryShortWeekdaySymbols ? _calendar.gregorian.veryShortStandaloneWeekdaySymbols : _calendar.gregorian.shortStandaloneWeekdaySymbols;
    BOOL useDefaultWeekdayCase = (_appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesDefaultCase;
    [_weekdayLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        index += _calendar.firstWeekday-1;
        index %= 7;
        label.text = useDefaultWeekdayCase ? weekdaySymbols[index] : [weekdaySymbols[index] uppercaseString];
    }];
}

- (void)invalidateWeekdayBackground
{
    if (self.appearance.weekdayBackground) {
        if (!self.weekdayView) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            imageView.contentMode = UIViewContentModeCenter;
            [self.contentView insertSubview:imageView belowSubview:self.weekdayLabels.firstObject];
            self.weekdayView = imageView;
        }
        
        self.weekdayView.frame = CGRectMake(self.weekdayLabels.firstObject.fs_left, self.weekdayLabels.firstObject.fs_top, self.weekdayLabels.lastObject.fs_right, self.weekdayLabels.firstObject.fs_height);
        
        if ([self.appearance.weekdayBackground isKindOfClass:[UIImage class]]) {
            self.weekdayView.image = self.appearance.weekdayBackground;
            self.weekdayView.backgroundColor = nil;
        } else {
            self.weekdayView.image = nil;
            self.weekdayView.backgroundColor = self.appearance.weekdayBackground;
        }
    } else {
        self.weekdayView = nil;
    }
}

@end


