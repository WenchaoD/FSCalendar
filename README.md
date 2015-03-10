# FSCalendar

##[中文文档](https://github.com/f33chobits/FSCalendar/blob/master/README-cn.md)
[![Version](https://img.shields.io/cocoapods/v/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![License](https://img.shields.io/cocoapods/l/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![Platform](https://img.shields.io/cocoapods/p/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)

## Features
### 1. Smooth Scrolling and directions(vertical/horizotal)
![animate](https://cloud.githubusercontent.com/assets/5186464/6260896/de303034-b820-11e4-9f01-8d98e0ac94aa.gif) 
![fscalendar-click](https://cloud.githubusercontent.com/assets/5186464/6479246/6156c458-c27d-11e4-97da-52b424b45ec3.gif)
### 2. Appearance adjustment
![appearance](https://cloud.githubusercontent.com/assets/5186464/6208969/20ee842a-b5fb-11e4-8875-132d42893b9e.png)
### 3. Subtitle(Provided by FSCalendarDataSource,not only Chinese)
![subtitle1](https://cloud.githubusercontent.com/assets/5186464/6209081/54d8a4cc-b5fc-11e4-981e-d4bb21a45628.png)
### 4. iPad compatible
![fscalendar-ipad](https://cloud.githubusercontent.com/assets/5186464/6502151/b4ce3092-c35b-11e4-827a-498d73579d78.jpg)

## Usage

* Using cocoapods:`pod 'FSCalendar'`
* Manually: Drag all .h and .m files in FSCalendar group to your project

```objective-c
#import FSCalendar.h
```

### 1. Simple DataSource/Delegate Pattern (IBOutlet supported)
```objective-c
self.calendar.dataSource = self; 
self.calendar.delegate = self;
```
#### FSCalendarDataSource
```objective-c
- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date; // set subtitle
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date; // set event dot
```
#### FSCalendarDelegate
```objective-c
- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date;
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date;
- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar;
```
### 2. Page Direction Supported
```objective-c
_calendar.flow = FSCalendarFlowVertical; //Change to vertical flow, default is FSCalendarFlowHorizontal
```
### 3. Flexible Appearance Customization
```objective-c
[[FSCalendar appearance] setWeekdayTextColor:[UIColor redColor]];   // week symbol color
[[FSCalendar appearance] setHeaderTitleColor:[UIColor darkGrayColor]]; // header text color
[[FSCalendar appearance] setEventColor:[UIColor greenColor]]; // event mark color
[[FSCalendar appearance] setSelectionColor:[UIColor blueColor]]; // selection fill color
[[FSCalendar appearance] setHeaderDateFormat:@"yyyy-MM"]; // header date format
[[FSCalendar appearance] setMinDissolvedAlpha:0.5]; // change to 1.0 to make header no alpha
[[FSCalendar appearance] setTodayColor:[UIColor redColor]]; // today fill color
[[FSCalendar appearance] setUnitStyle:FSCalendarUnitStyleCircle]; // shape of today/selection fill color.Circle/Fectangle
```
### 4. Header (IBOutlet supported)
```objective-c
FSCalendarHeader *header = [[FSCalendarHeader alloc] initWithFrame:CGRectMake(0,0,_calendar.frame.size.width,44)];
_calendar.header = header;
```
For more appearance and other usage, look into FSCalendar.h

## Requirements
ios 7.0

## Known issues
1. The title size changed as we change frame size of FSCalendar: Automatically adjusting font size based on frame size is default behavior of FSCalendadr, to disable it:

```objective-c    
self.calendar.autoAdjustTitle = NO; 
self.calendar.titleFont = otherTitleFont;
self.calendar.subtitleFont = otherSubtitleFont;
```

`titleFont` and `subtitleFont` is also available for `UIAppearance` selector, but would not take any effect if `autoAdjustTitle` value is `YES`

## Author

Wenchao Ding, f33chobits@gmail.com

## License

FSCalendar is available under the MIT license. See the LICENSE file for more info.

## Others
* If FSCalendar cannot meet your requirment, welcome to submit issues or pull request
* If you are using this library and using custom color modulation, please take a screenshot for your calendar appearance [here](https://github.com/f33chobits/FSCalendar/issues/2), this will help others better matching color in their apps, thanks
