//
//  FSCalendarStaticHeader.m
//  FSCalendar
//
//  Created by dingwenchao on 9/17/15.
//  Copyright (c) 2015 wenchaoios. All rights reserved.
//

#import "FSCalendarStickyHeader.h"
#import "FSCalendar.h"
#import "UIView+FSExtension.h"
#import "NSDate+FSExtension.h"
#import "FSCalendarConstance.h"
#import "FSCalendarDynamicHeader.h"

@interface FSCalendarStickyHeader ()

@property (weak, nonatomic) UIView *contentView;
@property (weak, nonatomic) UIView *separator;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (assign, nonatomic) BOOL needsReloadingAppearance;
@property (assign, nonatomic) BOOL needsAdjustingFrames;


- (void)reloadAppearance;

@end

@implementation FSCalendarStickyHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.needsReloadingAppearance = YES;
        self.needsAdjustingFrames = YES;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor clearColor];
        [self addSubview:view];
        self.contentView = view;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        [_contentView addSubview:label];
        self.titleLabel = label;
        
        view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.25];
        [_contentView addSubview:view];
        self.separator = view;
        
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

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    _contentView.frame = self.bounds;
    CGFloat weekdayWidth = self.fs_width / 7.0;
    CGFloat weekdayHeight = _calendar.preferedWeekdayHeight;
    CGFloat weekdayMargin = weekdayHeight * 0.1;
    CGFloat titleWidth = _contentView.fs_width;
    CGFloat titleHeight = _calendar.preferedHeaderHeight;
    CGFloat titleMargin = (titleHeight*0.1+weekdayMargin)*0.4;
    
    [_weekdayLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) { \
        label.frame = CGRectMake(index*weekdayWidth, _contentView.fs_height-weekdayHeight-weekdayMargin, weekdayWidth, weekdayHeight);
    }];
    _separator.frame = CGRectMake(0, _contentView.fs_height-weekdayHeight-weekdayMargin*2, _contentView.fs_width, 1.0);
    _titleLabel.frame = CGRectMake(0, _separator.fs_bottom-titleMargin-titleHeight, titleWidth, titleHeight);
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self reloadData];
    
    if (_needsReloadingAppearance) {
        _needsReloadingAppearance = NO;
        [self reloadAppearance];
    }
}

#pragma mark - Public methods

- (void)reloadData
{
    BOOL useVeryShortWeekdaySymbols = (_appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    NSArray *weekdaySymbols = useVeryShortWeekdaySymbols ? _calendar.calendar.veryShortStandaloneWeekdaySymbols : _calendar.calendar.shortStandaloneWeekdaySymbols;
    BOOL useDefaultWeekdayCase = (_appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesDefaultCase;
    [_weekdayLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        index += _calendar.firstWeekday-1;
        index %= 7;
        label.text = useDefaultWeekdayCase ? weekdaySymbols[index] : [weekdaySymbols[index] uppercaseString];
    }];

    _dateFormatter.dateFormat = _appearance.headerDateFormat;
    _dateFormatter.locale = self.calendar.locale;
    BOOL usesUpperCase = (_appearance.caseOptions & 15) == FSCalendarCaseOptionsHeaderUsesUpperCase;
    NSString *text = [_dateFormatter stringFromDate:_month];
    text = usesUpperCase ? text.uppercaseString : text;
    _titleLabel.text = text;
}

- (void)reloadAppearance
{
    _titleLabel.font = [UIFont systemFontOfSize:self.appearance.headerTitleTextSize];
    _titleLabel.textColor = self.appearance.headerTitleColor;
    [_weekdayLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        label.font = [UIFont systemFontOfSize:self.appearance.weekdayTextSize];
        label.textColor = self.appearance.weekdayTextColor;
    }];
}

@end


