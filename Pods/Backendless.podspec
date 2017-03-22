Pod::Spec.new do |s|
  s.name         = "Backendless"
  s.version      = "4.0b1"
  s.summary      = "Backendless provides an instant backend to help developers build better apps faster."
  s.description  = <<-DESC
	Backendless is a development and a run-time platform. It helps software developers to create 
	mobile and desktop applications while removing the need for server-side coding. The platform 
	consists of five core backend services which developers typically spend time implementing for
	each new applications. These services include:

		User Service – facilitates user registrations, login, logout, session management.
		Data Service – is responsible for data management – storage, retrieval, updates and deletion.
		Messaging Service – handles message publishing, broadcast, filtered message delivery and native mobile push notifications.
		Files Service – is responsible for file uploads, downloads and file sharing.
		Geo-Location Service – supports geo spatial data imports and geo queries.

		The Backendless services can be accessed through an easy-to-use APIs which we packaged into our 
		SDKs. The behavior of the services and the business logic behind them can be customized through 
		the Development Console.
                   DESC
  s.homepage    = "http://backendless.com"
  s.license		= { :type => 'Apache', :text => 'Copyright (c) 2012-2017 by Backendless.com' }
  s.author      = { "Mark Piller" => "mark@backendless.com" }

  s.platform       = :ios, '8.0'
  s.requires_arc   = true
  s.source         = { 
	:git => "https://github.com/Backendless/ios-SDK.git",
	:tag => '4.0b1'
  }

  s.preserve_paths = "SDK/ios/**/*.a"
  s.source_files = "SDK/ios/**/*.h"

  s.frameworks     = 'CFNetwork', 'CoreLocation', 'Foundation', 'MapKit', 'Security', 'SystemConfiguration', 'SafariServices'
  s.libraries 	   = 'backendless'
  s.xcconfig       =  { 'LIBRARY_SEARCH_PATHS' => '"$(SRCROOT)/Pods/Backendless/SDK/ios/backendless"' }

  s.prepare_command = <<-CMD

    pushd SDK/ios/backendless/
	  ln -s backendless.a libbackendless.a
	popd
	
    CMD
end
