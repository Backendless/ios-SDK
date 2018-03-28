# RELEASE HISTORY

## 4.0.27 March 28, 2018
* UserSevice fixed to work correctly with BackendlessUserAdapter

## 4.0.26 March 27, 2018
* Adapters error handling fixed

## 4.0.25 March 27, 2018
* BackendlessUser adaptation fixed

## 4.0.24 March 20, 2018
* BackendlessUser adaptation for ArrayType fixed

## 4.0.23 March 14, 2018
* BackendlessUser adaptation incorrect type mapping fixed

## 4.0.22 March 13, 2018
* BackendlessUser adaptation fixed for DataStoreFactory

## 4.0.21 February 20, 2018
* The mapColumnToProperty method added
* The findById method changed to take only NSString objectId
* The sendEmail method signature of the MessagingService changed to return MessageStatus
* The remove method of DataStoreFactory fixed and returns fault when trying to access the table that doesn't exist
* Sync methods of MapDrivenDataStore and DataStoreFactory fixed to return fault correctly

## 4.0.20 December 7, 2017
* The updateBulk and removeBulk methods added to the IDataStore
* Aggregate functions added

## 4.0.19 November 28, 2017
* Removed easy Twitter login methods. Please use TwitterKit instead
* Removed the BEReachability class, MediaService and Safari references
* Build for iOS and macOS

## 4.0.18 November 13, 2017
* The loginWithTwitterSDK sync and async methods added to the UserService class

## 4.0.17 November 8, 2017
* Fixed the logout bug when "Users" table is mapped to the BackendlessUser class

## 4.0.16 October 6, 2017
* The deviceRegistration (sync/async) methods bug with the default channel fixed
* The BackendlessPushHelper class created to process mutable content
* The publishPolicy method's bug when publishPolicy is not set fixed
* The deliveryOptionsForNotification:(PublishPolicyEnum)pushPolice method removed
* The bug when relationsDepth is not set for the find methods with query builder fixed

## 4.0.15 September 26, 2017
* Fixed bug when subscription response returned NSArray of Dictionaries, not NSArray of Messages

## 4.0.14 September 22, 2017
* Bug fixes

## 4.0.13 September 21, 2017
* The findFirst (sync/async) method bug with classMapping fixed
* The findLast (sync/async) method bug with classMapping fixed

## 4.0.12 September 20, 2017
* Xcode 9 compatibility
* Warnings fixed

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
