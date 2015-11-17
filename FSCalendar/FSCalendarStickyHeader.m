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
#import "FSCalendarConstance.h"
#import "FSCalendarDynamicHeader.h"

@interface FSCalendarStickyHeader ()

@property (weak, nonatomic) UIView *contentView;
@property (weak, nonatomic) UIView *separator;

@property (assign, nonatomic) BOOL needsReloadingAppearance;
@property (assign, nonatomic) BOOL needsAdjustingFrames;


- (void)reloadAppearance;

@end

@implementation FSCalendarStickyHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _needsReloadingAppearance = YES;
        _needsAdjustingFrames = YES;
        
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_needsAdjustingFrames) {
        if (!CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
            _needsAdjustingFrames = NO;
            _contentView.frame = self.bounds;
            CGFloat weekdayWidth = self.fs_width / 7.0;
            CGFloat weekdayHeight = _calendar.preferedWeekdayHeight;
            CGFloat weekdayMargin = weekdayHeight * 0.1;
            CGFloat titleWidth = _contentView.fs_width;
            
            [_weekdayLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) { \
                label.frame = CGRectMake(index*weekdayWidth, _contentView.fs_height-weekdayHeight-weekdayMargin, weekdayWidth, weekdayHeight);
            }];
            
#define m_calculate \
        CGFloat titleHeight = [@"1" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:_appearance.titleTextSize]}].height*1.5 + weekdayMargin*3;
            
#define m_adjust \
        _separator.frame = CGRectMake(0, _contentView.fs_height-weekdayHeight-weekdayMargin*2, _contentView.fs_width, 1.0); \
        _titleLabel.frame = CGRectMake(0, _separator.fs_bottom-titleHeight-weekdayMargin, titleWidth,titleHeight);
            
            if (_calendar.ibEditing) {
                m_calculate
                m_adjust
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    m_calculate
                    dispatch_async(dispatch_get_main_queue(), ^{
                        m_adjust
                    });
                });
            }
        }
    }
    
    [self reloadData];
    
    if (_needsReloadingAppearance) {
        _needsReloadingAppearance = NO;
        [self reloadAppearance];
    }
}

#pragma mark - Properties

- (void)setCalendar:(FSCalendar *)calendar
{
    if (![_calendar isEqual:calendar]) {
        _calendar = calendar;
        _appearance = calendar.appearance;
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

    _calendar.formatter.dateFormat = _appearance.headerDateFormat;
    BOOL usesUpperCase = (_appearance.caseOptions & 15) == FSCalendarCaseOptionsHeaderUsesUpperCase;
    NSString *text = [_calendar.formatter stringFromDate:_month];
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


