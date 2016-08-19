
Backendless iOS SDK (http://backendless.com)
_____________________________________________

============== USING WITH COCOAPODS:

To create a new project with CocoaPods, follow these simple steps:

- Create a new project in Xcode as you would normally, then close this project.
- Open a Terminal window, and $ cd into your project directory.
- Create a Podfile. This can be done by running $ touch Podfile.
- Open your Podfile using Xcode, and add a text that looks like this:
        
a. if you use iOS, and you need Backendless MediaService: 
        pod 'Backendless-ios-SDK'
    
b. if you use iOS, and you do not need Backendless MediaService:
        pod 'Backendless'
    
c. if you use OSX:
        pod 'Backendless-osx-SDK'

- Save Podfile, return to Terminal window and run $ pod install. Once all of the pod data is downloaded, Xcode project workspace file will be created. This should be the file you use everyday to create your app.
- Open .xcworkspace file to launch your project.

- If you use Swift, add to your briging header file the following

a. for 'Backendless-ios-SDK':
    #import "Backendless.h"
    #import "MediaService.h"

b. for other pods:
    #import "Backendless.h"

If you don't have your briging header file, set "Build Setting -> Swift Compiler ... -> Objective-C Bridgeing Header" (SWIFT_OBJC_BRIDGING_HEADER) option

a. for 'Backendless-ios-SDK':
    ${PODS_ROOT}/Headers/Public/Backendless-ios-SDK/Backendless-With-Media-Bridging-Header.h

b. for other pods:
    ${PODS_ROOT}/Headers/Public/Backendless/Backendless-Bridging-Header.h


============== USING WIHOUT COCOAPODS:

To create a new project, follow the guide: 'getting-started'

If you need to update your existing project to iOS 9.x, follow the guide: 'Update Project with Backendless SDK for iOS9'
