Backendless SDK for iOS (http://backendless.com)
---

# Version 4.0 Beta 6
The source code for version 4.0 is currently available in a separate branch of this repository: https://github.com/Backendless/ios-SDK/tree/4.0
> For the instructions for version 3.x of the library, see [Backendless 3.x Getting Started Guide](https://backendless.com/mobile-developers/quick-start-guide-for-ios/ "Backendless 3.x Getting Started Guide")

## GETTING STARTED WITH BACKENDLESS
The simplest way to get started with Backendless is by using a Project Template for iOS:
1. Register for your free account at https://develop.backendless.com
2. Login to Backendless Console and create a new app
3. Click the Download Project Template button: 

   ![Download Project Template](https://backendless.com/docs/images/shared/download-proj-template.png "Download Project Template")
4. Double click the iOS icon, then select Objective-C or Swift:

   ![iOS Templates](https://backendless.com/docs/images/shared/ios-templates.png "iOS Templates")
5. Click the Download button to download a template generated for your Backendless app
6. Unzip the downloaded file into a directory, let's call it `Project Directory`.
7. Open a Terminal window and change the currect directory to `Project Directory`.
8. Run the `pod install` and `pod update` commands. Once all of the pod data is downloaded / updated, Xcode project workspace file will be created. This is the file you must open when working on your app.
9. Open .xcworkspace file to launch your project.

## GETTING STARTED WITH COCOAPODS:
To create a new project with CocoaPods, follow the instructions below:

1. Create a new project in Xcode as you would normally, then close the project.
2. Open a Terminal window, and $ cd into your project directory.
3. Create a Podfile. This can be done by running `pod init`.
4. Open your Podfile with a text editor, and add the following
```
pod 'Backendless', '4.0b6'
```
5. Save Podfile, return to Terminal window and run `pod install`. Once all of the pod data is downloaded, Xcode project workspace file will be created. This is the file you must open when working on your app.
6. Open .xcworkspace file to launch your project.
7. If you use Swift, it is necessary to add a bridging header file. Navigate to "Build Settings -> Swift Compiler ... -> Objective-C Bridgeing Header" and add the following:
`${PODS_ROOT}/Headers/Public/Backendless/Backendless-Bridging-Header.h`

## RELEASE HISTORY
4.0b6 April 28, 2017
* Bug fixes

4.0b5 April 28, 2017
* Bug fixes

4.0b4 April 25, 2017
* Fixed "Table with the name BackendlessUser does not exist." when using Data service API to query the Users table
* Fixed and cleaned up register device methods in Messaging
* Removed unregister device methods with IResponder
* Cleaned up Subscribe methods in Messaging
* Removed cancel subscription method with the IResponder argument
* Removed send email methods with the IResponder argument
* Removed file upload methods from FileService class (the methods are replaced by the "saveFile" methods)
* Removed save file methods with the IResponder argument
* Removed rename file methods with the IResponder argument
* Removed copy file methods with the IResponder argument
* Removed move file methods with the IResponder argument
* Removed listing methods with the IResponder argument
* Removed get file count methods with the IResponder argument
* Removed exists method with the IResponder argument
* Removed remove file by URL method with the IResponder argument
* Removed remove directory by URL method with the IResponder argument
* Removed all methods with the IResponder argument from FilePermission class
* Fixed getEntityName method to get it to work correctly with BackendlessUser

4.0b3 April 7, 2017
* Removed easy login for Facebook and Google
* Removed signatures with IResponder for all methods in User Service
* Removed the assignRole/unassignRole methods - they must be invoked only from the server-code

4.0b2 March 31, 2017
* Removed asynchronous methods with IResponder from Data Service API
* Removed synchronous methods accepting Fault argument from Data Service API
* Removed BackendlessCollection from all methods

4.0b1 March 22, 2017
* Initial release
