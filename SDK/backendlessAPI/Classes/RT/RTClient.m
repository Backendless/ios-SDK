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
#import "Backendless.h"
@import SocketIO;

@interface RTClient() {
    SocketIOClient *socket;
    BOOL socketReady;
    BOOL subscribed;
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
        self.subscriptions = [NSMutableDictionary new];
        socketReady = NO;
        subscribed = NO;
    }
    return self;
}

-(void)connectSocket {
    if (!socketReady) {
        NSString *path = [@"/" stringByAppendingString:[backendless getAppId]];
        NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:5000"];
        socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"path": path, @"nsp": path, @"connectParams":@{@"token":@"some-token"}}];
        [self onConnectionHandlers];
        [socket connect];
    }
}

-(void)onConnectionHandlers {
    [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"***** Socket connected *****");
        socketReady = YES;
        
        //TODO: resubscribe on reconnect
    }];
    [socket on:@"reconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"***** Socket reconnected *****");
    }];
    [socket on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"***** Socket disconnected *****");
    }];
}

-(void)subscribe:(NSDictionary *)data onError:(NSArray *)errors {
    [socket emit:@"SUB_ON" with:[NSArray arrayWithObject:data]];
    if (!subscribed) {
        [self onObjectChangesHandler:errors];
    }
}

-(void)onObjectChangesHandler:(NSArray *)errors {
    subscribed = YES;
    [socket on:@"SUB_RES" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSDictionary *resultData = data.firstObject;
        NSString *subId = [resultData valueForKey:@"id"];
        NSDictionary *result;
        
        if ([resultData valueForKey:@"result"]) {
            result = [resultData valueForKey:@"result"];
            void (^callback)(id) = [[self.subscriptions valueForKey:subId] valueForKey:@"onData"];
            if (callback) {
                callback(result);
            }
        }
        else if ([resultData valueForKey:@"error"]) {
            result = [resultData valueForKey:@"error"];
            
            for (void (^callback)(NSDictionary *) in errors) {
                callback(result);
                [self onStop:subId];
            }
        }
    }];
}

-(void)onStop:(NSString *)subId {
    [socket emit:@"SUB_OFF" with:[NSArray arrayWithObject:subId]];
    [self.subscriptions removeObjectForKey:subId];
}

@end
