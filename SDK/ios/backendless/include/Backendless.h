//
//  Backendless.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 * 
 *  ********************************************************************************************************************
 *  
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
 *  
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *  
 *  ********************************************************************************************************************
 */

//version activations
#define BACKENDLESS_VERSION_2_1_0 0

// applications & services deployment
#define OLD_ASYNC_WITH_FAULT 0
#define OLD_MEDIA_APP 0
#define TEST_MEDIA_INSTANCE 0
#define AS_IDENTIFIER_MANAGER_ON 0

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#if AS_IDENTIFIER_MANAGER_ON
#import <AdSupport/AdSupport.h>
#endif
#endif

// CommLibiOS
#import "DEBUG.h"
#import "Types.h"
#import "Responder.h"
#import "AMFSerializer.h"
#import "BinaryCodec.h"

//UI
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import "BEMapView.h"
#import "BETableView.h"
#import "BECollectionView.h"
#endif

// backendless
#import "HashMap.h"
#import "AbstractProperty.h"
#import "BackendlessUser.h"
#import "UserProperty.h"
#import "UserService.h"
#import "ObjectProperty.h"
#import "BackendlessEntity.h"
#import "QueryOptions.h"
#import "BackendlessDataQuery.h"
#import "ProtectedBackendlessGeoQuery.h"
#import "BackendlessCollection.h"
#import "IDataStore.h"
#import "DataStoreFactory.h"
#import "PersistenceService.h"
#import "GeoPoint.h"
#import "GeoCluster.h"
#import "GeoCategory.h"
#import "BackendlessGeoQuery.h"
#import "GeoService.h"
#import "ICallback.h"
#import "GeoFence.h"
#import "LocationTracker.h"
#import "Message.h"
#import "MessageStatus.h"
#import "DeliveryOptions.h"
#import "PublishOptions.h"
#import "SubscriptionOptions.h"
#import "BESubscription.h"
#import "DeviceRegistration.h"
#import "MessagingService.h"
#import "FileService.h"
#import "BackendlessFile.h"
#import "CustomService.h"
#import "Events.h"
#import "CacheService.h"
#import "AtomicCounters.h"
#import "DataPermission.h"
#import "FilePermission.h"
#import "Logging.h"
#import "Logger.h"
#import "BackendlessSimpleQuery.h"
#import "BEFileInfo.h"
#import "IPresenceListener.h"
#import "BackendlessBeacon.h"
#import "Presence.h"


//Cache
#import "BackendlessCachePolicy.h"
#import "AbstractQuery.h"


/*******************************************************************************************************************
 * Backendless singleton accessor: this is how you should ALWAYS get a reference to the Backendless class instance *
 *******************************************************************************************************************/
#define backendless [Backendless sharedInstance]

// BackendlessAppConf.plist keys
#define BACKENDLESS_APP_CONF @"BackendlessAppConf"
#define BACKENDLESS_APP_ID @"AppId"
#define BACKENDLESS_SECRET_KEY @"SecretKey"
#define BACKENDLESS_VERSION_NUM @"VersionNum"
#define BACKENDLESS_DEBLOG_ON @"DebLogOn"

@class MediaService;

@protocol ReachabilityDelegate <NSObject>
-(void)changeNetworkStatus:(NSInteger)status connectionRequired:(BOOL)connectionRequired;
@end

@interface Backendless : NSObject
// context
@property (strong, nonatomic, getter = getHostUrl, setter = setHostUrl:) NSString *hostURL;
@property (strong, nonatomic, getter = getAppId, setter = setAppId:) NSString *appID;
@property (strong, nonatomic, getter = getSecretKey, setter = setSecretKey:) NSString *secretKey;
@property (strong, nonatomic, getter = getVersionNum, setter = setVersionNum:) NSString *versionNum;
@property (strong, nonatomic, getter = getApiVersion, setter = setApiVersion:) NSString *apiVersion;
// options
@property (strong, nonatomic) NSMutableDictionary *headers;
@property (strong, nonatomic, readonly) NSDictionary *appConf;
// services
@property (strong, nonatomic, readonly) UserService *userService;
@property (strong, nonatomic, readonly) PersistenceService *persistenceService;
@property (strong, nonatomic, readonly) GeoService *geoService;
@property (strong, nonatomic, readonly) MessagingService *messagingService;
@property (strong, nonatomic, readonly) FileService *fileService;
@property (strong, nonatomic, readwrite) MediaService *mediaService;
@property (strong, nonatomic, readonly) CustomService *customService;
@property (strong, nonatomic, readonly) Events *events;
@property (strong, nonatomic, readonly) CacheService *cache;
@property (strong, nonatomic, readonly) AtomicCounters *counters;
@property (strong, nonatomic, readonly) Logging *logging;
// service shortcuts
@property (assign, nonatomic, readonly) PersistenceService *data;
@property (assign, nonatomic, readonly) GeoService *geo;
@property (assign, nonatomic, readonly) MessagingService *messaging;
@property (assign, nonatomic, readonly) FileService *file;
// delegates
@property (strong, nonatomic) id <ReachabilityDelegate> reachabilityDelegate;

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(Backendless *)sharedInstance;

/**
 * Initializes the Backendless class and all Backendless dependencies.
 * This is the first step in using the client API.
 *
 * @param appId      a Backendless application ID, which could be retrieved at the Backendless console
 * @param secretKey  a Backendless application secret key, which could be retrieved at the Backendless console
 * @param versionNum identifies the version of the application. A version represents a snapshot of the configuration settings, set of schemas, user properties, etc.
 */
-(void)initApp:(NSString *)applicationID secret:(NSString *)secret version:(NSString *)version;
-(void)initApp:(NSString *)plist;
-(void)initApp;
-(void)initAppFault;
-(NSString *)mediaServerUrl;
#pragma mark - exceptions management
-(void)setThrowException:(BOOL)needThrow;
-(id)throwFault:(Fault *)fault;
#pragma mark - utils
-(NSString *)GUIDString;
-(NSString *)randomString:(int)numCharacters;
-(NSString *)applicationType;
-(void)setUIState:(NSString *)uiState;
-(NSString *)getUIState;
#pragma mark - cache methods
-(void)clearAllCache;
-(void)clearCacheForClassName:(NSString *)className query:(id) query;
-(BOOL)hasResultForClassName:(NSString *)className query:(id) query;
-(void)setCachePolicy:(BackendlessCachePolicy *)policy;
-(void)setCacheStoredType:(BackendlessCacheStoredEnum)storedType;
-(void)saveCache;
#pragma mark - connection
-(NSInteger)getConnectionStatus;
#pragma mark - offline mode
-(void)setOfflineMode:(BOOL)offlineMode;

@end
