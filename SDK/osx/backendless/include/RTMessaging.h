//
//  RTMessaging.h
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
#import "RTListener.h"
#import "Responder.h"
#import "PublishMessageInfo.h"
#import "CommandObject.h"
#import "UserStatusObject.h"
#import "Channel.h"

@interface RTMessaging : RTListener

-(instancetype)initWithChannel:(Channel *)channel;
-(void)connect:(void(^)(id))onSuccessfulConnect onError:(void(^)(Fault *))onError ;

-(void)addJoinListener:(BOOL)isConnected response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeJoinListeners;

-(void)addMessageListener:(NSString *)selector response:(void(^)(PublishMessageInfo *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeMessageListeners:(NSString *)selector;

-(void)addCommandListener:(void(^)(CommandObject *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeCommandListeners;

-(void)addUserStatusListener:(void(^)(UserStatusObject *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeUserStatusListeners;

@end
