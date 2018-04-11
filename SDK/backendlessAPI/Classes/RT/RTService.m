//
//  RTService.m
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


#import "RTService.h"
#import "RTClient.h"

@implementation RTService

-(void)addConnectEventListener:(void(^)(void))onConnect {
    [rtClient addConnectEventListener:onConnect];
}

-(void)removeConnectEventListeners:(void(^)(void))onConnect {
    [rtClient removeConnectEventListeners:onConnect];
}

-(void)removeConnectEventListeners {
    [rtClient removeEventListeners:CONNECT_EVENT];
}

-(void)addConnectErrorEventListener:(void(^)(NSString *))onConnectError {
    [rtClient addEventListener:CONNECT_ERROR_EVENT callBack:onConnectError];
}

-(void)removeConnectErrorEventListeners:(void(^)(NSString *))onConnectError {
    [rtClient removeEventListeners:CONNECT_ERROR_EVENT callBack:onConnectError];
}

-(void)removeConnectErrorEventListeners {
    [rtClient removeEventListeners:CONNECT_ERROR_EVENT];
}

-(void)addDisonnectEventListener:(void(^)(NSString *))onDisconnect {
    [rtClient addEventListener:DISCONNECT_EVENT callBack:onDisconnect];
}

-(void)removeDisconnectEventListeners:(void(^)(NSString *))onDisconnect {
    [rtClient removeEventListeners:DISCONNECT_EVENT callBack:onDisconnect];
}

-(void)removeDisconnectEventListeners {
    [rtClient removeEventListeners:DISCONNECT_EVENT];
}

-(void)addReconnectAttemptEventListener:(void(^)(ReconnectAttemptObject *))onReconnectAttempt {
    [rtClient addEventListener:RECONNECT_ATTEMPT_EVENT callBack:onReconnectAttempt];
}

-(void)removeReconnectAttemptEventListeners:(void(^)(ReconnectAttemptObject *))onReconnectAttempt {
    [rtClient removeEventListeners:RECONNECT_ATTEMPT_EVENT callBack:onReconnectAttempt];
}

-(void)removeReconnectAttemptEventListeners {
    [rtClient removeEventListeners:RECONNECT_ATTEMPT_EVENT];
}

-(void)removeConnectionListeners {
    [self removeConnectionListeners];
    [self removeConnectErrorEventListeners];
    [self removeDisconnectEventListeners];
    [self removeReconnectAttemptEventListeners];
}

@end
