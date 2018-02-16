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
    if (!self.isConnected) {
        __weak __typeof__(self) weakSelf = self;
        [self.rt connect:^(id result) {
            __typeof__(self) strongSelf = weakSelf;
            strongSelf.isConnected = YES;
        }];
    }
}

-(void)disconnect {
    if (self.isConnected) {
        [self removeConnectListeners];
        [self removeMessageListeners];
        [self removeCommandListeners];
        [self removeUserStatusListeners];
        self.isConnected = NO;
    }
}

-(void)addConnectListener:(void(^)(void))responseBlock error:(void (^)(Fault *))errorBlock {
    [self.rt addConnectListener:self.isConnected response:responseBlock error:errorBlock];
}

-(void)removeConnectListeners:(void(^)(void))responseBlock {
    [self.rt removeConnectListeners:responseBlock];
}

-(void)removeConnectListeners {
    [self.rt removeConnectListeners:nil];
}

-(void)addMessageListener:(void(^)(Message *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self.rt addMessageListener:nil response:responseBlock error:errorBlock];
}

-(void)addMessageListener:(NSString *)selector response:(void (^)(Message *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self.rt addMessageListener:selector response:responseBlock error:errorBlock];
}

-(void)removeMessageListeners:(NSString *)selector response:(void (^)(Message *))responseBlock {
    [self.rt removeMessageListeners:selector response:responseBlock];
}

-(void)removeMessageListenersWithCallback:(void(^)(Message *))responseBlock {
    [self.rt removeMessageListeners:nil response:responseBlock];
}

-(void)removeMessageListenersWithSelector:(NSString *)selector {
    [self.rt removeMessageListeners:selector response:nil];
}

-(void)removeMessageListeners {
    [self.rt removeMessageListeners:nil response:nil];
}

-(void)addCommandListener:(void (^)(CommandObject *))responseBlock error:(void(^)(Fault *))errorBlock; {
    [self.rt addCommandListener:responseBlock error:errorBlock];
}

-(void)removeCommandListeners:(void (^)(CommandObject *))responseBlock {
    [self.rt removeCommandListeners:responseBlock];
}

-(void)removeCommandListeners {
    [self.rt removeCommandListeners:nil];
}

-(void)addUserStatusListener:(void (^)(UserStatusObject *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self.rt addUserStatusListener:responseBlock error:errorBlock];
}

-(void)removeUserStatusListeners:(void (^)(UserStatusObject *))responseBlock {
    [self.rt removeUserStatusListeners:responseBlock];
}

-(void)removeUserStatusListeners {
    [self.rt removeUserStatusListeners:nil];
}

-(void)removeAllListeners {
    [self removeConnectListeners];
    [self removeMessageListeners];
    [self removeCommandListeners];
    [self removeUserStatusListeners];
}

@end
