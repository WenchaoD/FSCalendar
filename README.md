![fscalendar](https://cloud.githubusercontent.com/assets/5186464/6655324/213a814a-cb36-11e4-9add-f80515a83291.png)<br/><br/>
[![Travis](https://travis-ci.org/WenchaoD/FSCalendar.svg?branch=master)](https://travis-ci.org/WenchaoD/FSCalendar)
[![Version](https://img.shields.io/cocoapods/v/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![Platform](https://img.shields.io/badge/platform-iOS%207%2B-blue.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![Swift2 compatible](https://img.shields.io/badge/swift2-compatible-4BC51D.svg?style=flat)](https://developer.apple.com/swift/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![Join the chat at https://gitter.im/WenchaoD/FSCalendar](https://badges.gitter.im/WenchaoD/FSCalendar.svg)](https://gitter.im/WenchaoD/FSCalendar?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

# Screenshots

## iPhone
![fscalendar](https://cloud.githubusercontent.com/assets/5186464/10262249/4fabae40-69f2-11e5-97ab-afbacd0a3da2.jpg)

## iPad
![fscalendar-ipad](https://cloud.githubusercontent.com/assets/5186464/10927681/d2448cb6-82dc-11e5-9d11-f664a06698a7.jpg)

## Working with AutoLayout and Orientation
![fscalendar-scope-orientation-autolayout](https://cloud.githubusercontent.com/assets/5186464/13728798/59855e3e-e95e-11e5-84db-60f843427ef3.gif)

# Installation

## CocoaPods:

* For iOS8+: 👍
```ruby
use_frameworks!
pod 'FSCalendar'
```

* For iOS7+:
```ruby
pod 'FSCalendar'
```

* Alternatively to give it a test run, run the command:
```ruby
pod try FSCalendar
```

## Carthage: 
* For iOS8+
```ruby
github "WenchaoD/FSCalendar"
```

## Manually:
* Drag all files under `FSCalendar` folder into your project. 👍

## Support IBInspectable / IBDesignable
Only the methods marked "👍" support IBInspectable / IBDesignable feature. [Have fun with Interface builder](#roll_with_interface_builder)

# Setup

## Use Interface Builder

1. Drag an UIView object to ViewController Scene
2. Change the `Custom Class` to `FSCalendar`<br/>
3. Link `dataSource` and `delegate` to the ViewController <br/>

![fscalendar-ib](https://cloud.githubusercontent.com/assets/5186464/9488580/a360297e-4c0d-11e5-8548-ee9274e7c4af.jpg)

4. Finally, you should implement `FSCalendarDataSource` and `FSCalendarDelegate` in ViewController.m

## Or use code

```objc
@property (weak , nonatomic) FSCalendar *calendar;
```
```objc
// In loadView(Recommended) or viewDidLoad
FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
calendar.dataSource = self;
calendar.delegate = self;
[self.view addSubview:calendar];
self.calendar = calendar;
```
<br/>

## Or swift

* To use `FSCalendar` in swift, you need to [Create Bridge Header](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html) first.


```swift
private weak var calendar: FSCalendar!
```
```swift
// In loadView or viewDidLoad
let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
calendar.dataSource = self
calendar.delegate = self
view.addSubview(calendar)
self.calendar = calendar
```
<br/>


## Hide placeholder dates
![fscalendar-showsplaceholder](https://cloud.githubusercontent.com/assets/5186464/13727902/21a90042-e940-11e5-9b9f-392f38cf007d.gif)

1. Set `calendar.showsPlaceholders = NO`;
2. <a id="implement_bounding_rect_will_change"></a> Implement `-calendar:boundingRectWillChange:animated:`

```objc
// For autoLayout
- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    _calendarHeightConstraint.constant = CGRectGetHeight(bounds);
    [self.view layoutIfNeeded];
}
```

```objc
// For manual layout
- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
}
```

### <a id="roll_with_interface_builder"></a> Roll with Interface Builder
![fscalendar - ibdesignable](https://cloud.githubusercontent.com/assets/5186464/9301716/2e76a2ca-4503-11e5-8450-1fa7aa93e9fd.gif)

## More Usage
* To view more usage, download the zip file and read the example.
* Or you could refer to [this document](https://github.com/WenchaoD/FSCalendar/blob/master/MOREUSAGE.md)
* To view the full documentation, see [CocoaPods Documentation](http://cocoadocs.org/docsets/FSCalendar/2.0.1/)

# If you like this repo
* ***Star*** this repo.
* Send your calendar screenshot or `itunes link address` [here](https://github.com/WenchaoD/FSCalendar/issues/2).

# Support me via  [![paypal](https://www.paypalobjects.com/webstatic/i/logo/rebrand/ppcom.svg)](https://www.paypalobjects.com/webstatic/i/logo/rebrand/ppcom.svg)
* ☕️ [This coffee is on me!](https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=Z84P82H3V4Q26&lc=C2&item_name=This%20coffee%20is%20on%20me%21&item_number=Support%20FSCalendar%20%2d%20WenchaoIOS&amount=5%2e00&currency_code=USD&button_subtype=services&bn=PP%2dBuyNowBF%3abtn_buynowCC_LG%2egif%3aNonHosted)
* [Lunch is on me!](https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=Z84P82H3V4Q26&lc=C2&item_name=Lunch%20is%20on%20me%21&item_number=Support%20FSCalendar&amount=10%2e00&currency_code=USD&button_subtype=services&bn=PP%2dBuyNowBF%3abtn_buynowCC_LG%2egif%3aNonHosted)
* [Have a nice dinner!](https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=Z84P82H3V4Q26&lc=C2&item_name=Tonight%27s%20dinner%20is%20on%20me%21&item_number=Support%20FSCalendar%20%2d%20WenchaoIOS&amount=25%2e00&currency_code=USD&button_subtype=services&bn=PP%2dBuyNowBF%3abtn_buynowCC_LG%2egif%3aNonHosted)
* [Greate work! Keep the change!](https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=Z84P82H3V4Q26&lc=C2&item_name=Great%20work%21%20Keep%20the%20change%21&item_number=Support%20FSCalendar%20%2d%20WenchaoIOS&amount=100%2e00&currency_code=USD&button_subtype=services&bn=PP%2dBuyNowBF%3abtn_buynowCC_LG%2egif%3aNonHosted)

# License
FSCalendar is available under the MIT license. See the LICENSE file for more info.

# Contributions
* Issues and pull requests are absolutely welcome.
* For code contributions, please follow [Coding Guidelines for Cocoa](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html)

# Contact
* Email: `f33chobits@gmail.com`

