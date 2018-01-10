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

-(void)connect {
    __weak __typeof__(self) weakSelf = self;
    [self.rt connect:^(id result) {
        __typeof__(self) strongSelf = weakSelf;
        strongSelf.isConnected = YES;
    }];
}

-(void)disconnect {
    [self removeErrorListeners];
    [self removeConnectListeners];
    [self removeMessageListeners];
    [self removeCommandListeners];
    [self removeUserStatusListeners];
    self.isConnected = NO;
}

-(void)addErrorListener:(void(^)(Fault *))errorBlock {
    [self.rt addErrorListener:errorBlock];
}

-(void)removeErrorListeners:(void(^)(Fault *))errorBlock {
    [self.rt removeErrorListeners:errorBlock];
}

-(void)removeErrorListeners {
    [self.rt removeErrorListeners:nil];
}

-(void)addConnectListener:(void(^)(void))onConnect {
    [self.rt addConnectListener:self.isConnected onConnect:onConnect];
}

-(void)removeConnectListeners:(void(^)(void))onConnect {
    [self.rt removeConnectListeners:onConnect];
}

-(void)removeConnectListeners {
    [self.rt removeConnectListeners:nil];
}

-(void)addMessageListener:(void(^)(Message *))onMessage {
    [self.rt addMessageListener:nil onMessage:onMessage];
}

-(void)addMessageListener:(NSString *)selector onMessage:(void(^)(Message *))onMessage {
    [self.rt addMessageListener:selector onMessage:onMessage];
}

-(void)removeMessageListeners:(NSString *)selector onMessage:(void(^)(Message *))onMessage {
    [self.rt removeMessageListeners:selector onMessage:onMessage];
}

-(void)removeMessageListenersWithCallback:(void(^)(Message *))onMessage {
    [self.rt removeMessageListeners:nil onMessage:onMessage];
}

-(void)removeMessageListenersWithSelector:(NSString *)selector {
    [self.rt removeMessageListeners:selector onMessage:nil];
}

-(void)removeMessageListeners {
    [self.rt removeMessageListeners:nil onMessage:nil];
}

-(void)addCommandListener:(void (^)(CommandObject *))onCommand {
    [self.rt addCommandListener:onCommand];
}

-(void)removeCommandListeners:(void (^)(CommandObject *))onCommand {
    [self.rt removeCommandListeners:onCommand];
}

-(void)removeCommandListeners {
    [self.rt removeCommandListeners:nil];
}

-(void)addUserStatusListener:(void (^)(UserStatusObject *))onUserStatus {
    [self.rt addUserStatusListener:onUserStatus];
}

-(void)removeUserStatusListeners:(void (^)(UserStatusObject *))onUserStatus {
    [self.rt removeUserStatusListeners:onUserStatus];
}

-(void)removeUserStatusListeners {
    [self.rt removeUserStatusListeners:nil];
}

-(void)removeAllListeners {
    [self removeErrorListeners];
    [self removeConnectListeners];
    [self removeMessageListeners];
    [self removeCommandListeners];
    [self removeUserStatusListeners];
}

@end
