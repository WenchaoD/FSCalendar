//
//  RollViewController.m
//  FSCalendar
//
//  Created by dingwenchao on 10/16/15.
//  Copyright (c) 2015 wenchaoios. All rights reserved.
//

#import "RollViewController.h"

#define kPink [UIColor colorWithRed:198/255.0 green:51/255.0 blue:42/255.0 alpha:1.0]
#define kBlue [UIColor colorWithRed:31/255.0 green:119/255.0 blue:219/255.0 alpha:1.0]
#define kViolet [UIColor colorWithRed:170/255.0 green:114/255.0 blue:219/255.0 alpha:1.0]

@interface RollViewController ()

@property (assign, nonatomic) NSInteger step;
@property (strong, nonatomic) NSArray *dates;
@property (strong, nonatomic) NSArray *steps;
@property (strong, nonatomic) NSArray *stepDurations;

@property (strong, nonatomic) NSArray *upperSelectionColors;
@property (strong, nonatomic) NSArray *lowerSelectionColors;

@property (strong, nonatomic) NSArray *upperBorderDefaultColors;
@property (strong, nonatomic) NSArray *lowerBorderDefaultColors;

@property (strong, nonatomic) NSArray *upperBorderSelectionColors;
@property (strong, nonatomic) NSArray *lowerBorderSelectionColors;

@property (strong, nonatomic) NSArray *upperCellShapes;
@property (strong, nonatomic) NSArray *lowerCellShapes;

@property (strong, nonatomic) NSArray *randomSelectionColors;
@property (strong, nonatomic) NSArray *randomBorderDefaultColors;
@property (strong, nonatomic) NSArray *randomBorderSelectionColors;
@property (strong, nonatomic) NSArray *randomCellShapes;

@property (readonly, nonatomic) NSArray *shuffledDates;

- (void)stepRecursively;

- (void)selectSequentially;
- (void)deselectSequentially;
- (void)selectRandomly;
- (void)deselectRandomly;

- (void)generateRandomColors;
- (void)generateRandomShapes;
- (void)removeAllRandomData;


@end

