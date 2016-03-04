//
//  MessagingService.h
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

#import <Foundation/Foundation.h>
#import "HashMap.h"
#import "DeviceRegistration.h"

#define DEVICE_TOKEN_AS_STRING 0

#define MESSAGE_TAG @"message"

#define IOS_ALERT_TAG @"ios-alert"
#define IOS_BADGE_TAG @"ios-badge"
#define String IOS_SOUND_TAG @"ios-sound"

#define ANDROID_TICKER_TEXT_TAG @"android-ticker-text"
#define ANDROID_CONTENT_TITLE_TAG @"android-content-title"
#define ANDROID_CONTENT_TEXT_TAG @"android-content-text"
#define ANDROID_ACTION_TAG @"android-action"

#define WP_TYPE_TAG @"wp-type"
#define WP_TITLE_TAG @"wp-title"
#define WP_TOAST_SUBTITLE_TAG @"wp-subtitle"
#define WP_TOAST_PARAMETER_TAG @"wp-parameter"
#define WP_TILE_BACKGROUND_IMAGE @"wp-backgroundImage"
#define WP_TILE_COUNT @"wp-count"
#define WP_TILE_BACK_TITLE @"wp-backTitle"
#define WP_TILE_BACK_BACKGROUND_IMAGE @"wp-backImage"
#define WP_TILE_BACK_CONTENT @"wp-backContent"
#define WP_RAW_DATA @"wp-raw"

@class MessageStatus, PublishOptions, DeliveryOptions, SubscriptionOptions, BESubscription, BodyParts, Message, Fault;
@protocol IResponder;

@protocol IBEPushReceiver <NSObject>
@optional
-(void)didReceiveRemoteNotification:(NSString *)notification headers:(NSDictionary *)headers;
-(void)didRegisterForRemoteNotificationsWithDeviceId:(NSString *)deviceId fault:(Fault *)fault;
-(void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)err;
-(void)applicationWillTerminate;
@end

@interface MessagingService : NSObject
@property (nonatomic) uint pollingFrequencyMs;
@property (strong, nonatomic, readonly) HashMap *subscriptions;
@property (assign, nonatomic) id <IBEPushReceiver> pushReceiver;
@property NSUInteger notificationTypes;

// sync methods with fault return (as exception)
#if DEVICE_TOKEN_AS_STRING
-(NSString *)registerDevice:(NSArray<NSString*> *)channels expiration:(NSDate *)expiration token:(NSString *)deviceToken;
-(NSString *)registerDeviceToken:(NSString *)deviceToken;
-(NSString *)registerDeviceWithTokenData:(NSData *)deviceToken;
#else
-(NSString *)registerDevice:(NSArray<NSString*> *)channels expiration:(NSDate *)expiration token:(NSData *)deviceToken;
-(NSString *)registerDeviceToken:(NSData *)deviceToken;
#endif
-(NSString *)registerDeviceExpiration:(NSDate *)expiration;
-(NSString *)registerDevice:(NSArray<NSString*> *)channels;
-(NSString *)registerDevice:(NSArray<NSString*> *)channels expiration:(NSDate *)expiration;
-(NSString *)registerDevice;
-(DeviceRegistration *)getRegistration;
-(DeviceRegistration *)getRegistration:(NSString *)deviceId;
-(id)unregisterDevice;
-(id)unregisterDevice:(NSString *)deviceId;
-(MessageStatus *)publish:(NSString *)channelName message:(id)message;
-(MessageStatus *)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions;
-(MessageStatus *)publish:(NSString *)channelName message:(id)message deliveryOptions:(DeliveryOptions *)deliveryOptions;
-(MessageStatus *)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions deliveryOptions:(DeliveryOptions *)deliveryOptions;
-(id)cancel:(NSString *)messageId;
-(BESubscription *)subscribe:(NSString *)channelName;
-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponder:(id <IResponder>)subscriptionResponder;
-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponder:(id <IResponder>)subscriptionResponder subscriptionOptions:(SubscriptionOptions *)subscriptionOptions;
-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray<Message*> *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock;
-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray<Message*> *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock subscriptionOptions:(SubscriptionOptions *)subscriptionOptions;
-(BESubscription *)subscribe:(BESubscription *)subscription subscriptionOptions:(SubscriptionOptions *)subscriptionOptions;
-(NSArray *)pollMessages:(NSString *)channelName subscriptionId:(NSString *)subscriptionId;
//
-(id)sendTextEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients;
-(id)sendHTMLEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients;
-(id)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients;
-(id)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients attachment:(NSArray *)attachments;

