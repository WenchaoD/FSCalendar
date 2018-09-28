//
//  FSCalendarStaticHeader.m
//  FSCalendar
//
//  Created by dingwenchao on 9/17/15.
//  Copyright (c) 2015 Wenchao Ding. All rights reserved.
//

#import "FSCalendarStickyHeader.h"
#import "FSCalendar.h"
#import "FSCalendarWeekdayView.h"
#import "FSCalendarExtensions.h"
#import "FSCalendarConstants.h"
#import "FSCalendarDynamicHeader.h"

@interface FSCalendarStickyHeader ()

@property (weak  , nonatomic) UIView  *contentView;
@property (weak  , nonatomic) UIView  *bottomBorder;
@property (weak  , nonatomic) FSCalendarWeekdayView *weekdayView;

@end

@implementation FSCalendarStickyHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
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
        
        FSCalendarWeekdayView *weekdayView = [[FSCalendarWeekdayView alloc] init];
        [self.contentView addSubview:weekdayView];
        self.weekdayView = weekdayView;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _contentView.frame = self.bounds;
    
    CGFloat weekdayHeight = _calendar.preferredWeekdayHeight;
    CGFloat weekdayMargin = weekdayHeight * 0.1;
    CGFloat titleWidth = _contentView.fs_width;
    
    self.weekdayView.frame = CGRectMake(0, _contentView.fs_height-weekdayHeight-weekdayMargin, self.contentView.fs_width, weekdayHeight);
    
    CGFloat titleHeight = [@"1" sizeWithAttributes:@{NSFontAttributeName:self.calendar.appearance.headerTitleFont}].height*1.5 + weekdayMargin*3;
    
    _bottomBorder.frame = CGRectMake(0, _contentView.fs_height-weekdayHeight-weekdayMargin*2, _contentView.fs_width, 1.0);
    _titleLabel.frame = CGRectMake(0, _bottomBorder.fs_bottom-titleHeight-weekdayMargin, titleWidth,titleHeight);
    
}

#pragma mark - Properties

- (void)setCalendar:(FSCalendar *)calendar
{
    if (![_calendar isEqual:calendar]) {
        _calendar = calendar;
        _weekdayView.calendar = calendar;
        [self configureAppearance];
    }
}

#pragma mark - Private methods

- (void)configureAppearance
{
    _titleLabel.font = self.calendar.appearance.headerTitleFont;
    _titleLabel.textColor = self.calendar.appearance.headerTitleColor;
    [self.weekdayView configureAppearance];
}

- (void)setMonth:(NSDate *)month
{
    _month = month;
    _calendar.formatter.dateFormat = self.calendar.appearance.headerDateFormat;
    BOOL usesUpperCase = (self.calendar.appearance.caseOptions & 15) == FSCalendarCaseOptionsHeaderUsesUpperCase;
    NSString *text = [_calendar.formatter stringFromDate:_month];
    text = usesUpperCase ? text.uppercaseString : text;
    self.titleLabel.text = text;
}

@end


