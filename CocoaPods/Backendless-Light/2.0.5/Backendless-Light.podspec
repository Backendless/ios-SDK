Pod::Spec.new do |s|
  s.name         = "Backendless-Light"
  s.version      = "2.0.5"
  s.summary      = "Backendless provides an instant backend to help developers build better apps faster. 'Light' means 'without MediaService and media support libs'"
  s.description  = <<-DESC
	Backendless is a development and a run-time platform. It helps software developers to create 
	mobile and desktop applications while removing the need for server-side coding. The platform 
	consists of six core backend services which developers typically spend time implementing for 
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
  s.homepage    = "http://Backendless.com"
  s.screenshots = "https://backendless.com/wp-content/uploads/2013/03/Backendless_architecture-1024x710.jpg"
  s.license		= { :type => 'Apache', :text => 'Copyright (c) 2012-2015 by Backendless.com' }
  s.author      = { "Vyacheslav Vdovichenko" => "slavav@themidnightcoders.com" }

  s.platform       = :ios, '8.3'
  s.requires_arc   = true
  s.source         = { 
	:git => "https://github.com/Backendless/ios-SDK.git", 
    :commit => "23c70990e90b05c5a3e9b3c3c0b1bd8c49e3583f",
	:tag => '2.0.5'
  }

  s.preserve_paths = "**/*.a"
  s.source_files = "**/*.h"
  s.exclude_files  = "**/*mac.a", "SDK/lib/MediaLibiOS3x/*", "SDK/lib/ffmpeg-2.2.1/*", "SDK/lib/libspeex-1.2rc1/*", "SDK/lib/libx264-r2409/*"

  s.frameworks = 'SystemConfiguration'
  s.libraries = 'sqlite3', 'backendless', 'CommLibiOS'
  s.xcconfig =  { 'LIBRARY_SEARCH_PATHS' => '"$(SRCROOT)/Pods/Backendless-Light/SDK/lib/backendless" "$(SRCROOT)/Pods/Backendless-Light/SDK/lib/CommLibiOS"', 'SWIFT_OBJC_BRIDGING_HEADER' => '${PODS_ROOT}/Headers/Public/Backendless-Light/Backendless-Bridging-Header.h' }

  s.prepare_command = <<-CMD

    pushd SDK/lib/backendless/
	  ln -s backendless.a libbackendless.a
	popd
	
	pushd SDK/lib/CommLibiOS/
	  ln -s CommLibiOS.a libCommLibiOS.a
	popd
	
    CMD
end