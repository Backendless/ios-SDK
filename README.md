Backendless SDK for iOS (http://backendless.com)
---

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
4. Open your Podfile with a text editor, and add the following for iOS:
```
pod 'Backendless'
```
for macOS:
```
pod 'Backendless-osx-SDK'
```
5. Save Podfile, return to Terminal window and run `pod install` and `pod update`. Once all of the pod data is downloaded/updated, Xcode project workspace file will be created. This is the file you must open when working on your app.
6. Open .xcworkspace file to launch your project.
7. If you use Swift, it is necessary to add a bridging header file. Navigate to "Build Settings -> Swift Compiler ... -> Objective-C Bridging Header" and add the following for iOS:
```
${PODS_ROOT}/Headers/Public/Backendless/Backendless-Bridging-Header.h
```
for macOS:
```
${PODS_ROOT}/Headers/Public/Backendless-osx-SDK/Backendless-Bridging-Header.h
```