@implementation RollViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"FSCalendar";
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor colorWithRed:.95 green:.95 blue:.95 alpha:1.0];
    self.view = view;
    
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 300)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.allowsMultipleSelection = YES;
    calendar.today = nil;
    calendar.currentPage = [NSDate fs_dateWithYear:2015 month:10 day:1];
    calendar.scrollEnabled = NO;
    calendar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:calendar];
    self.calendar = calendar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDate *date = [NSDate fs_dateWithYear:2015 month:9 day:27];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:42];
    for (int i = 0; i < 42; i++) {
        [array addObject:[date fs_dateByAddingDays:i]];
    }
    self.dates = array.copy;
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 21; i++) {
            [_calendar selectDate:_dates[i] scrollToDate:NO];
        }
        for (int i = 21; i < 42; i++) {
            [_calendar deselectDate:_dates[i]];
        }
        [_calendar.appearance invalidateAppearance];
        [self removeAllRandomData];
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 21; i++) {
            [_calendar deselectDate:_dates[i]];
        }
        for (int i = 21; i < 42; i++) {
            [_calendar selectDate:_dates[i] scrollToDate:NO];
        }
        [_calendar.appearance invalidateAppearance];
    }];
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        [_dates enumerateObjectsUsingBlock:^(NSDate *date, NSUInteger idx, BOOL *stop) {
            [_calendar selectDate:date scrollToDate:NO];
        }];
        [_calendar.appearance invalidateAppearance];
    }];
    
    NSBlockOperation *op4 = [NSBlockOperation blockOperationWithBlock:^{
        [_dates enumerateObjectsUsingBlock:^(NSDate *date, NSUInteger idx, BOOL *stop) {
            [_calendar deselectDate:date];
        }];
        [_calendar.appearance invalidateAppearance];
    }];
    
    NSBlockOperation *op5 = [NSBlockOperation blockOperationWithBlock:^{
        [_calendar.appearance invalidateAppearance];
    }];
    
    NSBlockOperation *op6 = [NSBlockOperation blockOperationWithBlock:^{
        [_calendar.appearance invalidateAppearance];
    }];
    
    NSBlockOperation *op7 = [NSBlockOperation blockOperationWithBlock:^{
        [_calendar.appearance invalidateAppearance];
        [self selectSequentially];
    }];
    
    NSBlockOperation *op8 = [NSBlockOperation blockOperationWithBlock:^{
        [_calendar.appearance invalidateAppearance];
        [self deselectSequentially];
    }];
    
    NSBlockOperation *op9 = [NSBlockOperation blockOperationWithBlock:^{
        [self generateRandomColors];
        [self selectRandomly];
        [_calendar.appearance invalidateAppearance];
    }];
    
    NSBlockOperation *op10 = [NSBlockOperation blockOperationWithBlock:^{
        [self generateRandomColors];
        [self deselectRandomly];
        [_calendar.appearance invalidateAppearance];
    }];
    
    NSBlockOperation *op11 = [NSBlockOperation blockOperationWithBlock:^{
        [self generateRandomColors];
        [self generateRandomShapes];
        [self selectRandomly];
        [_calendar.appearance invalidateAppearance];
    }];
    
    NSBlockOperation *op12 = [NSBlockOperation blockOperationWithBlock:^{
        [self generateRandomColors];
        [self generateRandomShapes];
        [self deselectRandomly];
        [_calendar.appearance invalidateAppearance];
    }];
    
    self.steps = @[op1,op2,op3,op4,op5,op6,op7,op8,op9,op10,op11,op12];
    self.stepDurations = @[@1.2,@1.2,@1.2,@1.2,@1.2,@1.2,@2.0,@2.0,@2.0,@2.0,@2.0,@2.0];
    
    self.upperBorderDefaultColors = @[
                                      [UIColor clearColor],
                                      [UIColor clearColor],
                                      [UIColor clearColor],
                                      kPink,
                                      kBlue,
                                      [UIColor blackColor],
                                      kViolet,
                                      [UIColor greenColor],
                                      [UIColor clearColor],
                                      [UIColor clearColor],
                                      [UIColor clearColor],
                                      [UIColor clearColor]
                                     ];
    self.lowerBorderDefaultColors = @[
                                      [UIColor clearColor],
                                      [UIColor clearColor],
                                      [UIColor clearColor],
                                      kBlue,
                                      [UIColor blackColor],
                                      kViolet,
                                      kPink,
                                      [UIColor cyanColor],
                                      [UIColor clearColor],
                                      [UIColor clearColor],
                                      [UIColor clearColor],
                                      [UIColor clearColor]
                                     ];
    
    self.upperCellShapes = @[
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeRectangle),
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeRectangle),
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeCircle)
                            ];
    
    self.lowerCellShapes = @[
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeRectangle),
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeRectangle),
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeCircle),
                             @(FSCalendarCellShapeCircle)
                            ];
    
    self.upperSelectionColors = @[kBlue,kPink,[UIColor blackColor],kViolet,kBlue,kPink,kViolet,[UIColor blackColor],[UIColor blackColor],[UIColor blackColor],[UIColor blackColor],[UIColor blackColor]];
    self.lowerSelectionColors = @[kBlue,kPink,[UIColor blackColor],kBlue,kViolet,kBlue,kPink,[UIColor blackColor],[UIColor blackColor],[UIColor blackColor],[UIColor blackColor],[UIColor blackColor]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([_stepDurations[0] doubleValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.step = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([_stepDurations[1] doubleValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stepRecursively];
        });
    });
    
}

#pragma mark - Private methods;

- (void)stepRecursively
{
    self.step = (self.step+1)%12;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([_stepDurations[_step] doubleValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stepRecursively];
    });
}

- (void)setStep:(NSInteger)step
{
    if (_step != step) {
        _step = step;
        if (step > 11 || step < 0) {
            [NSException raise:@"Invalid step" format:@"No such step %@",@(step)];
        }
    }
    NSBlockOperation *op = _steps[step];
    [op main];
}

- (void)selectSequentially
{
    NSArray *dates = self.dates;
    for (int i = 0; i < 42 ; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2/42.0*i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_calendar selectDate:dates[i] scrollToDate:NO];
        });
    }
}

- (void)deselectSequentially
{
    NSArray *dates = self.dates;
    for (int i = 0; i < 42 ; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2/42.0*i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_calendar deselectDate:dates[dates.count-i-1]];
        });
    }
}

