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
 *  Copyright 2017 BACKENDLESS.COM. All Rights Reserved.
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
#import "Message.h"
#import "CommandObject.h"
#import "UserStatusObject.h"

@interface RTMessaging : RTListener

-(RTMessaging *)initWithChannelName:(NSString *)channelName;

-(void)connect:(void(^)(id))onSuccessfulConnect;

-(void)addErrorListener:(void(^)(Fault *))errorBlock;
-(void)removeErrorListener:(void(^)(Fault *))errorBlock;

-(void)addConnectListener:(BOOL)isConnected onConnect:(void(^)(void))onConnect;
-(void)removeConnectListener:(void(^)(void))onConnect;

-(void)addMessageListener:(NSString *)selector onMessage:(void(^)(Message *))onMessage;
-(void)removeMessageListener:(NSString *)selector onMessage:(void(^)(Message *))onMessage;

-(void)addCommandListener:(void(^)(CommandObject *))onCommand;
-(void)removeCommandListener:(void(^)(CommandObject *))onCommand;

-(void)addUserStatusListener:(void(^)(UserStatusObject *))onUserStatus;
-(void)removeUserStatusListener:(void(^)(UserStatusObject *))onUserStatus;

@end
