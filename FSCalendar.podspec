Pod::Spec.new do |s|

  s.name             = "FSCalendar"
  s.version          = "0.0.3"
  s.summary          = "A powerful calendar which supports Appearance, Infinite Scrolling and Subtitle"
  
  s.homepage         = "https://github.com/f33chobits/FSCalendar"
  s.screenshots     = "https://cloud.githubusercontent.com/assets/5186464/6208969/20ee842a-b5fb-11e4-8875-132d42893b9e.png", "https://cloud.githubusercontent.com/assets/5186464/6209081/54d8a4cc-b5fc-11e4-981e-d4bb21a45628.png"
  s.license          = 'MIT'
  s.author           = { "Wenchao Ding" => "f33chobits@gmail.com" }
  s.source           = { :git => "https://github.com/f33chobits/FSCalendar.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'

end
