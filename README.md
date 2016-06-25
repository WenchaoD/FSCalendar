
![fscalendar](https://cloud.githubusercontent.com/assets/5186464/6655324/213a814a-cb36-11e4-9add-f80515a83291.png)<br/><br/>
[![Travis](https://travis-ci.org/WenchaoD/FSCalendar.svg?branch=master)](https://travis-ci.org/WenchaoD/FSCalendar)
[![Version](https://img.shields.io/cocoapods/v/FSCalendar.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![Platform](https://img.shields.io/badge/platform-iOS%207%2B-blue.svg?style=flat)](http://cocoadocs.org/docsets/FSCalendar)
[![Swift2 compatible](https://img.shields.io/badge/swift2-compatible-4BC51D.svg?style=flat)](https://developer.apple.com/swift/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![QQ group](https://img.shields.io/badge/QQ%E7%BE%A4-323861692-orange.svg)](https://github.com/WenchaoD)
[![Twitter](https://img.shields.io/badge/Twitter-@WenchaoD-55ACEE.svg)](https://twitter.com/WenchaoD)
[![微博](https://img.shields.io/badge/%E5%BE%AE%E5%8D%9A-@WenchaoD-%23E6162D.svg)](http://weibo.com/WenchaoD)

* 在您静静的离开之前，请确保点击了这个按钮<img style="margin-bottom:-12px"" width="72" alt="star" src="https://cloud.githubusercontent.com/assets/5186464/15383105/fcf9cdf0-1dc2-11e6-88db-bf221042a584.png"><br>
* Before leaving quietly, please make sure you've taken good care of this button.<img style="margin-bottom:-12px"" width="72" alt="star" src="https://cloud.githubusercontent.com/assets/5186464/15383105/fcf9cdf0-1dc2-11e6-88db-bf221042a584.png"> 


# [中文介绍](http://www.jianshu.com/notebooks/4276521/latest)


# Table of contents
* [Screenshots](#screenshots)
* [Installation](#installation)
* [Advanced usage](#advanced_usage)
* [Support me](#support)

# <a id="screenshots"></a>Screenshots

## iPhone
![fscalendar](https://cloud.githubusercontent.com/assets/5186464/10262249/4fabae40-69f2-11e5-97ab-afbacd0a3da2.jpg)

## iPad
![fscalendar-ipad](https://cloud.githubusercontent.com/assets/5186464/10927681/d2448cb6-82dc-11e5-9d11-f664a06698a7.jpg)

## Working with AutoLayout and Orientation
![fscalendar-scope-orientation-autolayout](https://cloud.githubusercontent.com/assets/5186464/13728798/59855e3e-e95e-11e5-84db-60f843427ef3.gif)

## Hide placeholder dates
![fscalendar-showsplaceholder](https://cloud.githubusercontent.com/assets/5186464/13727902/21a90042-e940-11e5-9b9f-392f38cf007d.gif)

## Scope handle
![scopehandle](https://cloud.githubusercontent.com/assets/5186464/15096674/5270ef9c-1536-11e6-88b0-c4e3e8f93115.gif)

> FSCalendar doesn't change frame or the constraint by itself, see [Adjusts frame dynamicly](#adjusts_frame_dynamicly)

# <a id="installation"></a>Installation

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

## <a id='adjusts_frame_dynamicly' /></a>Warning 
`FSCalendar` doesn't change frame by itself, Please implement

* For autoLayout

```objc
- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    _calendarHeightConstraint.constant = CGRectGetHeight(bounds);
    [self.view layoutIfNeeded];
}
```

* For manual layout

```objc
- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
}
```

### <a id="roll_with_interface_builder"></a> Roll with Interface Builder
![fscalendar - ibdesignable](https://cloud.githubusercontent.com/assets/5186464/9301716/2e76a2ca-4503-11e5-8450-1fa7aa93e9fd.gif)

## <a id="advanced_usage"></a>Advanced Usage
* To view more usage, download the zip file and read the example.
* Or you could refer to [this document](https://github.com/WenchaoD/FSCalendar/blob/master/MOREUSAGE.md)
* To view the full documentation, see [CocoaPods Documentation](http://cocoadocs.org/docsets/FSCalendar/2.0.1/)

# <a id="support"></a>Support me via [![paypal](https://www.paypalobjects.com/webstatic/i/logo/rebrand/ppcom.svg)](https://www.paypalobjects.com/webstatic/i/logo/rebrand/ppcom.svg) <br>

* ☕️ [This coffee is on me!](https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=Z84P82H3V4Q26&lc=C2&item_name=This%20coffee%20is%20on%20me%21&item_number=Support%20FSCalendar%20%2d%20WenchaoIOS&amount=5%2e00&currency_code=USD&button_subtype=services&bn=PP%2dBuyNowBF%3abtn_buynowCC_LG%2egif%3aNonHosted)
* [Lunch is on me!](https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=Z84P82H3V4Q26&lc=C2&item_name=Lunch%20is%20on%20me%21&item_number=Support%20FSCalendar&amount=10%2e00&currency_code=USD&button_subtype=services&bn=PP%2dBuyNowBF%3abtn_buynowCC_LG%2egif%3aNonHosted)
* [Have a nice dinner!](https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=Z84P82H3V4Q26&lc=C2&item_name=Tonight%27s%20dinner%20is%20on%20me%21&item_number=Support%20FSCalendar%20%2d%20WenchaoIOS&amount=25%2e00&currency_code=USD&button_subtype=services&bn=PP%2dBuyNowBF%3abtn_buynowCC_LG%2egif%3aNonHosted)
* [Greate work! Keep the change!](https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=Z84P82H3V4Q26&lc=C2&item_name=Great%20work%21%20Keep%20the%20change%21&item_number=Support%20FSCalendar%20%2d%20WenchaoIOS&amount=100%2e00&currency_code=USD&button_subtype=services&bn=PP%2dBuyNowBF%3abtn_buynowCC_LG%2egif%3aNonHosted)

<br/>

# 打赏支持

<div class="center">
<a href="https://cloud.githubusercontent.com/assets/5186464/15096775/bacc0506-1539-11e6-91b7-b1a7a773622b.png" target="_blank"><img src="http://a1.mzstatic.com/us/r30/Purple49/v4/50/16/b3/5016b341-39c1-b47b-2994-d7e23823baed/icon175x175.png" width="150" height="150" style="-webkit-border-radius:20px;border:1px solid rgba(30, 154, 236, 1)"></a>
<a href="https://cloud.githubusercontent.com/assets/5186464/15096872/b06f3a3a-153c-11e6-89f9-2e9c7b88ef42.png" target="_blank"><img src="http://a4.mzstatic.com/us/r30/Purple49/v4/23/31/14/233114f8-2e8d-7b63-8dc5-85d29893061e/icon175x175.jpeg" height="150" width="150" style="margin-left:15px;-webkit-border-radius: 20px;border:1px solid rgba(43, 177, 0, 1)"></a>
</div>


# Communications
* If you found a bug ***with certain steps to reproduce***, open an issue.
* If you need help about your code, use [stackoverflow](http://stackoverflow.com/questions/tagged/fscalendar) and tag `fscalendar`
* If you want to contribute, submit a pull request. Make sure to follow [Coding Guidelines for Cocoa](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html)

# License
FSCalendar is available under the MIT license. See the LICENSE file for more info.

