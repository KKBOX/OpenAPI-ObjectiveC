Pod::Spec.new do |s|
  s.name = "KKBOXOpenAPI"
  s.version = "1.1.11"
  s.license = {:type => 'Apache 2.0', :file => "LICENSE.txt"}
  s.summary = "KKBOX's Open API SDK for iOS, macOS, watchOS and tvOS."
  s.description = <<-DESC
  KKBOX's Open API SDK for developers working on Apple platforms such as iOS, macOS, watchOS and tvOS.
                       DESC
  s.homepage = "https://github.com/KKBOX/OpenAPI-ObjectiveC/"
  s.documentation_url = 'https://kkbox.github.io/OpenAPI-ObjectiveC/'
  s.author = {"zonble" => "zonble@gmail.com"}
  s.source = {:git => "https://github.com/KKBOX/OpenAPI-ObjectiveC.git", :tag => s.version.to_s}

  s.platform = :ios, :tvos, :osx
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'
  s.requires_arc = true
  s.source_files = 'KKBOXOpenAPI/*.{h,m}'
  s.ios.frameworks = 'UIKit'
  s.osx.frameworks = 'AppKit'
  s.tvos.frameworks = 'UIKit'
end
