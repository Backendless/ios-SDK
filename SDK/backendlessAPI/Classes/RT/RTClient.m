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

#import "RTClient.h"
#import "RTSubscription.h"
#import "RTMethodRequest.h"
#import "Backendless.h"
#import "RTHelper.h"
#import "ReconnectAttemptObject.h"
@import SocketIO;

#define MAX_TIME_INTERVAL 60 // seconds

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@interface RTClient() {
    SocketManager *socketManager;
    SocketIOClient *socket;
    NSMutableDictionary<NSString *, RTSubscription *> *subscriptions;
    NSMutableDictionary<NSString *, RTMethodRequest *> *methods;
    NSMutableDictionary<NSString *, NSArray *> *eventListeners;
    BOOL socketCreated;
    BOOL socketConnected;
    BOOL needResubscribe;
    BOOL onConnectionHandlersReady;
    BOOL onResultReady;
    BOOL onMethodResultReady;
    NSLock *_lock;
    NSInteger reconnectAttempt;
    double timeInterval;
    void(^onSocketConnectCallback)(void);
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
        eventListeners = [NSMutableDictionary<NSString *, NSArray *> new];
        socketCreated = NO;
        socketConnected = NO;
        needResubscribe = NO;
        onConnectionHandlersReady = NO;
        onResultReady = NO;
        onMethodResultReady = NO;
        _lock = [NSLock new];
        reconnectAttempt = 1;
        timeInterval = 0.2;
    }
    return self;
}

-(void)connectSocket:(void(^)(void))connected {
    if (!onSocketConnectCallback) {
        onSocketConnectCallback = connected;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            [_lock lock];
            if (!socketCreated) {
                NSString *path = [@"/" stringByAppendingString:[backendless getAppId]];
                NSURL *url = [NSURL URLWithString:[RTHelper lookup]];
                
                NSString *clientId = @"";
      
#if !TARGET_OS_WATCH
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
                clientId =[[[UIDevice currentDevice] identifierForVendor] UUIDString];
#else // macOS
                clientId = [[NSHost currentHost] name];
#endif
#endif
                NSDictionary *connectParams = @{@"apiKey":[backendless getAPIKey],
                                                @"clientId":clientId};
                NSString *userToken = [backendless.userService.currentUser getUserToken];
                if (userToken) {
                    connectParams = @{@"apiKey":[backendless getAPIKey],
                                      @"clientId":clientId,
                                      @"userToken": userToken};
                }
                socketManager = [[SocketManager alloc] initWithSocketURL:url config:@{@"path": path, @"connectParams":connectParams}];
                socketManager.reconnects = NO;
                socket = [socketManager socketForNamespace:path];
                if (socket) {
                    socketCreated = YES;
                    [self onConnectionHandlers:connected];
                }
            }
            
            if (socketCreated && socketConnected) {
                connected();
                [_lock unlock];
            }
            else if (socketCreated && !socketConnected) {
                [socket connect];
            }
        }
        @catch (Fault *fault) {
            [_lock unlock];
            [self onConnectErrorOrDisconnect:fault.message type:CONNECT_ERROR_EVENT];
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
    if ([subscriptions count] == 0 && socket && socketManager) {
        [socketManager removeSocket:socket];
        socket = nil;
        socketManager = nil;
        socketCreated = NO;
        socketConnected = NO;
        needResubscribe = NO;
        onConnectionHandlersReady = NO;
        onResultReady = NO;
        onMethodResultReady = NO;
    }
}

-(void)sendCommand:(id)data method:(RTMethodRequest *)method {
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
        [socket on:@"connect" callback:^(NSArray *data, SocketAckEmitter *ack) {
            socketConnected = YES;
            reconnectAttempt = 1;
            timeInterval = 0.2; // seconds
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
                connected();
            }
            
            [self onResult];
            [self onMethodResult];
            
            NSArray *connectListeners = [NSArray arrayWithArray:[eventListeners valueForKey:CONNECT_EVENT]];
            for (void(^connectBlock)(void) in connectListeners) {
                connectBlock();
            }
        }];
        
        [socket on:@"connect_error" callback:^(NSArray *data, SocketAckEmitter *ack) {
            NSString *reason = data.firstObject;
            [self onConnectErrorOrDisconnect:reason type:CONNECT_ERROR_EVENT];
        }];
        
        [socket on:@"connect_timeout" callback:^(NSArray *data, SocketAckEmitter *ack) {
            NSString *reason = data.firstObject;
            [self onConnectErrorOrDisconnect:reason type:CONNECT_ERROR_EVENT];
        }];
        
        [socket on:@"error" callback:^(NSArray *data, SocketAckEmitter *ack) {
            NSString *reason = data.firstObject;
            [self onConnectErrorOrDisconnect:reason type:CONNECT_ERROR_EVENT];
        }];
        
        [socket on:@"disconnect" callback:^(NSArray *data, SocketAckEmitter *ack) {
            [socketManager disconnectSocket:socket];
            NSString *reason = data.firstObject;
            [self onConnectErrorOrDisconnect:reason type:DISCONNECT_EVENT];
        }];
    }
}

