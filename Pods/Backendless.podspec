Pod::Spec.new do |spec|
  spec.name          = 'Backendless'
  spec.version       = '5.0.2'
  spec.license       = { :type => 'Apache', :text => 'Copyright (c) 2013-2018 by Backendless.com' }
  spec.homepage      = 'http://backendless.com'
  spec.authors       = { 'Mark Piller' => 'mark@backendless.com' }
  spec.summary       = 'Backendless is a Mobile Backend and API Services Platform'
  spec.description   = 'Backendless is a development and a run-time platform. It helps software developers to create mobile and desktop applications while removing the need for server-side coding.'
  spec.source        = { :git => 'https://github.com/Backendless/ios-SDK.git', :tag => '5.0.2' }
  spec.swift_version = '4.1'

  spec.ios.deployment_target  = '8.0'
  spec.osx.deployment_target  = '10.10'

  spec.ios.source_files   = 'SDK/ios/**/*.h'
  spec.osx.source_files    = 'SDK/osx/**/*.h'

  spec.ios.preserve_paths    = 'SDK/ios/**/*.a'
  spec.osx.preserve_paths    = 'SDK/osx/**/*.a'

  spec.framework      = 'SystemConfiguration'
  spec.ios.framework  = 'UIKit', 'CoreLocation', 'Foundation'
  spec.osx.framework  = 'AppKit'

  spec.libraries    = 'backendless'

  spec.ios.xcconfig    =  { 'LIBRARY_SEARCH_PATHS' => '"$(SRCROOT)/Pods/Backendless/SDK/ios/backendless"' }
  spec.osx.xcconfig    =  { 'LIBRARY_SEARCH_PATHS' => '"$(SRCROOT)/Pods/Backendless/SDK/osx/backendless"' }

spec.prepare_command = <<-CMD
    pushd SDK/ios/backendless/
      ln -s backendless.a libbackendless.a
    popd

    pushd SDK/osx/backendless/
      ln -s backendless.a libbackendless.a
    popd
CMD

spec.dependency 'Socket.IO-Client-Swift'

end
