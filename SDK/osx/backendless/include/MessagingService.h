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
#import "RTMessaging.h"

@class UIUserNotificationCategory;
@class MessageStatus, PublishOptions, DeliveryOptions, Channel, SharedObject, BodyParts, Message, Fault;

@interface MessagingService : NSObject
@property (strong, nonatomic, readonly) HashMap *subscriptions;

// Channel
-(Channel *)subscribe:(NSString *)channelName;

// sync methods with fault return (as exception)
-(NSString *)registerDevice:(NSData *)deviceToken;
-(NSString *)registerDevice:(NSData *)deviceToken channels:(NSArray<NSString *> *)channels;
-(NSString *)registerDevice:(NSData *)deviceToken expiration:(NSDate *)expiration;
-(NSString *)registerDevice:(NSData *)deviceToken channels:(NSArray<NSString *> *)channels expiration:(NSDate *)expiration;
-(DeviceRegistration *)getRegistration:(NSString *)deviceId;
-(id)unregisterDevice;
-(id)unregisterDevice:(NSString *)deviceId;
-(MessageStatus *)publish:(NSString *)channelName message:(id)message;
-(MessageStatus *)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions;
-(MessageStatus *)publish:(NSString *)channelName message:(id)message deliveryOptions:(DeliveryOptions *)deliveryOptions;
-(MessageStatus *)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions deliveryOptions:(DeliveryOptions *)deliveryOptions;
-(id)cancel:(NSString *)messageId;
-(id)sendTextEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients;
-(id)sendHTMLEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients;
-(id)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients;
-(id)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients attachment:(NSArray *)attachments;
-(MessageStatus *)getMessageStatus:(NSString*)messageId;

// async methods with block-based callbacks
-(void)registerDevice:(NSData *)deviceToken response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)registerDevice:(NSData *)deviceToken channels:(NSArray<NSString *> *)channels response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)registerDevice:(NSData *)deviceToken expiration:(NSDate *)expiration response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)registerDevice:(NSData *)deviceToken channels:(NSArray<NSString *> *)channels expiration:(NSDate *)expiration response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getRegistration:(NSString *)deviceId response:(void(^)(DeviceRegistration *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)unregisterDevice:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)unregisterDevice:(NSString *)deviceId response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)publish:(NSString *)channelName message:(id)message response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)publish:(NSString *)channelName message:(id)message deliveryOptions:(DeliveryOptions *)deliveryOptions response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions deliveryOptions:(DeliveryOptions *)deliveryOptions response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)cancel:(NSString *)messageId response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)sendTextEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)sendHTMLEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients attachment:(NSArray *)attachments response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getMessageStatus:(NSString*)messageId response:(void(^)(MessageStatus*))responseBlock error:(void(^)(Fault *))errorBlock;

// utilites
-(DeviceRegistration *)currentDevice;
-(NSString *)deviceTokenAsString:(NSData *)token;

// commands
-(void)sendCommand:(NSString *)commandType channelName:(NSString *)channelName data:(id)data onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError;

@end
