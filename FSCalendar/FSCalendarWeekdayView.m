//
//  FSCalendarWeekdayView.m
//  FSCalendar
//
//  Created by dingwenchao on 03/11/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendarWeekdayView.h"
#import "FSCalendar.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarExtensions.h"

@interface FSCalendarWeekdayView()

@property (strong, nonatomic) NSPointerArray *weekdayPointers;
@property (weak  , nonatomic) UIView *contentView;
@property (weak  , nonatomic) FSCalendar *calendar;

- (void)commonInit;

@end

@implementation FSCalendarWeekdayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:contentView];
    _contentView = contentView;
    
    _weekdayPointers = [NSPointerArray weakObjectsPointerArray];
    for (int i = 0; i < 7; i++) {
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:weekdayLabel];
        [_weekdayPointers addPointer:(__bridge void * _Nullable)(weekdayLabel)];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    
    // Position Calculation
    NSInteger count = self.weekdayPointers.count;
    size_t size = sizeof(CGFloat)*count;
    CGFloat *widths = malloc(size);
    CGFloat contentWidth = self.contentView.fs_width;
    FSCalendarSliceCake(contentWidth, count, widths);
    
    __block CGFloat x = 0;
    [self.weekdayLabels enumerateObjectsUsingBlock:^(UILabel *weekdayLabel, NSUInteger index, BOOL *stop) {
        CGFloat width = widths[index];
        weekdayLabel.frame = CGRectMake(x, 0, width, self.contentView.fs_height);
        x += width;
    }];
    free(widths);
    
}

#if TARGET_INTERFACE_BUILDER
- (void)setCalendar:(FSCalendar *)calendar
{
    _calendar = calendar;
    [self configureAppearance];
}
#endif

- (NSArray<UILabel *> *)weekdayLabels
{
    return self.weekdayPointers.allObjects;
}

- (void)configureAppearance
{
    BOOL useVeryShortWeekdaySymbols = (self.calendar.appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    NSArray *weekdaySymbols = useVeryShortWeekdaySymbols ? self.calendar.gregorian.veryShortStandaloneWeekdaySymbols : self.calendar.gregorian.shortStandaloneWeekdaySymbols;
    BOOL useDefaultWeekdayCase = (self.calendar.appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesDefaultCase;
    
    [self.weekdayLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull label, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger index = idx;
        label.font = self.calendar.appearance.weekdayFont;
        label.textColor = self.calendar.appearance.weekdayTextColor;
        index += self.calendar.firstWeekday-1;
        index %= 7;
        label.text = useDefaultWeekdayCase ? weekdaySymbols[index] : [weekdaySymbols[index] uppercaseString];
    }];

}

@end
