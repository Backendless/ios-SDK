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
#import "RTSubscription.h"
#import "RTMethodRequest.h"
#import "Backendless.h"

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@interface RTClient() {
    SocketManager *socketManager;
    SocketIOClient *socket;
    NSMutableDictionary<NSString *, RTSubscription *> *subscriptions;
    NSMutableDictionary<NSString *, RTMethodRequest *> *methods;
    BOOL socketCreated;
    BOOL socketConnected;
    BOOL needResubscribe;
    BOOL onConnectionHandlersReady;
    NSLock *_lock;
}
@end

@implementation RTClient

+(instancetype)sharedInstance {
    static RTClient *sharedRTClient;
    @synchronized(self) {
        if (!sharedRTClient)
            sharedRTClient = [[RTClient alloc] init];
    }
    return sharedRTClient;
}

- (instancetype)init {
    if (self = [super init]) {
        subscriptions = [NSMutableDictionary<NSString *, RTSubscription *> new];
        methods =  [NSMutableDictionary<NSString *, RTMethodRequest *> new];
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
            NSString *userToken = [backendless.userService.currentUser getUserToken];
            if (userToken) {
                socketManager = [[SocketManager alloc] initWithSocketURL:url config:@{@"path": path, @"connectParams":@{@"token":@"some-token", @"userToken":userToken}}];
            }
            else {
                socketManager = [[SocketManager alloc] initWithSocketURL:url config:@{@"path": path, @"connectParams":@{@"token":@"some-token"}}];
            }
            socket = [socketManager socketForNamespace:path];
            if (socket) {
                socketCreated = YES;
                [self onConnectionHandlers:connected];
            }
        }
        if (socketConnected) {
            connected();
            [_lock unlock];
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
    if (!needResubscribe) {
        [subscriptions setObject:subscription forKey:subscription.subscriptionId];
    }
}

-(void)unsubscribe:(NSString *)subscriptionId {
    [socket emit:@"SUB_OFF" with:[NSArray arrayWithObject:@{@"id":subscriptionId}]];
    [subscriptions removeObjectForKey:subscriptionId];
}

-(void)sendCommand:(NSDictionary *)data method:(RTMethodRequest *)method {
    if(socketConnected) {
        [socket emit:@"MET_REQ" with:[NSArray arrayWithObject:data]];
    }
    else {
        [self connectSocket:^{
            [socket emit:@"MET_REQ" with:[NSArray arrayWithObject:data]];
        }];
    }
    if (method) {
        [methods setObject:method forKey:method.methodId];
    }
}

-(void)onConnectionHandlers:(void(^)(void))connected {
    if (!onConnectionHandlersReady) {
        onConnectionHandlersReady = YES;
        
        [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
            NSLog(@"***** Socket connected *****");
            socketConnected = YES;
            [_lock unlock];
            
            if (needResubscribe) {
                for (NSString *subscriptionId in subscriptions) {
                    RTSubscription *subscription = [subscriptions valueForKey:subscriptionId];
                    
                    NSDictionary *data = @{@"id"        : subscriptionId,
                                           @"name"      : subscription.type,
                                           @"options"   : subscription.options};
                    
                    [self subscribe:data subscription:subscription];
                }
                needResubscribe = NO;
            }
            
            else if (!needResubscribe) {
                [self onResult];
                [self onMethodResult];
                connected();
            }
        }];
        [socket on:@"reconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
            NSLog(@"***** Socket reconnected *****");
            socketConnected = NO;
            needResubscribe = YES;
        }];
    }
}

-(void)onResult {
    [socket on:@"SUB_RES" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSDictionary *resultData = data.firstObject;
        NSString *subscriptionId = [resultData valueForKey:@"id"];
        RTSubscription *subscription = [subscriptions valueForKey:subscriptionId];
        
        if ([resultData valueForKey:@"data"]) {
            id result = [resultData valueForKey:@"data"];
            subscription.ready = YES;
            
            if (result && [result isKindOfClass:[NSString class]] && [result isEqualToString:@"connected"]) {
                if (subscription && subscription.onReady) {
                    subscription.onReady();
                    subscription.onResult(result);
                }
            }
            else if (result && [result isKindOfClass:[NSDictionary class]]) {
                if (subscription && subscription.onResult) {
                    subscription.onResult([subscription.classInstance performSelector:subscription.handleResult withObject:result]);
                }
            }
        }
        else if ([resultData valueForKey:@"error"]) {
            Fault *fault = [Fault fault:[[resultData valueForKey:@"error"] valueForKey:@"message"]
                                 detail:[[resultData valueForKey:@"error"] valueForKey:@"message"]
                              faultCode:[[resultData valueForKey:@"details"] valueForKey:@"code"]];
            
            if (subscription && subscription.onError) {
                subscription.onError(fault);
            }
            if (subscription && subscription.onStop) {
                subscription.onStop(subscription);
                [subscriptions removeObjectForKey:subscriptionId];
            }
        }
    }];
}

-(void)onMethodResult {
    [socket on:@"MET_RES" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSDictionary *resultData = data.firstObject;
        NSString *methodId = [resultData valueForKey:@"id"];
        RTMethodRequest *method = [methods valueForKey:methodId];
        
        if ([resultData valueForKey:@"error"]) {
            Fault *fault = [Fault fault:[[resultData valueForKey:@"error"] valueForKey:@"message"]
                                 detail:[[resultData valueForKey:@"error"] valueForKey:@"message"]
                              faultCode:[[resultData valueForKey:@"error"] valueForKey:@"code"]];            
            if (method && method.onError) {
                method.onError(fault);
            }
            if (method && method.onStop) {
                method.onStop(method);
                [methods removeObjectForKey:methodId];
            }
        }
        else {
            if ([resultData valueForKey:@"result"]) {
                method.onResult([resultData valueForKey:@"result"]);
            }
            else if ([resultData valueForKey:@"id"] && ![resultData valueForKey:@"result"]) {
                method.onResult(nil);
            }
            method.onStop(method);
            [methods removeObjectForKey:methodId];
        }
    }];
}

-(void)userLoggedInWithToken:(NSString *)userToken {
    if (socketConnected) {
        NSString *methodId = [[NSUUID UUID] UUIDString];
        NSDictionary *options = @{@"userToken"  : userToken};
        NSDictionary *data = @{@"id"        : methodId,
                               @"name"      : SET_USER,
                               @"options"   : options};
        [self sendCommand:data method:nil];
    }
}

@end

