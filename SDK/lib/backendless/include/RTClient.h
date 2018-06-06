//
//  RTClient.h
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
@class RTSubscription;
@class RTMethodRequest;

#define rtClient [RTClient sharedInstance]

#define CONNECT_EVENT @"CONNECT_EVENT"
#define CONNECT_ERROR_EVENT @"CONNECT_ERROR_EVENT"
#define DISCONNECT_EVENT @"DISCONNECT_EVENT"
#define RECONNECT_ATTEMPT_EVENT @"RECONNECT_ATTEMPT_EVENT"

@interface RTClient : NSObject

+(instancetype)sharedInstance;
-(void)subscribe:(NSDictionary *)data subscription:(RTSubscription *)subscription;
-(void)unsubscribe:(NSString *)subscriptionId;
-(void)sendCommand:(id)data method:(RTMethodRequest *)method;
-(void)userLoggedInWithToken:(NSString *)userToken;

// Native Socket.io events
-(void)addConnectEventListener:(void(^)(void))onConnect;
-(void)removeConnectEventListeners:(void(^)(void))onConnect;

-(void)addEventListener:(NSString *)type callBack:(void(^)(id))callback;
-(void)removeEventListeners:(NSString *)type callBack:(void(^)(id))callback;

-(void)removeEventListeners:(NSString *)type;

@end

