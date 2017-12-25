Pod::Spec.new do |s|
  s.name             = "KKBOXOpenAPI"
  s.version          = "1.1.3"
  s.license          = {:type => 'Private', :text => 'Private'}
  s.summary          = "KKBOX's Open API client for iOS, macOS, watchOS and tvOS."
  s.homepage         = "https://kkbox.com"
  s.author           = { "Weizhong Yang" => "wzyang@kkbox.com" }
  s.source           = { :git => "https://gitlab.kkinternal.com/kkbox-ios/kkbox_openapi_ios_sdk.git", :tag => s.version.to_s }

  s.platform         = :ios, :tvos, :osx
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc     = true
  s.source_files     = 'KKBOXOpenAPI/*.{h,m}'
  s.ios.frameworks = 'UIKit'
  s.tvos.frameworks = 'UIKit'
  s.osx.frameworks = 'AppKit'
end
