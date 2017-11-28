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

// implementation options
#import <Foundation/Foundation.h>
#import "DEBUG.h"
#import "Types.h"
#import "Responder.h"
#import "AMFSerializer.h"
#import "BinaryCodec.h"
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
#import "BackendlessPushHelper.h"
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
#import "MapDrivenDataStore.h"

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
#define BACKENDLESS_API_KEY @"APIKey"
#define BACKENDLESS_DEBLOG_ON @"DebLogOn"

@interface Backendless : NSObject
// context
@property (strong, nonatomic, getter = getHostUrl, setter = setHostUrl:) NSString *hostURL;
@property (strong, nonatomic, getter = getAppId, setter = setAppId:) NSString *appID;
@property (strong, nonatomic, getter = getAPIKey, setter = setAPIKey:) NSString *apiKey;
// options
@property (strong, nonatomic) NSMutableDictionary *headers;
@property (strong, nonatomic, readonly) NSDictionary *appConf;
// services
@property (strong, nonatomic, readonly) UserService *userService;
@property (strong, nonatomic, readonly) PersistenceService *persistenceService;
@property (strong, nonatomic, readonly) GeoService *geoService;
@property (strong, nonatomic, readonly) MessagingService *messagingService;
@property (strong, nonatomic, readonly) FileService *fileService;
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

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(Backendless *)sharedInstance;
/**
 * Initializes the Backendless class and all Backendless dependencies.
 * This is the first step in using the client API.
 *
 @param applicationId a Backendless application ID, which could be retrieved at the Backendless console
 @param apiKey a Backendless application API key, which could be retrieved at the Backendless console
 */
-(void)initApp:(NSString *)applicationId APIKey:(NSString *)apiKey;
-(void)initApp:(NSString *)plist;
-(void)initApp;
-(void)initAppFault;
#pragma mark - exceptions management
-(void)setThrowException:(BOOL)needThrow;
-(id)throwFault:(Fault *)fault;
#pragma mark - utils
-(NSString *)GUIDString;
-(NSString *)randomString:(int)numCharacters;
-(NSString *)applicationType;
#pragma mark - cache methods
-(void)clearAllCache;
-(void)clearCacheForClassName:(NSString *)className query:(id) query;
-(BOOL)hasResultForClassName:(NSString *)className query:(id) query;
-(void)setCachePolicy:(BackendlessCachePolicy *)policy;
-(void)setCacheStoredType:(BackendlessCacheStoredEnum)storedType;
-(void)saveCache;
#pragma mark - hardware
-(BOOL)is64bitSimulator;
-(BOOL)is64bitHardware;
@end
