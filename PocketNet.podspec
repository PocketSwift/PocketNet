Pod::Spec.new do |s|
  s.name         = "PocketNet"
  s.version      = "1.1.0"
  s.homepage     = "https://github.com/PocketSwift/PocketNet"
  s.summary      = "Net with Alamofire implementation"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "PocketSwift" => "https://github.com/PocketSwift" }
  s.source       = { :git => "https://github.com/PocketSwift/PocketNet.git", :tag => "1.1.0" }
  s.source_files = 'Classes', 'PocketNet/*.{h,m,swift}', 'PocketNet/Net/*', 'PocketNet/Net/PocketNetAlamofire/*' 
  s.platform     = :ios, '10.0'
  s.requires_arc = true
  s.dependency 'Alamofire', '4.0'
  s.dependency 'ResponseDetective', '1.0'
  s.dependency 'Result', '3.0.0'
end