
![fscalendar](https://cloud.githubusercontent.com/assets/5186464/6655324/213a814a-cb36-11e4-9add-f80515a83291.png)<br/><br/>
[![Version](https://img.shields.io/cocoapods/v/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![License](https://img.shields.io/cocoapods/l/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![Platform](https://img.shields.io/cocoapods/p/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)

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
FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
calendar.dataSource = self;
calendar.delegate = self;
[self.view addSubview:calendar];
self.calendar = calendar;
```
<br/>

### Or swift

```swift
private weak var calendar: FSCalendar!

// In loadView or viewDidLoad
let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
calendar.dataSource = self
calendar.delegate = self
view.addSubview(calendar)
self.calendar = calendar
```

## More usage

#### If you want `FSCalendar` to scroll vertically (default horizontally)

* Objective - c

```objective-c
_calendar.flow = FSCalendarFlowVertical;
```

* Swift

```swift
calendar.flow = .Vertical 
```

#### If you want `FSCalendar` to use `Monday` as the first column (or any other weekday)

```objective-c
_calendar.firstWeekday = 2; 
```

#### If you wanna change the date format for header

```objective-c
_calendar.appearance.headerDateFormat = @"MMM yy";
```

#### If you wanna change colors

```objective-c
_calendar.appearance.weekdayTextColor = [UIColor redColor];
_calendar.appearance.headerTitleColor = [UIColor redColor];
_calendar.appearance.eventColor = [UIColor greenColor];
_calendar.appearance.selectionColor = [UIColor blueColor];
_calendar.appearance.todayColor = [UIColor orangeColor];
```

#### What if you wanna hide this?

```objective-c
_calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
```

#### What if you wanna show this without alpha?
```objective-c
_calendar.appearance.headerMinimumDissolvedAlpha = 1.0;
```


#### If you want `FSCalendar` to show subtitle for each day

```objective-c
// FSCalendarDataSource
- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date
{
    return yourSubtitle;
}
```

#### If you want `FSCalendar` to show event dot for some days

```objective-c
// FSCalendarDataSource
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date
{
    return shouldShowEventDot;
}
```

#### If you want `FSCalendar` to show an image for some days

```objective-c
// FSCalendarDataSource
- (UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date
{
    return anyImage;
}
```

#### If you want set a boundary for `FSCalendar`

```objective-c
// FSCalendarDataSource
- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    return [NSDate fs_dateWithYear:2015 month:1 day:1];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    return [NSDate fs_dateWithYear:2015 month:10 day:31];
}
```

#### If you want to do something when a date is selected
```objective-c
// FSCalendarDelegate
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    // Do something
}
```

#### If you don't want some date to be selected
```objective-c
// FSCalendarDelegate
- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date
{
    if ([date shouldNotBeSelected]) {
        return NO;
    }
    return YES;
}
```

#### If you need to do something when the month changes
```objective-c
- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar
{
    // Do something
}
```

## Requirements
ios 7.0

## Compatibility
`FSCalendar` can be used on iPad, see the demo for details.

## Known issues
1. The title size changed as we change frame size of FSCalendar: Automatically adjusting font size based on frame size is default behavior of FSCalendadr, to disable it:

```objective-c    
_calendar.appearance.autoAdjustTitleSize = NO; 
_calendar.appearance.titleFont = otherTitleFont;
_calendar.appearance.subtitleFont = otherSubtitleFont;
```

`titleFont` and `subtitleFont` would not take any effect if `autoAdjustTitleSize` value is `YES`

2. What if I don't need the `today` circle?

```objective-c
_calendar.appearance.todayColor = [UIColor clearColor];
_calendar.appearance.titleTodayColor = _calendar.appearance.titleDefaultColor;
_calendar.appearance.subtitleTodayColor = _calendar.appearance.subtitleDefaultColor;
```

## License

FSCalendar is available under the MIT license. See the LICENSE file for more info.

## Support
* If FSCalendar cannot meet your requirment, tell me in issues or send your pull requests
* If you like this control and use it in your app, submit your app's link address [here](https://www.cocoacontrols.com/controls/fscalendar).It would be a great support for me.

## Contact
* email: `f33chobits@gmail.com`
* skype: `wenchao.ding`

## Donate
* Paypal - f33chobits@gmail.com

