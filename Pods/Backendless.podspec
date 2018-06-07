Pod::Spec.new do |spec|
  spec.name          = 'Backendless'
  spec.version       = '5.0'
  spec.license       = { :type => 'Apache', :text => 'Copyright (c) 2013-2018 by Backendless.com' }
  spec.homepage      = 'http://backendless.com'
  spec.authors       = { 'Mark Piller' => 'mark@backendless.com' }
  spec.summary       = 'Backendless is a Mobile Backend and API Services Platform'
  spec.description   = 'Backendless is a development and a run-time platform. It helps software developers to create mobile and desktop applications while removing the need for server-side coding.'
  spec.source        = { :git => 'https://github.com/Backendless/ios-SDK.git', :tag => '5.0' }
  spec.swift_version = '4.1'

  spec.ios.deployment_target  = '8.0'
  spec.osx.deployment_target  = '10.10'

  spec.ios.source_files   = 'SDK/ios/**/*.h'
  spec.osx.source_files    = "SDK/osx/**/*.h"

  spec.dependency 'Socket.IO-Client-Swift'

end