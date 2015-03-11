Pod::Spec.new do |s|

  s.name             = "FSCalendar"
  s.version          = "0.2.0"
  s.summary          = "A powerful calendar which supports Appearance, Infinite Scrolling and Subtitle"
  
  s.homepage         = "https://github.com/f33chobits/FSCalendar"
  s.screenshots     = "https://cloud.githubusercontent.com/assets/5186464/6260896/de303034-b820-11e4-9f01-8d98e0ac94aa.gif","https://cloud.githubusercontent.com/assets/5186464/6479246/6156c458-c27d-11e4-97da-52b424b45ec3.gif","https://cloud.githubusercontent.com/assets/5186464/6208969/20ee842a-b5fb-11e4-8875-132d42893b9e.png", "https://cloud.githubusercontent.com/assets/5186464/6209081/54d8a4cc-b5fc-11e4-981e-d4bb21a45628.png","https://cloud.githubusercontent.com/assets/5186464/6502151/b4ce3092-c35b-11e4-827a-498d73579d78.jpg"
  s.license          = 'MIT'
  s.author           = { "Wenchao Ding" => "f33chobits@gmail.com" }
  s.source           = { :git => "https://github.com/f33chobits/FSCalendar.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.framework    = 'UIKit', 'QuartzCore'
  s.source_files = 'Pod/Classes/**/*'

end
