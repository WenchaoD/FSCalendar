Pod::Spec.new do |s|

  s.name             = "FSCalendar"
  s.version          = "0.9.2"
  s.summary          = "A powerful calendar which supports Appearance, Infinite Scrolling and Subtitle"
  
  s.homepage         = "https://github.com/f33chobits/FSCalendar"
  s.screenshots      = "https://cloud.githubusercontent.com/assets/5186464/6655324/213a814a-cb36-11e4-9add-f80515a83291.png","https://cloud.githubusercontent.com/assets/5186464/6652191/f11d5242-caa1-11e4-9cc2-8a7c0cc9ef02.gif","https://cloud.githubusercontent.com/assets/5186464/6652193/19e7f92a-caa2-11e4-92af-0639dc0c2d79.gif","https://cloud.githubusercontent.com/assets/5186464/6680012/4af05080-cc8c-11e4-863a-59cd3507192d.gif"
  s.license          = 'MIT'
  s.author           = { "Wenchao Ding" => "f33chobits@gmail.com" }
  s.source           = { :git => "https://github.com/f33chobits/FSCalendar.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.framework    = 'UIKit', 'QuartzCore'
  s.source_files = 'Pod/Classes/**/*'

end
