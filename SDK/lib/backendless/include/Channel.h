//
//  Channel.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
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
#import "Responder.h"
#import "PublishMessageInfo.h"
#import "CommandObject.h"
#import "UserStatusObject.h"

@interface Channel : NSObject

@property (strong, nonatomic, readonly) NSString *channelName;
@property (nonatomic) BOOL isJoined;

-(instancetype)initWithChannelName:(NSString *)channelName;
-(void)join;
-(void)leave;

-(void)addJoinListener:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeJoinListeners;

-(void)addMessageListenerString:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addMessageListenerString:(NSString *)selector response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock;

-(void)addMessageListenerDictionary:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addMessageListenerDictionary:(NSString *)selector response:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock;

-(void)addMessageListenerCustomObject:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock class:(Class)classType;
-(void)addMessageListenerCustomObject:(NSString *)selector response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock class:(Class)classType;

-(void)addMessageListener:(void(^)(PublishMessageInfo *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addMessageListener:(NSString *)selector response:(void(^)(PublishMessageInfo *))responseBlock error:(void(^)(Fault *))errorBlock;

-(void)removeMessageListeners:(NSString *)selector;
-(void)removeMessageListeners;

-(void)addCommandListener:(void(^)(CommandObject *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeCommandListeners;

-(void)addUserStatusListener:(void(^)(UserStatusObject *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeUserStatusListeners;

-(void)removeAllListeners;

@end
