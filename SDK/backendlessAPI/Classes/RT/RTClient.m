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
    BOOL socketReady;
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
    }
    return self;
}

-(void)connectSocket:(void(^)(void))connected {
    if (!socketReady) {
        NSString *path = [@"/" stringByAppendingString:[backendless getAppId]];
        NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:5000"];
        self.socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"path": path, @"nsp": path, @"connectParams":@{@"token":@"some-token"}}];
        [self onConnectionHandlers:connected];
        [self.socket connect];
    }
}

-(void)onConnectionHandlers:(void(^)(void))connected {
    [self.socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        if (!socketReady) {
            NSLog(@"***** Socket connected *****");
            socketReady = YES;
        }
        connected();
        //TODO: resubscribe on reconnect
    }];
    [self.socket on:@"reconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"***** Socket reconnected *****");
    }];
    [self.socket on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"***** Socket disconnected *****");
    }];
}

@end