-(void)onConnectErrorOrDisconnect:(NSString *)reason type:(NSString *)type {
    [socketManager removeSocket:socket];
    socket = nil;
    socketManager = nil;
    socketCreated = NO;
    socketConnected = NO;
    needResubscribe = YES;
    onConnectionHandlersReady = NO;
    onResultReady = NO;
    onMethodResultReady = NO;    
    NSArray *connectListeners = [NSArray arrayWithArray:[eventListeners valueForKey:type]];    
    for (int i = 0; i < [connectListeners count]; i++) {
        void(^connectBlock)(NSString *) = [connectListeners objectAtIndex:i];
        connectBlock(reason);
    }
    [self onReconnectAttempt];
    [self tryToReconnectSocket];
}

-(void)onReconnectAttempt {
    NSArray *reconnectAttemptListeners = [NSArray arrayWithArray:[eventListeners valueForKey:RECONNECT_ATTEMPT_EVENT]];
    for (int i = 0; i < [reconnectAttemptListeners count]; i++) {
        ReconnectAttemptObject *reconnectAttemptObject = [ReconnectAttemptObject new];
        reconnectAttemptObject.attempt = @(reconnectAttempt);
        reconnectAttemptObject.timeout = @(MAX_TIME_INTERVAL * 1000);
        void(^reconnectAttemptBlock)(ReconnectAttemptObject *) = [reconnectAttemptListeners objectAtIndex:i];
        reconnectAttemptBlock(reconnectAttemptObject);
    }
    reconnectAttempt++;
}

-(void)tryToReconnectSocket {
    if (timeInterval < MAX_TIME_INTERVAL) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInterval * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self connectSocket:onSocketConnectCallback];
        });
        if (reconnectAttempt % 10 == 0) {
            timeInterval *= 2;
        }
    }
    else {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MAX_TIME_INTERVAL * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self connectSocket:onSocketConnectCallback];
        });
    }
}

-(void)onResult {
    if (!onResultReady) {
        [socket on:@"SUB_RES" callback:^(NSArray *data, SocketAckEmitter *ack) {
            onResultReady = YES;
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
                else if ([result isKindOfClass:[NSNumber class]]) {
                    if (subscription && subscription.onResult) {
                        subscription.onResult(result);
                    }
                }
                else if ([result isKindOfClass:[NSArray class]]) {
                    if (subscription && subscription.onResult) {
                        subscription.onResult(result);
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
                    [self unsubscribe:subscriptionId];
                }
            }
        }];
    }
}

-(void)onMethodResult {
    if (!onMethodResultReady) {
        onMethodResultReady = YES;
        [socket on:@"MET_RES" callback:^(NSArray *data, SocketAckEmitter *ack) {
            NSDictionary *resultData = data.firstObject;
            NSString *methodId = [resultData valueForKey:@"id"];
            RTMethodRequest *method = [methods valueForKey:methodId];
            if (method) {
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
            }
        }];
    }
}

-(void)userLoggedInWithToken:(NSString *)userToken {
    NSString *methodId = [[NSUUID UUID] UUIDString];
    NSDictionary *options = @{@"userToken"  : [NSNull null]};
    if (userToken) {
        options = @{@"userToken"  : userToken};
    }
    NSDictionary *data = @{@"id"        : methodId,
                           @"name"      : SET_USER_TOKEN,
                           @"options"   : options};
    [self sendCommand:data method:nil];
}

// Native Socket.io events
-(void)addConnectEventListener:(void(^)(void))onConnect {
    NSMutableArray *connectListeners = [NSMutableArray arrayWithArray:[eventListeners valueForKey:CONNECT_EVENT]];
    if (connectListeners) {
        [connectListeners addObject:onConnect];
        [eventListeners setObject:connectListeners forKey:CONNECT_EVENT];
    }
}

-(void)removeConnectEventListeners:(void(^)(void))onConnect {
    NSMutableArray *connectListeners = [NSMutableArray arrayWithArray:[eventListeners valueForKey:CONNECT_EVENT]];
    if (connectListeners) {
        [connectListeners removeObject:onConnect];
        [eventListeners setObject:connectListeners forKey:CONNECT_EVENT];
    }
}

-(void)addEventListener:(NSString *)type callBack:(void(^)(id))callback {
    NSMutableArray *listeners = [NSMutableArray arrayWithArray:[eventListeners valueForKey:type]];
    if (listeners) {
        [listeners addObject:callback];
        [eventListeners setObject:listeners forKey:type];
    }
}

-(void)removeEventListeners:(NSString *)type callBack:(void(^)(id))callback {
    NSMutableArray *listeners = [NSMutableArray arrayWithArray:[eventListeners valueForKey:type]];
    if (listeners) {
        [listeners removeObject:callback];
        [eventListeners setObject:listeners forKey:type];
    }
}

-(void)removeEventListeners:(NSString *)type {
    NSMutableArray *listeners = [NSMutableArray arrayWithArray:[eventListeners valueForKey:type]];
    if (listeners) {
        [listeners removeAllObjects];
        [eventListeners setObject:listeners forKey:type];
    }
}

@end

