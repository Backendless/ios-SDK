Pod::Spec.new do |s|
  s.name         = "Backendless-Light"
  s.version      = "3.0.7"
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
  s.homepage    = "http://backendless.com"
  s.license		= { :type => 'Apache', :text => 'Copyright (c) 2012-2016 by Backendless.com' }
  s.author      = { "Mark Piller" => "mark@backendless.com" }

  s.platform       = :ios, '7.1'
  s.requires_arc   = true
  s.source         = { 
	:git => "https://github.com/Backendless/Backendless-Light.git",
    :commit => "25296d9292de4ac276b87b759d32df72e437b599",
	:tag => '3.0.7'
  }

  s.preserve_paths = "lib/**/*.a"
  s.source_files = "lib/**/*.h"

  s.frameworks     = 'SystemConfiguration'
  s.libraries 	   = 'sqlite3', 'backendless', 'CommLibiOS'
  s.xcconfig       =  { 'LIBRARY_SEARCH_PATHS' => '"$(SRCROOT)/Pods/Backendless-Light/lib/backendless" "$(SRCROOT)/Pods/Backendless-Light/lib/CommLibiOS"', 'SWIFT_OBJC_BRIDGING_HEADER' => '${PODS_ROOT}/Headers/Public/Backendless-Light/Backendless-Bridging-Header.h' }

  s.prepare_command = <<-CMD

    pushd lib/backendless/
	  ln -s backendless.a libbackendless.a
	popd
	
	pushd lib/CommLibiOS/
	  ln -s CommLibiOS.a libCommLibiOS.a
	popd

    CMD
end