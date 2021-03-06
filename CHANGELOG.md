# RELEASE HISTORY

## 5.6.0-deprecated November 27, 2019
iOS-SDK is now deprecated and won't be updated with upcoming features.
Please use [Backendless Swift-SDK ](https://github.com/Backendless/Swift-SDK) instead.

[Backendless Swift-SDK on Cocoapods.](https://cocoapods.org/pods/BackendlessSwift)
[Backendless Swift-SDK Documentation](https://backendless.com/docs/ios/) 

## 5.6.0 November 15, 2019
* added methods to the DataQueryBuilder:
```
-(NSNumber *)getRelationsPageSize;

-(instancetype)setRelationsPageSize:(int)relationsPageSize;
```

## 5.5.0 October 8, 2019
* fixed the device registration for iOS 13 and above

## 5.4.1 August 19, 2019
* added the blUserLocale property (two character code) to the BackendlessUser object
* added methods to UserService:
```
- (void)setUserToken:(NSString *)userToken;

-(NSString *)getUserToken;

-(BackendlessUser *)loginAsGuest;

-(BackendlessUser *)loginAsGuestWithStayLoggedIn:(BOOL)stayLoggedIn;

-(void)loginAsGuest:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock;

-(void)loginAsGuestWithStayLoggedIn:(BOOL)stayLoggedIn response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock;
```

## 5.4.0 July 9, 2019
* added support of custom smart-text substitutions for push templates, the sendEmail method signatures changed:
```
-(MessageStatus *)sendEmailFromTemplate:(NSString *)templateName envelope:(EmailEnvelope *)envelope;
-(MessageStatus *)sendEmailFromTemplate:(NSString *)templateName envelope:(EmailEnvelope *)envelope templateValues:(NSDictionary<NSString *, NSString*> *)templateValues;

-(void)sendEmailFromTemplate:(NSString *)templateName envelope:(EmailEnvelope *)envelope response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)sendEmailFromTemplate:(NSString *)templateName envelope:(EmailEnvelope *)envelope templateValues:(NSDictionary<NSString *, NSString*> *)templateValues response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock;
```
* the EmailEnvelope class added:
```
@interface EmailEnvelope : NSObject

@property (strong, nonatomic) NSArray<NSString *> *to;
@property (strong, nonatomic) NSArray<NSString *> *cc;
@property (strong, nonatomic) NSArray<NSString *> *bcc;
@property (strong, nonatomic) NSString *query;

-(void)addTo:(NSArray<NSString *> *)to;
-(void)addCc:(NSArray<NSString *> *)cc;
-(void)addBcc:(NSArray<NSString *> *)bcc;

@end
```

## 5.3.8 June 11, 2019
* added classes and Protocol: EmailEnvelope, IEmailEnvelope, EnvelopeWIthQuery, EnvelopeWithRecipients
* added methods in MessagingService:
```
-(MessageStatus *)sendEmails:(NSString *)templateName envelope:(id<IEmailEnvelope>)envelope;

-(MessageStatus *)sendEmails:(NSString *)templateName templateValues:(NSDictionary<NSString *, NSString*> *)templateValues envelope:(id<IEmailEnvelope>)envelope;

-(void)sendEmails:(NSString *)templateName envelope:(id<IEmailEnvelope>)envelope response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock;

-(void)sendEmails:(NSString *)templateName templateValues:(NSDictionary<NSString *, NSString*> *)templateValues envelope:(id<IEmailEnvelope>)envelope response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock;
```
* added groups support for push notifications (for iOS 12+)

## 5.2.13 May, 13 2019
* added support of sortBy and properties for LoadRelationsQueryBuilder
* macOS device registration fixed

## 5.2.12 March, 26 2019
* podspec updated to support Socket.IO v14.0.0

## 5.2.11 March, 12 2019
* Added support for low priority tasks in CustomService and Events

## 5.2.10 February 14, 2019
* Socket.IO updated to v14.0.0

## 5.2.9 January 9, 2019
* The uploadFile methods (with http request) added to FileService

## 5.2.8 December 14, 2018
* Inline reply "textInputPlaceholder" and "inputButtonTitle" fixed when values are not set in console

## 5.2.7 December 5, 2018
* Inline reply support added
* Socket.IO updated

## 5.2.6 November 23, 2018
* Push with template method fixed to work with custom groups

## 5.2.5 November 22, 2018
* User should create app group for push templates which starts with "group.backendlesspush."

## 5.2.4 November 15, 2018
* Setting dictionary's NSNull values to nil removed because of retrieving schema definition structure
* The processAsyncAMFResponse method from HttpEngine class fixed to process response correctly when NSURLSession returns error

## 5.2.3 November 5, 2018
* Smart text for push templates fixed

## 5.2.2 November 2, 2018
* Push templates handling fixed to work correctly when adding new button options

## 5.2.1 November 1, 2018
* UserDefaultsHelper class added to the tvOS and watchOS binaries

## 5.2.0 October 30, 2018
* Push Templates support added

## 5.1.8 October 23, 2018
* DeviceRegistrationAdapter fixed to handle os and osVersion correctly

## 5.1.7 October 10, 2018
* Socket.IO updated to v 13.3.1
* isValidUserToken method fixed to hanle fault correctly when there is no internet connection

## 5.1.6 September 27, 2018
* LoadRelations method fixed to return array of dictionaries for MapDrivenDataStore

## 5.1.5 September 26, 2018
* DataQueryBuilder getPageSize and getOffset methods added

## 5.1.4 September 20, 2018
* WatchOS build fixed
* Compatible with Swift 4.2, Xcode 10

## 5.1.3 September 14, 2018
* Loading all user properties of a GeoPoint's linked user object fixed

## 5.1.2 September 5, 2018
* Socket.IO updated to v13.3.0
* Added support of return value for deleteFile methods

## 5.1.1 August 1, 2018
* The bulk create listener methods added in RT

## 5.1.0 July 8, 2018
* Issue when response returned in background thread instead of thread which it has been invoked fixed

## 5.0.6 July 2, 2018
* JSONHelper class fixed to proceed NSNull values correctly

## 5.0.5 June 28, 2018
* MessagingService class is now ARC-based
* Async unregisterDevice method fixed
* wrapResponseBlockToCustomObject method fixed

## 5.0.3 June 11, 2018
* Some deprecated NSURLConnection methods fixed. No API changes

## 5.0.2 June 8, 2018
* Socket.IO updated to v13.2.1

## 5.0.1 June 7, 2018
* pod 'Backendless' command is used for all platforms

## 5.0 June 6, 2018
* RT support added
* API changes. Please check the documentation

## 4.5.0 April 4, 2018
* Bulk create method now returns array of objectIds

## 4.0.29 April 2, 2018
* Bulk create method added
* CustomServiceAdapter fault handle fixed

## 4.0.28 March 29, 2018
* CustomServiceAdapter added
* CustomService fixed to work correctly with CustomServiceAdapter

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
