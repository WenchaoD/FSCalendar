//
//  FScalendar.m
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import "FSCalendar.h"
#import "FSCalendarHeader.h"
#import "UIView+FSExtension.h"
#import "NSDate+FSExtension.h"
#import "NSCalendar+FSExtension.h"
#import "FSCalendarCell.h"

#define kWeekHeight roundf(self.fs_height/9)
#define kBlueText [UIColor colorWithRed:14/255.0 green:69/255.0 blue:221/255.0 alpha:1.0]
#define kPink [UIColor colorWithRed:198/255.0 green:51/255.0 blue:42/255.0 alpha:1.0]
#define kBlue [UIColor colorWithRed:31/255.0 green:119/255.0 blue:219/255.0 alpha:1.0]

#define kNumberOfPages (2100-1970+1)*12 // From 1970 to 2100

@interface FSCalendar ()<UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewFlowLayout;

@property (strong, nonatomic) NSMutableArray *weekdays;
@property (strong, nonatomic) NSMutableDictionary *backgroundColors;
@property (strong, nonatomic) NSMutableDictionary *titleColors;
@property (strong, nonatomic) NSMutableDictionary *subtitleColors;

@property (readonly, nonatomic) NSInteger currentPage;

- (BOOL)shouldSelectDate:(NSDate *)date;
- (void)didSelectDate:(NSDate *)date;
- (BOOL)hasEventForDate:(NSDate *)date;
- (NSString *)subtitleForDate:(NSDate *)date;

- (void)adjustTitleIfNecessary;

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath;

@end

@implementation FSCalendar