// sync methods with fault option
#if DEVICE_TOKEN_AS_STRING
-(NSString *)registerDevice:(NSArray<NSString*> *)channels expiration:(NSDate *)expiration token:(NSString *)deviceToken error:(Fault **)fault;
-(NSString *)registerDeviceToken:(NSString *)deviceToken error:(Fault **)fault;
-(NSString *)registerDeviceWithTokenData:(NSData *)deviceToken error:(Fault **)fault;
#else
-(NSString *)registerDevice:(NSArray<NSString*> *)channels expiration:(NSDate *)expiration token:(NSData *)deviceToken error:(Fault **)fault;
-(NSString *)registerDeviceToken:(NSData *)deviceToken error:(Fault **)fault;
#endif
-(NSString *)registerDeviceExpiration:(NSDate *)expiration error:(Fault **)fault;
-(NSString *)registerDevice:(NSArray<NSString*> *)channels error:(Fault **)fault;
-(NSString *)registerDevice:(NSArray<NSString*> *)channels expiration:(NSDate *)expiration error:(Fault **)fault;
-(NSString *)registerDeviceError:(Fault **)fault;
-(DeviceRegistration *)getRegistrationError:(Fault **)fault;
-(DeviceRegistration *)getRegistration:(NSString *)deviceId error:(Fault **)fault;
-(BOOL)unregisterDeviceError:(Fault **)fault;
-(BOOL)unregisterDevice:(NSString *)deviceId error:(Fault **)fault;
-(MessageStatus *)publish:(NSString *)channelName message:(id)message error:(Fault **)fault;
-(MessageStatus *)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions error:(Fault **)fault;
-(MessageStatus *)publish:(NSString *)channelName message:(id)message deliveryOptions:(DeliveryOptions *)deliveryOptions error:(Fault **)fault;
-(MessageStatus *)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions deliveryOptions:(DeliveryOptions *)deliveryOptions error:(Fault **)fault;
-(BOOL)cancel:(NSString *)messageId error:(Fault **)fault;
-(BESubscription *)subscribe:(NSString *)channelName error:(Fault **)fault;
-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponder:(id <IResponder>)subscriptionResponder error:(Fault **)fault;
-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponder:(id <IResponder>)subscriptionResponder subscriptionOptions:(SubscriptionOptions *)subscriptionOptions error:(Fault **)fault;
-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray<Message*> *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock error:(Fault **)fault;
-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray<Message*> *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock subscriptionOptions:(SubscriptionOptions *)subscriptionOptions error:(Fault **)fault;
-(BESubscription *)subscribe:(BESubscription *)subscription subscriptionOptions:(SubscriptionOptions *)subscriptionOptions error:(Fault **)fault;
-(NSArray *)pollMessages:(NSString *)channelName subscriptionId:(NSString *)subscriptionId error:(Fault **)fault;
//
-(BOOL)sendTextEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients error:(Fault **)fault;
-(BOOL)sendHTMLEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients error:(Fault **)fault;
-(BOOL)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients error:(Fault **)fault;
-(BOOL)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients attachment:(NSArray *)attachments error:(Fault **)fault;

