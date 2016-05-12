Pod::Spec.new do |s|
  s.name         = "WJPhotoBrowser"
  s.version      = "0.0.1"
  s.summary      = "A simple and easy to use image browser."
  s.description  = <<-DESC
A simple and easy to use image browser,Colleagues can browse local and network images
                   DESC
  s.homepage     = "https://github.com/ZengWeiJun/WJPhotoBrowser"
  s.license      = "MIT"
  s.author             = { "zwj" => "niuszeng@sina.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/ZengWeiJun/WJPhotoBrowser.git", :tag => "0.0.1" }
  s.source_files  = "WJPhotoBrowser", "WJPhotoBrowser/*.{h,m}"
  s.resources = "WJPhotoBrowser/images/*.png"
  s.framework  = "UIKit"
  s.requires_arc = true
  s.dependency 'SDWebImage', '~> 3.7.2'

end
