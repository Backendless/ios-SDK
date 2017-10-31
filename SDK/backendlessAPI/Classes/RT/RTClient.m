//
//  RTClient.m
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

#import "RTClient.h"
#include "Backendless.h"
#import "RTSubscription.h"
#import "RTError.h"


@interface RTClient() {
    SocketIOClient *socket;
    NSMutableDictionary<NSString *, RTSubscription *> *subscriptions;
    BOOL socketCreated;
    BOOL socketConnected;
    BOOL needResubscribe;
    BOOL onConnectionHandlersReady;
    NSLock *_lock;
}
@end

@implementation RTClient

+(RTClient *)sharedInstance {
    static RTClient *sharedRTClient;
    @synchronized(self) {
        if (!sharedRTClient)
            sharedRTClient = [[RTClient alloc] init];
    }
    return sharedRTClient;
}

- (RTClient *)init {
    if (self = [super init]) {
        subscriptions = [NSMutableDictionary<NSString *, RTSubscription *> new];
        socketCreated = NO;
        socketConnected = NO;
        needResubscribe = NO;
        onConnectionHandlersReady = NO;
        _lock = [NSLock new];
    }
    return self;
}

-(void)connectSocket:(void(^)(void))connected {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_lock lock];
        if (!socketCreated) {
            NSString *path = [@"/" stringByAppendingString:[backendless getAppId]];
            NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:5000"];
            socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"path": path, @"nsp": path, @"connectParams":@{@"token":@"some-token"}}];
            if (socket) {
                socketCreated = YES;
                [self onConnectionHandlers:connected];
            }
        }
        if (socketConnected) {
            connected();
        }
        else {
            [socket connect];
        }
    });
}

-(void)subscribe:(NSDictionary *)data subscription:(RTSubscription *)subscription {
    if(socketConnected) {
        [socket emit:@"SUB_ON" with:[NSArray arrayWithObject:data]];
    }
    else {
        [self connectSocket:^{
            [socket emit:@"SUB_ON" with:[NSArray arrayWithObject:data]];
        }];
    }
    [subscriptions setObject:subscription forKey:subscription.subscriptionId];
}

-(void)unsubscribe:(NSString *)subscriptionId {
    [socket emit:@"SUB_OFF" with:[NSArray arrayWithObject:@{@"id":subscriptionId}]];
    [subscriptions removeObjectForKey:subscriptionId];
}

-(void)onConnectionHandlers:(void(^)(void))connected {
    if (!onConnectionHandlersReady) {
        onConnectionHandlersReady = YES;
        
        [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
            NSLog(@"***** Socket connected *****");
            socketConnected = YES;
            [_lock unlock];
            
            // reusbscribe
            if (needResubscribe) {
                NSLog(@"Here will be resubscribed: %lu", (unsigned long)[subscriptions count]);
                needResubscribe = NO;
            }
            else if (!needResubscribe) {
                [self onResult];
                connected();
            }
        }];
        
        [socket on:@"reconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
            NSLog(@"***** Socket reconnected *****");
            [_lock lock];
            socketConnected = NO;
            needResubscribe = YES;
        }];
    }
}

-(void)onResult {
    [socket on:@"SUB_RES" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSDictionary *resultData = data.firstObject;
        NSString *subId = [resultData valueForKey:@"id"];
        
        if ([resultData valueForKey:@"result"]) {
            NSDictionary *result = [resultData valueForKey:@"result"];
            void (^resultCallback)(id) = ((RTSubscription *)[subscriptions valueForKey:subId]).onResult;
            if (resultCallback) {
                resultCallback(result);
            }
        }
        else if ([resultData valueForKey:@"error"]) {
            RTError *error = [RTError new];
            error.code = [[resultData valueForKey:@"error"] valueForKey:@"code"];
            error.message = [[resultData valueForKey:@"error"] valueForKey:@"message"];
            error.details = [[resultData valueForKey:@"details"] valueForKey:@"code"];
            void (^errorCallback)(RTError *) = ((RTSubscription *)[subscriptions valueForKey:subId]).onError;
            if (errorCallback) {
                errorCallback(error);
            }
            void (^stopCallback)(RTSubscription *) = [subscriptions valueForKey:subId].onStop;
            if (stopCallback) {
                stopCallback([subscriptions valueForKey:subId]);
            }
            [subscriptions removeObjectForKey:subId];
        }
    }];
}

@end
