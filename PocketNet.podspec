Pod::Spec.new do |s|
  s.name         = "PocketNet"
  s.version      = "1.3.2.1"
  s.homepage     = "https://github.com/PocketSwift/PocketNet"
  s.summary      = "Net with Alamofire implementation"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "PocketSwift" => "https://github.com/PocketSwift" }
  s.source       = { :git => "https://github.com/PocketSwift/PocketNet.git", :tag => "1.3.2.1" }
  s.static_framework = true
  s.source_files = 'Classes', 'PocketNet/**/*.swift', 'StaticPods/**/*.swift'
  s.platform     = :ios, '9.0'
  s.requires_arc = true
end