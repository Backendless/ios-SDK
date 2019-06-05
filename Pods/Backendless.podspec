Pod::Spec.new do |spec|
  spec.name          = 'Backendless'
  spec.version       = '5.3.8'
  spec.license       = { :type => 'Apache', :text => 'Copyright (c) 2013-2019 by Backendless.com' }
  spec.homepage      = 'http://backendless.com'
  spec.authors       = { 'Mark Piller' => 'mark@backendless.com' }
  spec.summary       = 'Backendless is a Mobile Backend and API Services Platform'
  spec.description   = 'Backendless is a development and a run-time platform. It helps software developers to create mobile and desktop applications while removing the need for server-side coding.'
  spec.source        = { :git => 'https://github.com/Backendless/ios-SDK.git', :tag => '5.3.8' }
  spec.swift_version = '4.2'

  spec.ios.deployment_target  = '8.0'
  spec.osx.deployment_target  = '10.10'
  spec.tvos.deployment_target = '9.0'
  spec.watchos.deployment_target = '2.0'

  spec.ios.source_files   = 'SDK/ios/**/*.h'
  spec.osx.source_files    = 'SDK/osx/**/*.h'
  spec.tvos.source_files    = 'SDK/tvos/**/*.h'
  spec.watchos.source_files    = 'SDK/watchos/**/*.h'

  spec.ios.preserve_paths    = 'SDK/ios/**/*.a'
  spec.osx.preserve_paths    = 'SDK/osx/**/*.a'
  spec.tvos.preserve_paths    = 'SDK/tvos/**/*.a'
  spec.watchos.preserve_paths    = 'SDK/watchos/**/*.a'

  spec.ios.framework  = 'SystemConfiguration', 'UIKit', 'CoreLocation', 'Foundation'
  spec.osx.framework  = 'SystemConfiguration', 'AppKit'
  spec.tvos.framework  = 'SystemConfiguration', 'UIKit'

  spec.libraries    = 'backendless'

  spec.ios.xcconfig    =  { 'LIBRARY_SEARCH_PATHS' => '"$(SRCROOT)/Pods/Backendless/SDK/ios/backendless"' }
  spec.osx.xcconfig    =  { 'LIBRARY_SEARCH_PATHS' => '"$(SRCROOT)/Pods/Backendless/SDK/osx/backendless"' }
  spec.tvos.xcconfig    =  { 'LIBRARY_SEARCH_PATHS' => '"$(SRCROOT)/Pods/Backendless/SDK/tvos/backendless"' }
  spec.watchos.xcconfig    =  { 'LIBRARY_SEARCH_PATHS' => '"$(SRCROOT)/Pods/Backendless/SDK/watchos/backendless"' }

spec.prepare_command = <<-CMD
    pushd SDK/ios/backendless/
      ln -s backendless.a libbackendless.a
    popd

    pushd SDK/osx/backendless/
      ln -s backendless.a libbackendless.a
    popd

    pushd SDK/tvos/backendless/
      ln -s backendless.a libbackendless.a
    popd

    pushd SDK/watchos/backendless/
      ln -s backendless.a libbackendless.a
    popd
CMD

spec.dependency "Socket.IO-Client-Swift"

end
