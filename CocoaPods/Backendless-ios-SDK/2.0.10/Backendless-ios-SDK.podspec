Pod::Spec.new do |s|
  s.name         = "Backendless-ios-SDK"
  s.version      = "2.0.10"
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
  s.license		= { :type => 'Apache', :text => 'Copyright (c) 2012-2015 by Backendless.com' }
  s.author      = { "Vyacheslav Vdovichenko" => "slavav@themidnightcoders.com" }

  s.platform       = :ios, '8.3'
  s.requires_arc   = true
  s.source         = { 
	:git => "https://github.com/Backendless/ios-SDK.git",
    :commit =>"298880195247af721d52afde29c68fae6f9491d3",
	:tag => '2.0.10'
  }

  s.preserve_paths = "SDK/lib/**/*.a"
  s.source_files = "SDK/lib/**/*.h"

  s.frameworks     = 'AVFoundation','AudioToolbox', 'CFNetwork', 'CoreData', 'CoreGraphics', 'CoreLocation', 'CoreMedia', 'CoreVideo', 'Foundation', 'MapKit', 'Security', 'SystemConfiguration', 'UIKit'
  s.libraries 	   = 'z', 'sqlite3', 'backendless', 'CommLibiOS', 'MediaLibiOS', 'swresample', 'avformat', 'avdevice', 'swscale', 'avfilter', 'avutil', 'avcodec', 'speex', 'speexdsp', 'x264'
  s.xcconfig       =  { 'SWIFT_OBJC_BRIDGING_HEADER' => '${PODS_ROOT}/Headers/Public/Backendless-ios-SDK/Backendless-With-Media-Bridging-Header.h' }

  s.prepare_command = <<-CMD

    pushd SDK/lib/backendless/
	  ln -s backendless.a libbackendless.a
	popd
	
	pushd SDK/lib/CommLibiOS/
	  ln -s CommLibiOS.a libCommLibiOS.a
	popd
	
	pushd SDK/lib/MediaLibiOS3x/
	  ln -s MediaLibiOS.a libMediaLibiOS.a
	popd
	
    CMD
end