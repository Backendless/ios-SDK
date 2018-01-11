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

@synthesize data = _data;

-(RTPersistence *)data {
    if (!_data) {
        _data = [RTPersistence new];
    }
    return _data;
}

-(void)addConnectEventListener:(void(^)(void))connectBlock {
    [rtClient addConnectEventListener:connectBlock];
}

-(void)removeConnectEventListeners:(void(^)(void))connectBlock {
    [rtClient removeConnectEventListeners:connectBlock];
}

-(void)removeConnectEventListeners {
    [rtClient removeEventListeners:CONNECT_EVENT];
}

-(void)addConnectErrorEventListener:(void(^)(NSString *))connectErrorBlock {
    [rtClient addEventListener:CONNECT_ERROR_EVENT callBack:connectErrorBlock];
}

-(void)removeConnectErrorEventListeners:(void(^)(NSString *))connectErrorBlock {
    [rtClient removeEventListeners:CONNECT_ERROR_EVENT callBack:connectErrorBlock];
}

-(void)removeConnectErrorEventListeners {
    [rtClient removeEventListeners:CONNECT_ERROR_EVENT];
}

-(void)addDisonnectEventListener:(void(^)(NSString *))disconnectBlock {
    [rtClient addEventListener:DISCONNECT_EVENT callBack:disconnectBlock];
}

-(void)removeDisconnectEventListeners:(void(^)(NSString *))disconnectBlock {
    [rtClient removeEventListeners:DISCONNECT_EVENT callBack:disconnectBlock];
}

-(void)removeDisconnectEventListeners {
    [rtClient removeEventListeners:DISCONNECT_EVENT];
}

-(void)addReconnectAttemptEventListener:(void(^)(ReconnectAttemptObject *))reconnectAttemptBlock {
    [rtClient addEventListener:RECONNECT_ATTEMPT_EVENT callBack:reconnectAttemptBlock];
}

-(void)removeReconnectAttemptEventListeners:(void(^)(ReconnectAttemptObject *))reconnectAttemptBlock {
    [rtClient removeEventListeners:RECONNECT_ATTEMPT_EVENT callBack:reconnectAttemptBlock];
}

-(void)removeReconnectAttemptEventListeners {
    [rtClient removeEventListeners:RECONNECT_ATTEMPT_EVENT];
}

@end