#pragma mark - Life Cycle

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
    _titleFont = [UIFont systemFontOfSize:15];
    _subtitleFont = [UIFont systemFontOfSize:10];
    _weekdayFont = [UIFont systemFontOfSize:15];
    _headerTitleFont = [UIFont systemFontOfSize:15];
    
    NSArray *weekSymbols = [[NSCalendar currentCalendar] shortStandaloneWeekdaySymbols];
    _weekdays = [NSMutableArray arrayWithCapacity:weekSymbols.count];
    for (int i = 0; i < weekSymbols.count; i++) {
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        weekdayLabel.text = weekSymbols[i];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.font = _weekdayFont;
        weekdayLabel.textColor = kBlueText;
        [_weekdays addObject:weekdayLabel];
        [self addSubview:weekdayLabel];
    }
    
    _collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    _collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionViewFlowLayout.minimumInteritemSpacing = 0;
    _collectionViewFlowLayout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                         collectionViewLayout:_collectionViewFlowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.bounces = YES;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.delaysContentTouches = NO;
    _collectionView.canCancelContentTouches = YES;
    [_collectionView registerClass:[FSCalendarCell class] forCellWithReuseIdentifier:@"cell"];
    [self addSubview:_collectionView];
    
    _collectionView.collectionViewLayout = _collectionViewFlowLayout;
    
    _currentDate = [NSDate date];
    _currentMonth = [_currentDate copy];
    
    _backgroundColors = [NSMutableDictionary dictionaryWithCapacity:4];
    _backgroundColors[@(FSCalendarUnitStateNormal)] = [UIColor clearColor];
    _backgroundColors[@(FSCalendarUnitStateSelected)] = kBlue;
    _backgroundColors[@(FSCalendarUnitStateDisabled)] = [UIColor clearColor];
    _backgroundColors[@(FSCalendarUnitStatePlaceholder)] = [UIColor clearColor];
    _backgroundColors[@(FSCalendarUnitStateToday)] = kPink;
    
    _titleColors = [NSMutableDictionary dictionaryWithCapacity:4];
    _titleColors[@(FSCalendarUnitStateNormal)] = [UIColor darkTextColor];
    _titleColors[@(FSCalendarUnitStateWeekend)] = [UIColor darkTextColor];
    _titleColors[@(FSCalendarUnitStateSelected)] = [UIColor whiteColor];
    _titleColors[@(FSCalendarUnitStateDisabled)] = [UIColor grayColor];
    _titleColors[@(FSCalendarUnitStatePlaceholder)] = [UIColor lightGrayColor];
    _titleColors[@(FSCalendarUnitStateToday)] = [UIColor whiteColor];
    
    _subtitleColors = [NSMutableDictionary dictionaryWithCapacity:4];
    _subtitleColors[@(FSCalendarUnitStateNormal)] = [UIColor darkGrayColor];
    _subtitleColors[@(FSCalendarUnitStateWeekend)] = [UIColor darkGrayColor];
    _subtitleColors[@(FSCalendarUnitStateSelected)] = [UIColor whiteColor];
    _subtitleColors[@(FSCalendarUnitStateDisabled)] = [UIColor lightGrayColor];
    _subtitleColors[@(FSCalendarUnitStatePlaceholder)] = [UIColor lightGrayColor];
    _subtitleColors[@(FSCalendarUnitStateToday)] = [UIColor whiteColor];
    
    _unitStyle = FSCalendarUnitStyleCircle;
    _autoAdjustTitleSize = YES;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    CGFloat padding = bounds.size.height * 0.01;
    _collectionView.frame = CGRectMake(0, kWeekHeight, self.fs_width, self.fs_height-kWeekHeight);
    _collectionViewFlowLayout.itemSize = CGSizeMake(_collectionView.fs_width/7,
                                                    (_collectionView.fs_height-padding*2)/6);
    _collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(padding, 0, padding, 0);
    _collectionView.collectionViewLayout = _collectionViewFlowLayout;
    [_weekdays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat width = self.fs_width/_weekdays.count;
        CGFloat height = kWeekHeight;
        [obj setFrame:CGRectMake(idx*width, 0, width, height)];
    }];
    [self adjustTitleIfNecessary];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return kNumberOfPages;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 42;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.titleColors = self.titleColors;
    cell.subtitleColors = self.subtitleColors;
    cell.backgroundColors = self.backgroundColors;
    cell.month = [[NSCalendar fs_sharedCalendar] dateByAddingUnit:NSMonthCalendarUnit
                                                            value:indexPath.section
                                                           toDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                          options:0];
    cell.date = [self dateForIndexPath:indexPath];
    if (!_autoAdjustTitleSize) {
        cell.titleLabel.font = _titleFont;
        cell.subtitleLabel.font = _subtitleFont;
    }

    cell.hasEvent = [self hasEventForDate:cell.date];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCell *cell = (FSCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.isPlaceholder) {

    } else {
        [cell showAnimation];
        [self didSelectDate:cell.date];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCell *cell = (FSCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    return [self shouldSelectDate:cell.date];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSCalendarCell *cell = (FSCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell hideAnimation];
}

#pragma mark - Setter & Getter

- (NSInteger)currentPage
{
    if (self.flow == FSCalendarFlowHorizontal) {
        return round(_collectionView.contentOffset.x)/_collectionView.fs_width;
    } else {
        return round(_collectionView.contentOffset.y)/_collectionView.fs_height;
    }
}

- (void)setFlow:(FSCalendarFlow)flow
{
    _collectionViewFlowLayout.scrollDirection = (UICollectionViewScrollDirection)flow;
}

- (FSCalendarFlow)flow
{
    return (FSCalendarFlow)_collectionViewFlowLayout.scrollDirection;
}

- (void)setWeekdayFont:(UIFont *)weekdayFont
{
    if (_weekdayFont != weekdayFont) {
        _weekdayFont = weekdayFont;
        [_weekdays setValue:weekdayFont forKeyPath:@"font"];
    }
}

- (void)setWeekdayTextColor:(UIColor *)weekdayTextColor
{
   [_weekdays setValue:weekdayTextColor forKeyPath:@"textColor"];
}

- (void)setHeader:(FSCalendarHeader *)header
{
    if (_header != header) {
        _header = header;
        if (header) {
            header.calendar = self;
        }
    }
}

- (void)setCurrentDate:(NSDate *)currentDate
{
    if (![_currentDate isEqualToDate:currentDate]) {
        _currentDate = [currentDate copy];
        _currentMonth = [_currentDate copy];
        
        if (_header) {
            _header.calendar = nil;
            _header.calendar = self;
        }
    }
}

- (void)setHeaderTitleFont:(UIFont *)font
{
    if (_headerTitleFont != font) {
        _headerTitleFont = font;
        _header.titleFont = font;
    }
}

- (void)setHeaderTitleColor:(UIColor *)color
{
    _header.titleColor = color;
}

- (void)setHeaderDateFormat:(NSString *)dateFormat
{
    _header.dateFormat = dateFormat;
}

- (void)setTitleDefaultColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarUnitStateNormal)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarUnitStateNormal)];
    }
    [self reloadData];
}

- (void)setTitleSelectionColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarUnitStateSelected)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarUnitStateSelected)];
    }
    [self reloadData];
}

- (void)setTitleTodayColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarUnitStateToday)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarUnitStateToday)];
    }
    [self reloadData];
}

- (void)setTitlePlaceholderColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarUnitStatePlaceholder)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarUnitStatePlaceholder)];
    }
    [self reloadData];
}

- (void)setTitleWeekendColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(FSCalendarUnitStateWeekend)] = color;
    } else {
        [_titleColors removeObjectForKey:@(FSCalendarUnitStateWeekend)];
    }
    [self reloadData];
}

- (void)setSubtitleDefaultColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarUnitStateNormal)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarUnitStateNormal)];
    }
    [self reloadData];
}

- (void)setSubtitleSelectionColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarUnitStateSelected)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarUnitStateSelected)];
    }
    [self reloadData];
}

