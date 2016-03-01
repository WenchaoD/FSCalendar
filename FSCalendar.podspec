Pod::Spec.new do |s|

  s.name             = "FSCalendar"
  s.version          = "1.9.0.beta"
  s.summary          = "Designed to build the best iOS calendar control."
  
  s.homepage         = "https://github.com/WenchaoIOS/FSCalendar"
  s.screenshots      = "https://cloud.githubusercontent.com/assets/5186464/10262249/4fabae40-69f2-11e5-97ab-afbacd0a3da2.jpg"
  s.license          = 'MIT'
  s.author           = { "Wenchao Ding" => "f33chobits@gmail.com" }
  s.source           = { :git => "https://github.com/f33chobits/FSCalendar.git", :tag => s.version.to_s }

  s.platform     = :ios
  s.ios.deployment_target = '7.0'
  s.requires_arc = true
  s.framework    = 'UIKit', 'QuartzCore'
  s.source_files = 'FSCalendar/*.{h,m}'

end
