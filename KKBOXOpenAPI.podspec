Pod::Spec.new do |s|
  s.name             = "KKBOXOpenAPI"
  s.version          = "1.1.4"
  s.license          = {:type => 'Apache 2.0', :file => "LICENSE"}
  s.summary          = "KKBOX's Open API client for iOS, macOS, watchOS and tvOS."
  s.homepage         = "https://github.com/KKBOX/OpenAPI-ObjectiveC"
  s.documentation_url = 'https://kkbox.github.io/OpenAPI-ObjectiveC/'
  s.author           = { "zonble" => "zonble@gmail.com" }
  s.source           = { :git => "https://github.com/KKBOX/OpenAPI-ObjectiveC.git", :tag => s.version.to_s }

  s.platform         = :ios, :tvos, :osx
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc     = true
  s.source_files     = 'KKBOXOpenAPI/*.{h,m}'
  s.ios.frameworks = 'UIKit'
  s.tvos.frameworks = 'UIKit'
  s.osx.frameworks = 'AppKit'
end
