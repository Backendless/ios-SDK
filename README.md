ios-SDK
=======

iOS SDK

======= ADDITIONAL SWIFT PROJECT SETTINGS:

Set target's Build Settings -> "Swift Compiller - Code Generation" -> "Objective-C Bridging Header" option in:
    $(PROJECT_DIR)/../lib/backendless/include/Backendless-Bridging-Header.h

To create a new project with CocoaPods, follow these simple steps:

- Create a new project in Xcode as you would normally, then close this project.
- Open a Terminal window, and $ cd into your project directory.
- Create a Podfile. This can be done by running $ touch Podfile.
- Open your Podfile using your favorite text editor (or Xcode), and add a text that looks like this:

    platform :ios, '8.0'

    pod 'Backendless-ios-SDK', '~>2.0.0'

    The first line specifies the platform and supported version, the second line specifies the name of Backendless folder in CocoaPods Specs repository and SDK version which you need.

- Save Podfile, return to Terminal window and run $ pod install. Once all of the pod data is downloaded, Xcode project workspace file will be created. This should be the file you use everyday to create your app.
- Open .xcworkspace file to launch your project, and build it using scheme for iOS device.
- If you would like to run your application on the simulator (you can do it only without MediaService), you should remove from the Build Settings in the option "Linking" -> "Other Linking Flags" (OTHER_LDFLAGS) the substring “$(inherited) -ObjC” at the beginning of the line.

