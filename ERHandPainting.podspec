
Pod::Spec.new do |s|
  s.name         = "ERHandPainting"
  s.version      = "1.0.0"
  s.summary      = "You Can drawn on UIImageView"
  s.homepage     = "https://github.com/ErHu1993/ERHandPainting"
  s.license= { :type => "MIT", :file => "LICENSE" }
  s.author             = { "huguangyu" => "199301055@qq.com" }
  s.source       = { :git => "https://github.com/ErHu1993/ERHandPainting.git", :tag => "s.version" }
  s.source_files  = "HandPainting/*"
  s.ios.deployment_target = "7.0"
end
