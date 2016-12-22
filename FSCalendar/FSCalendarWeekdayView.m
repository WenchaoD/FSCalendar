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
    
    CGFloat weekdayWidth = self.fs_width/self.weekdayLabels.count;
    [self.weekdayLabels enumerateObjectsUsingBlock:^(UILabel *weekdayLabel, NSUInteger index, BOOL *stop) {
        weekdayLabel.frame = CGRectMake(index*weekdayWidth, 0, weekdayWidth, self.contentView.fs_height);
    }];
    
}

- (void)setCalendar:(FSCalendar *)calendar
{
    _calendar = calendar;
    [self configureAppearance];
}

- (void)configureAppearance
{
    BOOL useVeryShortWeekdaySymbols = (self.calendar.appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    NSArray *weekdaySymbols = useVeryShortWeekdaySymbols ? self.calendar.gregorian.veryShortStandaloneWeekdaySymbols : self.calendar.gregorian.shortStandaloneWeekdaySymbols;
    BOOL useDefaultWeekdayCase = (self.calendar.appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesDefaultCase;
    
    void(^configureLabel)(UILabel *, NSInteger index) = ^(UILabel *label, NSInteger index) {
        label.font = self.calendar.appearance.weekdayFont;
        label.textColor = self.calendar.appearance.weekdayTextColor;
        index += self.calendar.firstWeekday-1;
        index %= 7;
        label.text = useDefaultWeekdayCase ? weekdaySymbols[index] : [weekdaySymbols[index] uppercaseString];
    };
    
#if TARGET_INTERFACE_BUILDER
    [self.weekdayLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull label, NSUInteger idx, BOOL * _Nonnull stop) {
        configureLabel(label,idx);
    }];
#else
    [self.weekdayLabels enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(UILabel * _Nonnull label, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([NSThread isMainThread]) {
            configureLabel(label,idx);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                configureLabel(label,idx);
            });
        }
    }];
#endif
    
}

- (NSArray<UILabel *> *)weekdayLabels { return self.weekdayPointers.allObjects; }

@end
