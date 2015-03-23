Pod::Spec.new do |s|
  s.name         = "Backendless-Light"
  s.version      = "2.0.2"
  s.summary      = "Backendless provides an instant backend to help developers build better apps faster."
  s.description  = <<-DESC
	Backendless is a development and a run-time platform. It helps software developers to create 
	mobile and desktop applications while removing the need for server-side coding. The platform 
	consists of six core backend services which developers typically spend time implementing for 
	each new applications. These services include:

		User Service – facilitates user registrations, login, logout, session management.
		Data Service – is responsible for data management – storage, retrieval, updates and deletion.
		Messaging Service – handles message publishing, broadcast, filtered message delivery and native mobile push notifications.
		Files Service – is responsible for file uploads, downloads and file sharing.
		Media Service – provides support for video and audio streaming (up and down) and server-side recording.
		Geo-Location Service – supports geo spatial data imports and geo queries.

		The Backendless services can be accessed through an easy-to-use APIs which we packaged into our 
		SDKs. The behavior of the services and the business logic behind them can be customized through 
		the Development Console.
                   DESC
  s.homepage    = "http://Backendless.com"
  s.screenshots = "https://backendless.com/wp-content/uploads/2013/03/Backendless_architecture-1024x710.jpg"
  s.license		= { :type => 'Apache', :text => 'Copyright (c) 2012-2014 by Backendless.com' }
  s.author      = { "Vyacheslav Vdovichenko" => "slavav@themidnightcoders.com" }

  s.platform       = :ios, '8.1'
  s.requires_arc   = true
  s.source         = { 
	:git => "https://github.com/Backendless/ios-SDK.git", 
    :commit => "fc05ae2f54d19eb2c12d5eb8c11a293c0310a8e1",
	:tag => '2.0.2'
  }

  s.preserve_paths = "**/*.a"
  s.source_files = "**/*.h"
  s.exclude_files  = "**/*mac.a"
  s.frameworks     = 'CFNetwork', 'CoreData', 'CoreLocation', 'MapKit', 'Security', 'SystemConfiguration', 'UIKit'
  s.libraries 	   = 'sqlite3', 'backendless', 'CommLibiOS'
  s.xcconfig       =  { 'OTHER_LDFLAGS' => '-ObjC', 'LIBRARY_SEARCH_PATHS' => '"$(SRCROOT)/Pods/Backendless-Light/SDK/lib/backendless" "$(SRCROOT)/Pods/Backendless-Light/SDK/lib/CommLibiOS"', 'SWIFT_OBJC_BRIDGING_HEADER' => '${PODS_ROOT}/Headers/Backendless-Light/Backendless-Bridging-Header.h' }

  s.prepare_command = <<-CMD

    pushd SDK/lib/backendless/
	  ln -s backendless.a libbackendless.a
	popd
	
	pushd SDK/lib/CommLibiOS/
	  ln -s CommLibiOS.a libCommLibiOS.a
	popd
	
    CMD
end