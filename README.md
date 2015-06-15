
![fscalendar](https://cloud.githubusercontent.com/assets/5186464/6655324/213a814a-cb36-11e4-9add-f80515a83291.png)<br/><br/>
[![Version](https://img.shields.io/cocoapods/v/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![License](https://img.shields.io/cocoapods/l/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![Platform](https://img.shields.io/cocoapods/p/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)

## Example
![fscalendar1](https://cloud.githubusercontent.com/assets/5186464/6652191/f11d5242-caa1-11e4-9cc2-8a7c0cc9ef02.gif)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

## Horizontal flow
![fscalendar-horizontal](https://cloud.githubusercontent.com/assets/5186464/6679663/2afae1c4-cc86-11e4-9a44-26560a16d81d.gif)

## Vertical flow
![fscalendar-vertical](https://cloud.githubusercontent.com/assets/5186464/6679667/3856a2ae-cc86-11e4-96c2-313e9dcf0ac1.gif)

## Select a date Manually
![fscalendar-selected-date](https://cloud.githubusercontent.com/assets/5186464/6680012/4af05080-cc8c-11e4-863a-59cd3507192d.gif)

## Installation

* Using cocoapods:`pod 'FSCalendar'` 
* Manually: Unzip downloaded zip file, drag all files under `FSCalendar-master/Pod/Classes` to your project, make sure `copy items if needed` is checked.

```objective-c
#import "FSCalendar.h"
```

## Setup

### Use Interface Builder (Recommended)

1. Drag an UIView object to ViewController Scene, change the `Custom Class` to `FSCalendar`<br/>
2. After adjust the position and frame, link the `dataSource` and `delegate` to the ViewController <br/>
3. Implement `FSCalendarDataSource` and `FSCalendarDelegate` in ViewController.m

### Use code

```objective-c
@property (weak , nonatomic) FSCalendar *calendar;

// In loadView or viewDidLoad
FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 0, 320, 280)];
calendar.dataSource = self;
calendar.delegate = self;
[self.view addSubview:calendar];
self.calendar = calendar;
```
<br/>
Or swift

```swift
private weak var calendar: FSCalendar!

// In loadView or viewDidLoad
let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 280))
calendar.dataSource = self
calendar.delegate = self
view.addSubview(calendar)
self.calenar = calendar
```

## Donate
* Paypal - f33chobits@gmail.com
* Alipay(支付宝) - f33chobits@gmail.com

## Core classes

### FSCalendar

```objective-c
@property (weak, nonatomic) IBOutlet id<FSCalendarDelegate> delegate;
```
A delegate object to handle user tap/scroll event, see `FSCalendarDelegate` for details.

```objective-c
@property (weak, nonatomic) IBOutlet id<FSCalendarDataSource> dataSource;
```
A dataSource object to provide subtitle, event dot or other sources, see `FSCalendarDataSource` for details.

```objective-c
@property (assign, nonatomic) FSCalendarFlow flow;
```
An enumeration value to determine the scroll direction of `FSCalendar`, default value is `FSCalendarFlowHorizontal`

```objective-c
@property (assign, nonatomic) BOOL autoAdjustTitleSize;
```
The text size of `FSCalendar` is automaticly calculated based on the frame by default. To turn it off, set this value to `NO`.

```objective-c
@property (strong, nonatomic) NSDate *currentDate;
```
The current date of calendar, default is [NSDate date];

```objective-c
@property (strong, nonatomic) NSDate *selectedDate;
```
Get the selected date of `FSCalendar`

```objective-c
@property (strong, nonatomic) NSDate *currentMonth;
```
Get the current month of `FSCalendar`.Extract it with `NSDateComponents`, or `currentMonth.fs_month` and `currentMonth.fs_year`

```objective-c
@property (assign, nonatomic) FSCalendarCellStyle cellStyle UI_APPEARANCE_SELECTOR;
```
The background style for `today` and `selected cell`, default is FSCalendarCellStyleCircle.

```objective-c
@property (strong, nonatomic) UIFont   *titleFont UI_APPEARANCE_SELECTOR;
```
The font for `day` text. To change the font size, set `autoAdjustTitleSize` to `NO`

```objective-c
@property (strong, nonatomic) UIFont   *subtitleFont UI_APPEARANCE_SELECTOR;
```
The font for `subtitle` text. To change the font size, set `autoAdjustTitleSize` to `NO`

```objective-c
@property (strong, nonatomic) UIFont   *weekdayFont UI_APPEARANCE_SELECTOR;
```
The font for `weekday` text. To change the font size, set `autoAdjustTitleSize` to `NO`

```objective-c
@property (strong, nonatomic) UIFont   *headerTitleFont UI_APPEARANCE_SELECTOR;
```
The font for scrolling header text. To change the font size, set `autoAdjustTitleSize` to `NO`

```objective-c
@property (strong, nonatomic) UIColor  *eventColor UI_APPEARANCE_SELECTOR;
```
The color for event dot.

```objective-c
@property (strong, nonatomic) UIColor  *weekdayTextColor UI_APPEARANCE_SELECTOR;
```
The text color of weekday. 

```objective-c
@property (strong, nonatomic) UIColor *titleDefaultColor UI_APPEARANCE_SELECTOR;
```
The `day text color` for default state.

```objective-c
@property (strong, nonatomic) UIColor *titleSelectionColor UI_APPEARANCE_SELECTOR;
```
The `day text color` for selection state.

```objective-c
@property (strong, nonatomic) UIColor *titleTodayColor UI_APPEARANCE_SELECTOR;
```
The `day text color` where the date is equal to `currentDate`.

```objective-c
@property (strong, nonatomic) UIColor *titlePlaceholderColor UI_APPEARANCE_SELECTOR;
```
The `day text color` where the date is `not` in `currentMonth`.

```objective-c
@property (strong, nonatomic) UIColor *titleWeekendColor UI_APPEARANCE_SELECTOR;
```
The `day text color` where the date is weekend.

```objective-c
@property (strong, nonatomic) UIColor *subtitleDefaultColor UI_APPEARANCE_SELECTOR;
```
The `subtitle text color` for default state.

```objective-c
@property (strong, nonatomic) UIColor *subtitleSelectionColor UI_APPEARANCE_SELECTOR;
```
The `subtitle text color` for selection state.

```objective-c
@property (strong, nonatomic) UIColor *subtitleTodayColor UI_APPEARANCE_SELECTOR;
```
The `subtitle text color` where the date is equal to `currentDate`.

```objective-c
@property (strong, nonatomic) UIColor *subtitlePlaceholderColor UI_APPEARANCE_SELECTOR;
```
The `subtitle text color` where the date is `not` in `currentMonth`.

```objective-c
@property (strong, nonatomic) UIColor *subtitleWeekendColor UI_APPEARANCE_SELECTOR;
```
The `subtitle text color` where the date is weekend.

```objective-c
@property (strong, nonatomic) UIColor *selectionColor UI_APPEARANCE_SELECTOR;
```
The `cell background color` for selection state.

```objective-c
@property (strong, nonatomic) UIColor *todayColor UI_APPEARANCE_SELECTOR;
```
The `cell background color` where the date is equal to `currentDate`.

```objective-c
@property (strong, nonatomic) UIColor  *headerTitleColor UI_APPEARANCE_SELECTOR;
```
The `text color` for `FSCalendarHeader`.

```objective-c
@property (strong, nonatomic) NSString *headerDateFormat UI_APPEARANCE_SELECTOR;
```
The `date format` for `FSCalendarHeader`.

#### FSCalendarDataSource

```objective-c
- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date;
```
To provide a subtitle right below the `day` digit. 

```objective-c
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date;
```
To provide an event dot below the day cell.

#### FSCalendarDelegate

```objective-c
- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date;
```
To determine whether the day cell should be selected and show the selection layer.

```objective-c
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date;
```
This method would execute after a cell is managed to be selected and show the selection layer. 

```objective-c
- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar;
```
This method would execute when calendar month page is changed. 

```objective-c
- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar;
```
Provides a left boundary for calendar

```objective-c
- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar;
```
Provides a right boundary for calendar

## Requirements
ios 7.0

## Compatibility
`FSCalendar` is also tested on iPad device, see the demo for details.


## Version notes

### Version 0.7.0
* Simplier initialization: No more `FSCalendarHeader`, use `headerHeight` to control the size (which I thought it's not needed because the default 44 pixels looks good enough). For those who wanna keep the `FSCalendarHeader`, just set `pod 'FSCalendar', ~> 0.6.0` in `podfile` to keep it from upated , or you can download the old released version in `tags`.
* Fix problem setting `selectedDate` in `viewDidLoad`
* Fix other problems

### Version 0.6.0
* Add minmumDate and maximumDate in FSCalendarDataSource
* Fix weekstarday issue

### Version 0.5.4
* Fix cell wrapping problem
* Fix problem while adding FSCalendar in viewDidLoad(cause by adjust scroll inset)

### Version 0.5.3
* Fix month-jumping problem on orientation changed #16
* Fix issue #20

### Version 0.5.2
* Fix lunar problem in demo project
* Fix issue #18

### Version 0.5.1
* Fix issue for different timeZone #14
* Fix date-calculation problem while changing `firstWeekday`
* Fix problem about setting `flow` in `viewDidLoad` #15

### Version 0.5
* Make `currentMonth` writable. `FSCalendar` will show `currentMonth` after it is set.
* Add `firstWeekday` property. If you want the first day of week to be Monday, just set this property to `2`, just like `NSCalendar`.
* Add some performace improvements and code optimization.

### Version 0.4
* Make `selectedDate` writable. `FSCalendar` will select `selectedDate` and show the corresponding month

### Version 0.3
* Improve scrolling performance

### Version 0.2
* Improve cell rendering performance

### Version 0.1
* The first release

## Known issues
1. The title size changed as we change frame size of FSCalendar: Automatically adjusting font size based on frame size is default behavior of FSCalendadr, to disable it:

```objective-c    
self.calendar.autoAdjustTitleSize = NO; 
self.calendar.titleFont = otherTitleFont;
self.calendar.subtitleFont = otherSubtitleFont;
```

`titleFont` and `subtitleFont` is also available for `UIAppearance` selector, but would not take any effect if `autoAdjustTitleSize` value is `YES`

## Author

Wenchao Ding, f33chobits@gmail.com

## License

FSCalendar is available under the MIT license. See the LICENSE file for more info.

## Support
* If FSCalendar cannot meet your requirment, welcome to submit issues or pull requests
* If you like this control and use it in your app, submit your app's link address [here](https://www.cocoacontrols.com/controls/fscalendar).It would be a great support for me.
