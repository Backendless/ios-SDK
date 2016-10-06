Pod::Spec.new do |s|
  s.name         = "Backendless-osx-SDK"
  s.version      = "3.0.43"
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
  s.license		= { :type => 'Apache', :text => 'Copyright (c) 2012-2016 by Backendless.com' }
  s.author      = { "Mark Piller" => "mark@backendless.com" }

  s.platform       = :osx, '10.8'
  s.requires_arc   = true
  s.source         = { 
	:git => "https://github.com/Backendless/ios-SDK.git",
	:tag => '3.0.43'
  }

  s.preserve_paths = "SDK/osx/**/*.a"
  s.source_files = "SDK/osx/**/*.h"

  s.frameworks     = 'SystemConfiguration'
  s.libraries 	   = 'sqlite3', 'backendless-mac', 'CommLib-osx'
  s.xcconfig       =  { 'LIBRARY_SEARCH_PATHS' => '"$(SRCROOT)/Pods/Backendless-osx-SDK/SDK/osx/backendless" "$(SRCROOT)/Pods/Backendless-osx-SDK/SDK/osx/CommLib"' }

end
