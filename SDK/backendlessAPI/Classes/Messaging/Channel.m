//
//  Channel.m
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

#import "Channel.h"
#import "RTMessaging.h"

@interface Channel()
@property (strong, nonatomic, readwrite) NSString *channelName;
@property (strong, nonatomic) RTMessaging *rt;
@property (nonatomic, readwrite) BOOL isConnected;
@end

@implementation Channel

-(instancetype)initWithChannelName:(NSString *)channelName {
    if (self = [super init]) {
        self.channelName = channelName;
        self.rt = [[RTMessaging alloc] initWithChannelName:channelName];
        self.isConnected = NO;
    }
    return self;
}

-(NSString *)getChannelName {
    return self.channelName;
}

-(void)connect {
    __weak __typeof__(self) weakSelf = self;
    [self.rt connect:^(id result) {
        __typeof__(self) strongSelf = weakSelf;
        strongSelf.isConnected = YES;
    }];
}

-(void)disconnect {
    [self removeErrorListener];
    [self removeConnectListener];
    [self removeMessageListener];
    self.isConnected = NO;
}

// **********************************************

-(void)addErrorListener:(void(^)(Fault *))errorBlock {
    [self.rt addErrorListener:errorBlock];
}

-(void)removeErrorListener:(void(^)(Fault *))errorBlock {
    [self.rt removeErrorListener:errorBlock];
}

-(void)removeErrorListener {
    [self.rt removeErrorListener:nil];
}

// **********************************************

-(void)addConnectListener:(void(^)(void))onConnect {
    [self.rt addConnectListener:self.isConnected onConnect:onConnect];
}

-(void)removeConnectListener:(void(^)(void))onConnect {
    [self.rt removeConnectListener:onConnect];
}

-(void)removeConnectListener {
    [self.rt removeConnectListener:nil];
}

// **********************************************

-(void)addMessageListener:(void(^)(Message *))onMessage {
    [self.rt addMessageListener:nil onMessage:onMessage];
}

-(void)addMessageListener:(NSString *)selector onMessage:(void(^)(Message *))onMessage {
    [self.rt addMessageListener:selector onMessage:onMessage];
}

-(void)removeMessageListener:(NSString *)selector onMessage:(void(^)(Message *))onMessage {
    [self.rt removeMessageListener:selector onMessage:onMessage];
}

-(void)removeMessageListenerWithCallback:(void(^)(Message *))onMessage {
    [self.rt removeMessageListener:nil onMessage:onMessage];
}

-(void)removeMessageListenerWithSelector:(NSString *)selector {
    [self.rt removeMessageListener:selector onMessage:nil];
}

-(void)removeMessageListener {
    [self.rt removeMessageListener:nil onMessage:nil];
}

// **********************************************

-(void)addCommandListener:(void (^)(CommandObject *))onCommand {
    [self.rt addCommandListener:onCommand];
}

-(void)removeCommandListener:(void (^)(CommandObject *))onCommand {
    [self.rt removeCommandListener:onCommand];
}

-(void)removeCommandListener {
    [self.rt removeCommandListener:nil];
}

// **********************************************

-(void)addUserStatusListener:(void (^)(UserStatusObject *))onUserStatus {
    [self.rt addUserStatusListener:onUserStatus];
}

-(void)removeUserStatusListener:(void (^)(UserStatusObject *))onUserStatus {
    [self.rt removeUserStatusListener:onUserStatus];
}

-(void)removeUserStatusListener {
    [self.rt removeUserStatusListener:nil];
}

// **********************************************

-(void)removeAllListeners {
    [self removeErrorListener];
    [self removeConnectListener];
    [self removeMessageListener];
}

@end
