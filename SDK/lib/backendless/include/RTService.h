//
//  RTService.h
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
#import "ReconnectAttemptObject.h"

@interface RTService : NSObject

-(void)addConnectEventListener:(void(^)(void))onConnect;
-(void)removeConnectEventListeners:(void(^)(void))onConnect;
-(void)removeConnectEventListeners;

-(void)addConnectErrorEventListener:(void(^)(NSString *))onConnectError;
-(void)removeConnectErrorEventListeners:(void(^)(NSString *))onConnectError;
-(void)removeConnectErrorEventListeners;

-(void)addDisonnectEventListener:(void(^)(NSString *))onDisconnect;
-(void)removeDisconnectEventListeners:(void(^)(NSString *))onDisconnect;
-(void)removeDisconnectEventListeners;

-(void)addReconnectAttemptEventListener:(void(^)(ReconnectAttemptObject *))onReconnectAttempt;
-(void)removeReconnectAttemptEventListeners:(void(^)(ReconnectAttemptObject *))onReconnectAttempt;
-(void)removeReconnectAttemptEventListeners;

@end
