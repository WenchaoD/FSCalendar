#
# Be sure to run `pod lib lint FSCalendar.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "FSCalendar"
  s.version          = "0.0.1"
  s.summary          = "A powerful calendar which supports Appearance, Infinite Scrolling and Subtitle"
  #s.description      = <<-DESC
  #                     An optional longer description of FSCalendar
  #
  #                      * Markdown format.
  #                     * Don't worry about the indent, we strip it!
  #                    DESC
  s.homepage         = "https://github.com/f33chobits/FSCalendar"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "=" => "f33chobits@gmail.com" }
  s.source           = { :git => "https://github.com/f33chobits/FSCalendar.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'FSCalendar' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