// async methods with responder
#if DEVICE_TOKEN_AS_STRING
-(void)registerDevice:(NSArray<NSString*> *)channels expiration:(NSDate *)expiration token:(NSString *)deviceToken responder:(id <IResponder>)responder;
-(void)registerDeviceToken:(NSString *)deviceToken responder:(id <IResponder>)responder;
-(void)registerDeviceWithTokenData:(NSData *)deviceToken responder:(id <IResponder>)responder;
#else
-(void)registerDevice:(NSArray<NSString*> *)channels expiration:(NSDate *)expiration token:(NSData *)deviceToken responder:(id <IResponder>)responder;
-(void)registerDeviceToken:(NSData *)deviceToken responder:(id <IResponder>)responder;
#endif
-(void)registerDeviceExpiration:(NSDate *)expiration responder:(id <IResponder>)responder;
-(void)registerDevice:(NSArray<NSString*> *)channels responder:(id <IResponder>)responder;
-(void)registerDevice:(NSArray<NSString*> *)channels expiration:(NSDate *)expiration responder:(id <IResponder>)responder;
-(void)registerDeviceAsync:(id <IResponder>)responder;
-(void)getRegistrationAsync:(id<IResponder>)responder;
-(void)getRegistrationAsync:(NSString *)deviceId responder:(id<IResponder>)responder;
-(void)unregisterDeviceAsync:(id<IResponder>)responder;
-(void)unregisterDeviceAsync:(NSString *)deviceId responder:(id<IResponder>)responder;
-(void)publish:(NSString *)channelName message:(id)message responder:(id <IResponder>)responder;
-(void)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions responder:(id <IResponder>)responder;
-(void)publish:(NSString *)channelName message:(id)message deliveryOptions:(DeliveryOptions *)deliveryOptions responder:(id <IResponder>)responder;
-(void)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions deliveryOptions:(DeliveryOptions *)deliveryOptions responder:(id <IResponder>)responder;
-(void)cancel:(NSString *)messageId responder:(id <IResponder>)responder;
-(void)subscribe:(NSString *)channelName responder:(id <IResponder>)responder;
-(void)subscribe:(NSString *)channelName subscriptionResponder:(id <IResponder>)subscriptionResponder responder:(id <IResponder>)responder;
-(void)subscribe:(NSString *)channelName subscriptionResponder:(id <IResponder>)subscriptionResponder subscriptionOptions:(SubscriptionOptions *)subscriptionOptions responder:(id <IResponder>)responder;
-(void)subscribe:(BESubscription *)subscription subscriptionOptions:(SubscriptionOptions *)subscriptionOptions responder:(id <IResponder>)responder;
-(void)pollMessages:(NSString *)channelName subscriptionId:(NSString *)subscriptionId responder:(id <IResponder>)responder;
//
-(void)sendTextEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients responder:(id <IResponder>)responder;
-(void)sendHTMLEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients responder:(id <IResponder>)responder;
-(void)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients responder:(id <IResponder>)responder;
-(void)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients attachment:(NSArray *)attachments responder:(id <IResponder>)responder;

// async methods with block-based callbacks
#if DEVICE_TOKEN_AS_STRING
-(void)registerDevice:(NSArray<NSString*> *)channels expiration:(NSDate *)expiration token:(NSString *)deviceToken response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)registerDeviceToken:(NSString *)deviceToken response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)registerDeviceWithTokenData:(NSData *)deviceToken response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock;
#else
-(void)registerDevice:(NSArray<NSString*> *)channels expiration:(NSDate *)expiration token:(NSData *)deviceToken response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)registerDeviceToken:(NSData *)deviceToken response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock;
#endif
-(void)registerDeviceExpiration:(NSDate *)expiration response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)registerDevice:(NSArray<NSString*> *)channels response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)registerDevice:(NSArray<NSString*> *)channels expiration:(NSDate *)expiration response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)registerDeviceAsync:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getRegistrationAsync:(void(^)(DeviceRegistration *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getRegistrationAsync:(NSString *)deviceId response:(void(^)(DeviceRegistration *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)unregisterDeviceAsync:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)unregisterDeviceAsync:(NSString *)deviceId response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)publish:(NSString *)channelName message:(id)message response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)publish:(NSString *)channelName message:(id)message deliveryOptions:(DeliveryOptions *)deliveryOptions response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions deliveryOptions:(DeliveryOptions *)deliveryOptions response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)cancel:(NSString *)messageId response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)subscribe:(NSString *)channelName response:(void(^)(BESubscription *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray<Message*> *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock response:(void(^)(BESubscription *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray<Message*> *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock subscriptionOptions:(SubscriptionOptions *)subscriptionOptions response:(void(^)(BESubscription *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)subscribe:(BESubscription *)subscription subscriptionOptions:(SubscriptionOptions *)subscriptionOptions response:(void(^)(BESubscription *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)pollMessages:(NSString *)channelName subscriptionId:(NSString *)subscriptionId response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
//
-(void)sendTextEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)sendHTMLEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients attachment:(NSArray *)attachments response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;

// utilites
-(DeviceRegistration *)currentDevice;
-(NSString *)deviceTokenAsString:(NSData *)token;

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
-(void)registerForRemoteNotifications;
-(void)unregisterFromRemoteNotifications;
// the methods for AppDelegate using for push publish & push pub/sub (SubscriptionOptions.deliveryMethod = DELIVERY_PUSH)
-(void)registerForPushPubSub;
-(void)unregisterFromPushPubSub;
// invoke it in -(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
-(void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
// invoke it in -(void)applicationWillTerminate:(UIApplication *)application
-(void)applicationWillTerminate;
// invoke it in - (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
-(void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;
// invoke it in - (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
-(void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)err;
// invoke it in:
// - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
// -(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

// start up register device methods
-(void)startupRegisterDeviceWithExpiration:(NSDate *)expiration;
-(void)startupRegisterDeviceWithChannels:(NSArray<NSString*> *)channels;
-(void)startupRegisterDevice:(NSArray<NSString*> *)channels expiration:(NSDate *)expiration;
#endif

@end
