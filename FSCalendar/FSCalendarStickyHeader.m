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

@property (readonly, nonatomic) FSCalendarAppearance *appearance;


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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _contentView.frame = self.bounds;
    
#define m_calculate \
    CGFloat weekdayWidth = self.fs_width / 7.0; \
    CGFloat weekdayHeight = [@"1" sizeWithAttributes:@{NSFontAttributeName:[_weekdayLabels.lastObject font]}].height; \
    CGFloat weekdayMargin = (weekdayHeight*0.4+_contentView.fs_height*0.2)*0.5; \
    CGFloat titleWidth = _contentView.fs_width; \
    CGFloat titleHeight = [@"1" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.appearance.headerTitleTextSize]}].height; \
    CGFloat titleMargin = (titleHeight*0.2+_contentView.fs_height*0.1)*0.5; \

#define m_adjust \
    [_weekdayLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) { \
        label.frame = CGRectMake(index*weekdayWidth, _contentView.fs_height-weekdayHeight, weekdayWidth, weekdayHeight); \
    }]; \
    _separator.frame = CGRectMake(0, _contentView.fs_height-weekdayHeight-weekdayMargin, _contentView.fs_width, 1.0); \
    _titleLabel.frame = CGRectMake(0, _separator.fs_top-titleMargin-titleHeight, titleWidth, titleHeight); \
    
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

    [self reloadData];
    
    if (_needsReloadingAppearance) {
        _needsReloadingAppearance = NO;
        [self reloadAppearance];
    }
}

#pragma mark - Properties

- (FSCalendarAppearance *)appearance
{
    return self.calendar.appearance;
}

#pragma mark - Public methods

- (void)reloadData
{
    NSArray *weekdaySymbols = self.appearance.useVeryShortWeekdaySymbols ? self.calendar.calendar.veryShortStandaloneWeekdaySymbols : self.calendar.calendar.shortStandaloneWeekdaySymbols;
    [_weekdayLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        label.text = weekdaySymbols[index];
    }];
    
    _dateFormatter.dateFormat = self.calendar.appearance.headerDateFormat;
    _dateFormatter.locale = self.calendar.locale;
    _titleLabel.text = [_dateFormatter stringFromDate:_month];
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


