Pod::Spec.new do |s|

  s.name         = "WJPhotoBrowser"
  s.version      = "1.1.9"
  s.summary      = "A simple and easy to use image browser."
  s.homepage     = "https://github.com/ZengWeiJun/WJPhotoBrowser"
  s.license      = "MIT"
  s.author       = { "zwj" => "niuszeng@sina.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/ZengWeiJun/WJPhotoBrowser.git", :tag => s.version }
  s.source_files  = "WJPhotoBrowser", "WJPhotoBrowser/*.{h,m}"
#s.resources = "WJPhotoBrowser/images/*.png"
  s.framework  = "UIKit"
  s.requires_arc = true
  s.dependency "pop"
end