- (void)setSubtitleTodayColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarUnitStateToday)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarUnitStateToday)];
    }
    [self reloadData];
}

- (void)setSubtitlePlaceholderColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarUnitStatePlaceholder)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarUnitStatePlaceholder)];
    }
    [self reloadData];
}

- (void)setSubtitleWeekendColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(FSCalendarUnitStateWeekend)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(FSCalendarUnitStateWeekend)];
    }
    [self reloadData];
}

- (void)setSelectionColor:(UIColor *)color
{
    if (color) {
        _backgroundColors[@(FSCalendarUnitStateSelected)] = color;
    } else {
        [_backgroundColors removeObjectForKey:@(FSCalendarUnitStateSelected)];
    }
    [self reloadData];
}

- (void)setTodayColor:(UIColor *)color
{
    if (color) {
        _backgroundColors[@(FSCalendarUnitStateToday)] = color;
    } else {
        [_backgroundColors removeObjectForKey:@(FSCalendarUnitStateToday)];
    }
    [self reloadData];
}

- (void)setEventColor:(UIColor *)eventColor
{
    if (![_eventColor isEqual:eventColor]) {
        _eventColor = eventColor;
        [self reloadData];
    }
}

- (void)setTitleFont:(UIFont *)font
{
    if (_titleFont != font) {
        _titleFont = font;
        if (_autoAdjustTitleSize) {
            return;
        }
    }
}

- (void)setSubtitleFont:(UIFont *)font
{
    if (_subtitleFont != font) {
        _subtitleFont = font;
        if (_autoAdjustTitleSize) {
            return;
        }
    }
}

- (void)setMinDissolvedAlpha:(CGFloat)minDissolvedAlpha
{
    if (_minDissolvedAlpha != minDissolvedAlpha) {
        _minDissolvedAlpha = minDissolvedAlpha;
        _header.minDissolveAlpha = minDissolvedAlpha;
    }
}

#pragma mark - Private

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath
{
    NSCalendar *calendar = [NSCalendar fs_sharedCalendar];
    NSDate *currentMonth = [calendar dateByAddingUnit:NSMonthCalendarUnit
                                                value:indexPath.section
                                               toDate:[NSDate dateWithTimeIntervalSince1970:1]
                                              options:0];
    NSDate *firstDayOfMonth = [NSDate fs_dateWithYear:currentMonth.fs_year month:currentMonth.fs_month day:1];
    NSInteger numberOfPlaceholdersForPrev = (firstDayOfMonth.fs_weekday - 1) ? : 7;
    NSDate *firstDateOfPage = [firstDayOfMonth fs_dateBySubtractingDays:numberOfPlaceholdersForPrev];
    NSDate *dateForRow = [firstDateOfPage fs_dateByAddingDays:7*(indexPath.row%6)+indexPath.row/6];
    return dateForRow;
}

- (void)adjustTitleIfNecessary
{
    UIFont *titleFont = _titleFont;
    UIFont *subtitleFont = _subtitleFont;
    UIFont *headerFont = _headerTitleFont;
    UIFont *weekdayFont = _weekdayFont;
    if (_autoAdjustTitleSize) {
        titleFont = [titleFont fontWithSize:_collectionView.fs_height/3/6];
        subtitleFont = [subtitleFont fontWithSize:_collectionView.fs_height/4.3/6];
        headerFont = titleFont;
        weekdayFont = titleFont;
    }
    [_collectionView reloadData];
    [_weekdays setValue:weekdayFont forKey:@"font"];
    if (_header) {
        [_header setTitleFont:headerFont];
    }
}

- (BOOL)shouldSelectDate:(NSDate *)date
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendar:shouldSelectDate:)]) {
        return [_delegate calendar:self shouldSelectDate:date];
    }
    return YES;
}

- (void)didSelectDate:(NSDate *)date
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendar:didSelectDate:)]) {
        [_delegate calendar:self didSelectDate:date];
    }
}

- (NSString *)subtitleForDate:(NSDate *)date
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendar:subtitleForDate:)]) {
        return [_dataSource calendar:self subtitleForDate:date];
    }
    return nil;
}

- (BOOL)hasEventForDate:(NSDate *)date
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendar:hasEventForDate:)]) {
        return [_dataSource calendar:self hasEventForDate:date];
    }
    return NO;
}

- (void)setAutoAdjustTitleSize:(BOOL)autoAdjustTitleSize
{
    if (_autoAdjustTitleSize != autoAdjustTitleSize) {
        _autoAdjustTitleSize = autoAdjustTitleSize;
        [self reloadData];
    }
}

- (void)setUnitStyle:(FSCalendarUnitStyle)unitStyle
{
    if (_unitStyle != unitStyle) {
        _unitStyle = unitStyle;
        [self reloadData];
    }
}

#pragma mark - Public

- (void)reloadData
{
    [_collectionView reloadData];
}

@end

