# RELEASE HISTORY

## 4.0.12 September 20, 2017
* Xcode 9 compatibility, warnings fixed

## 4.0.11 September 18, 2017
* Bug fixes

## 4.0.10 September 7, 2017
* Bug fixes

## 4.0.9 September 7, 2017
* Fixed relationsDepth bug when it is not specified

## 4.0.8 September 6, 2017
* The LoadRelationsQueryBuilder class updated to support dictionary/map approach

## 4.0.7 September 4, 2017
* ARC enabled for the LoadRelationsQueryBuilder class

## 4.0.6 August 10, 2017
* Added the "mutable-content" support for push notifications

## 4.0.5 August 4, 2017
* The user registration bug when adding to users one after another fixed
* NSNull values changed to nil for dictionary/map approach

## 4.0.4 July 26, 2017
* The error when SDK don't send user token header to the server fixed

## 4.0.3 July 24, 2017
* The autoload relation loading fixed for the basic find method

## 4.0.2 July 18, 2017
* The mapTableToClass method fixed

## 4.0.1 July 5, 2017
* 4.0 release

## 4.0b14 June 30, 2017
* User registration fixed (method for a Dictionary is used instead of one for BackendlessUser class fixed)

## 4.0b13 June 23, 2017
* The findById method called in UserService returns BackendlessUser

## 4.0b12 June 21, 2017
* PushPolicyEnum changed to PublishPolicyEnum and now supports the PUSH, PUBSUB and BOTH delivery options

## 4.0b11 June 16, 2017
* Removed version from hosted service invocation

## 4.0b10 June 14, 2017
* Pub/Sub problems fixed

## 4.0b9 June 8, 2017
* sid parameter changed to objectId in the PersistenceService class methods
* SDK cleanup

## 4.0b8 May 22, 2017
* Restored removeById method in IDataStore
* IDataStore, MapDrivenDataStore, DataStoreFactory and PersistenceService cleanup

## 4.0b7 May 19, 2017
* RegisterDevice now returns deviceId instead of registrationId
* Geolocation API cleanup - removed methods with the IResponder (async) and Fault (sync) arguments
* Removed AppDelegate methods from LocationTracker
* Caching API cleanup - removed methods with the IResponder (async) and Fault (sync) arguments
* Atomic Counters API cleanup - removed methods with the IResponder (async) and Fault (sync) arguments
* Fixed warnings in the library build

## 4.0b6 April 28, 2017
* Fixed problem with MessagingService.m reported as an excluded class in a build for a device
* Made changes in BackendlessUser so that it is represented as a dictionary in the dictionary-based data retrieval

## 4.0b5 April 28, 2017
* Bug fixes

## 4.0b4 April 25, 2017
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

## 4.0b3 April 7, 2017
* Removed easy login for Facebook and Google
* Removed signatures with IResponder for all methods in User Service
* Removed the assignRole/unassignRole methods - they must be invoked only from the server-code

## 4.0b2 March 31, 2017
* Removed asynchronous methods with IResponder from Data Service API
* Removed synchronous methods accepting Fault argument from Data Service API
* Removed BackendlessCollection from all methods

## 4.0b1 March 22, 2017
* Initial release