- (void)selectRandomly
{
    NSArray *dates = self.shuffledDates;
    for (int i = 0; i < 42 ; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2/42.0*i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_calendar selectDate:dates[i] scrollToDate:NO];
        });
    }
}

- (void)deselectRandomly
{
    NSArray *dates = self.shuffledDates;
    for (int i = 0; i < 42 ; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2/42.0*i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_calendar deselectDate:dates[i]];
        });
    }
}

- (NSArray *)shuffledDates
{
    NSMutableArray *shuffledArray = _dates.mutableCopy;
    
    for (NSUInteger i = shuffledArray.count - 1; i > 0; i--) {
        NSUInteger n = arc4random_uniform((int)i + 1);
        [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    return [shuffledArray copy];
}

- (void)generateRandomColors
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:42];
    for (int i = 0; i < 42; i++) {
        CGFloat r = arc4random_uniform(200)/255.0;
        CGFloat g = arc4random_uniform(200)/255.0;
        CGFloat b = arc4random_uniform(200)/255.0;
        [array addObject:[UIColor colorWithRed:r green:g blue:b alpha:1.0]];
    }
    self.randomSelectionColors = array.copy;
    
    [array removeAllObjects];
    for (int i = 0; i < 42; i++) {
        CGFloat r = arc4random_uniform(200)/255.0;
        CGFloat g = arc4random_uniform(200)/255.0;
        CGFloat b = arc4random_uniform(200)/255.0;
        [array addObject:[UIColor colorWithRed:r green:g blue:b alpha:1.0]];
    }
    self.randomBorderDefaultColors = array.copy;
}

- (void)generateRandomShapes
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:42];
    for (int i = 0; i < 42; i++) {
        CGFloat r = arc4random_uniform(200)/255.0;
        CGFloat g = arc4random_uniform(200)/255.0;
        CGFloat b = arc4random_uniform(200)/255.0;
        [array addObject:[UIColor colorWithRed:r green:g blue:b alpha:1.0]];
    }
    self.randomBorderSelectionColors = array.copy;
    
    [array removeAllObjects];
    for (int i = 0; i < 42; i++) {
        [array addObject:@(arc4random_uniform(2))];
    }
    self.randomCellShapes = array.copy;
}

- (void)removeAllRandomData
{
    self.randomBorderDefaultColors = nil;
    self.randomBorderSelectionColors = nil;
    self.randomCellShapes = nil;
    self.randomSelectionColors = nil;
}

#pragma mark - <FSCalendarDelegateAppearance>

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance selectionColorForDate:(NSDate *)date
{
    NSInteger index = [_dates indexOfObject:date];
    if (_step >= 8) {
        if (index == NSNotFound) {
            // Fetching data for which beyond the screen bounds
            return _randomSelectionColors.firstObject;
        }
        return _randomSelectionColors[index];
    }
    return (index < 21 ? _upperSelectionColors : _lowerSelectionColors)[_step];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date
{
    NSInteger index = [_dates indexOfObject:date];
    if (_step >= 8) {
        if (index == NSNotFound) {
            // Fetching data for which beyond the screen bounds
            return _randomBorderDefaultColors.firstObject;
        }
        return _randomBorderDefaultColors[index];
    }
    return (index < 21 ? _upperBorderDefaultColors : _lowerBorderDefaultColors)[_step];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date
{
    NSInteger index = [_dates indexOfObject:date];
    if (_step >= 8) {
        if (index == NSNotFound) {
            // Fetching data for which beyond the screen bounds
            return _randomBorderSelectionColors.firstObject;
        }
        return _randomBorderSelectionColors[index];
    }
    return (index < 21 ? _upperBorderSelectionColors : _lowerBorderSelectionColors)[_step];
}

- (FSCalendarCellShape)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance cellShapeForDate:(NSDate *)date
{
    NSInteger index = [_dates indexOfObject:date];
    if (_step >= 8) {
        if (index == NSNotFound) {
            return (FSCalendarCellShape)[_randomCellShapes.firstObject unsignedIntegerValue];
        }
        return (FSCalendarCellShape)[_randomCellShapes[index] unsignedIntegerValue];
    }
    return (FSCalendarCellShape)[(index < 21 ? _upperCellShapes : _lowerCellShapes)[_step] unsignedIntegerValue];
}

@end
