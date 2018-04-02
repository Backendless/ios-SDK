Pod::Spec.new do |s|
  s.name	= "Backendless-osx-SDK"
  s.version	= "4.0.29"
  s.summary	= 'Backendless provides an instant backend to help developers build better apps faster.'
  s.description	= 'Backendless is a development and a run-time platform. It helps software developers to create \nmobile and desktop applications while removing the need for server-side coding. The platform \nconsists of six core backend services which developers typically spend time implementing for \neach new applications. These services include:\n\n\tUser Service – facilitates user registrations, login, logout, session management.\n\tData Service – is responsible for data management – storage, retrieval, updates and deletion.\n\tMessaging Service – handles message publishing, broadcast, filtered message delivery and native mobile push notifications.\n\tFiles Service – is responsible for file uploads, downloads and file sharing.\n\tGeo-Location Service – supports geo spatial data imports and geo queries.\n\n\tThe Backendless services can be accessed through an easy-to-use APIs which we packaged into our \n\tSDKs. The behavior of the services and the business logic behind them can be customized through \n\tthe Development Console.'
  s.homepage	= 'http://backendless.com'
  s.license	= { :type => 'Apache', :text => 'Copyright (c) 2012-2018 by Backendless.com' }
  s.author	= { 'Mark Piller' => 'mark@backendless.com' }

  s.platform		= :osx, '10.8'
  s.requires_arc	= true
  s.source         	= { 
	:git => "https://github.com/Backendless/ios-SDK.git",
	:tag => '4.0.29'
  }

  s.preserve_paths	= "SDK/osx/**/*.a"
  s.source_files	= "SDK/osx/**/*.h"

  s.frameworks	= 'SystemConfiguration'
  s.libraries	= 'backendless-mac'
  s.xcconfig	=  { 'LIBRARY_SEARCH_PATHS' => '"$(SRCROOT)/Pods/Backendless-osx-SDK/SDK/osx/backendless"' }

end
