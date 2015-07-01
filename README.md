
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

![fscalendar---takealook](https://cloud.githubusercontent.com/assets/5186464/8448508/0abae54e-1ffb-11e5-9963-c02e4d44a0af.png)

## More usage

#### If you want `FSCalendar` to scroll vertically

* Objective - c

```objective-c
_calendar.flow = FSCalendarFlowVertical;
```

* Swift

```swift
calendar.flow = .Vertical 
```

![fscalendar-vertical](https://cloud.githubusercontent.com/assets/5186464/8448624/384e344c-1ffc-11e5-8b0b-1c3951dab2e1.gif)

#### If you want `FSCalendar` to scroll horizontally (Default)

* Objective - c

```objective-c
_calendar.flow = FSCalendarFlowHorizontal; // By default
```

* Swift

```swift
calendar.flow = .Horizontal 
```

![fscalendar-horizontal](https://cloud.githubusercontent.com/assets/5186464/8448696/059e9acc-1ffd-11e5-8a95-aff6d871c6e1.gif)

#### If you want `FSCalendar` to use `Monday` as the first column (or any other weekday)

```objective-c
_calendar.firstWeekday = 2; 
```

![fscalendar---monday](https://cloud.githubusercontent.com/assets/5186464/8448782/c92505e4-1ffd-11e5-95c0-9bf3c8bec669.png)


#### The date format of header can be customized

```objective-c
_calendar.appearance.headerDateFormat = @"MMM yy";
```

![fscalendar---headerformat](https://cloud.githubusercontent.com/assets/5186464/8449322/15d79168-2003-11e5-997a-06c6721dd807.png)

#### You can define the appearance

```objective-c
_calendar.appearance.weekdayTextColor = [UIColor redColor];
_calendar.appearance.headerTitleColor = [UIColor redColor];
_calendar.appearance.eventColor = [UIColor greenColor];
_calendar.appearance.selectionColor = [UIColor blueColor];
_calendar.appearance.todayColor = [UIColor orangeColor];
```

![fscalendar---colors](https://cloud.githubusercontent.com/assets/5186464/8449300/d55d1c7a-2002-11e5-8de6-be04f3783456.png)

#### The day shape doesn't have to be a circle

* Objective - c
```objective-c
_calendar.appearance.cellStyle = FSCalendarCellStyleRectangle;
```

* Swift
```swift
calendar.appearance.cellStyle = .Rectangle
```

![fscalendar---rectangle](https://cloud.githubusercontent.com/assets/5186464/8449186/d38ea39c-2001-11e5-99f4-32fcd6120a01.png)

#### `FSCalendar` can show subtitle for each day

```objective-c
// FSCalendarDataSource
- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date
{
    return yourSubtitle;
}
```

![fscalendar---subtitle1](https://cloud.githubusercontent.com/assets/5186464/8449076/b0be3d88-2000-11e5-9c5d-22ecd325b6cc.png)

&nbsp&nbsp&nbsp&nbsp

![fscalendar---subtitle2](https://cloud.githubusercontent.com/assets/5186464/8449075/b0bb34ee-2000-11e5-9c4a-401bc708d9ea.png)

#### And event dot for some days

```objective-c
// FSCalendarDataSource
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date
{
    return shouldShowEventDot;
}
```

#### Or an image for some days

```objective-c
// FSCalendarDataSource
- (UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date
{
    return anyImage;
}
```

![fscalendar---image](https://cloud.githubusercontent.com/assets/5186464/8449772/e94d3126-2006-11e5-8871-e4f8dbce81ea.png)

#### There are left and right boundaries

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

#### You can do something when a date is selected
```objective-c
// FSCalendarDelegate
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    // Do something
}
```

#### You can prevent it from being selected
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

#### You will get notified when `FSCalendar` changes the month
```objective-c
- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar
{
    // Do something
}
```

## Requirements
ios 7.0

## Compatibility
`FSCalendar` can be used on iPad.

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

3. Can we hide this?

```objective-c
_calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
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

