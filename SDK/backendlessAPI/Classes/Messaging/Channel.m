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
#import "PublishMessageInfoWrapper.h"

@interface Channel()
@property (strong, nonatomic, readwrite) NSString *channelName;
@property (strong, nonatomic) RTMessaging *rt;
@property (nonatomic, readwrite) BOOL isJoined;
@property (nonatomic, readwrite) NSMutableArray *waitingSubscriptions;
@end

@implementation Channel

-(instancetype)initWithChannelName:(NSString *)channelName {
    if (self = [super init]) {
        self.channelName = channelName;
        self.rt = [[RTMessaging alloc] initWithChannelName:channelName];
        self.isJoined = NO;
        self.waitingSubscriptions = [NSMutableArray new];
    }
    return self;
}

-(void)join {
    if (!self.isJoined) {
        __weak __typeof__(self) weakSelf = self;
        [self.rt connect:^(id result) {
            __typeof__(self) strongSelf = weakSelf;
            strongSelf.isJoined = YES;
            for (NSDictionary *waitingSubscription in self.waitingSubscriptions) {
                if ([[waitingSubscription valueForKey:@"event"] isEqualToString:PUB_SUB_CONNECT]) {
                    void(^onConnectResponse)(void) = [waitingSubscription valueForKey:@"onConnectResponse"];
                    onConnectResponse();
                }
            }
            [self subscribeForWaitingListeners];
        } onError: ^(Fault *fault) {
            for (NSDictionary *waitingSubscription in self.waitingSubscriptions) {
                if ([[waitingSubscription valueForKey:@"event"] isEqualToString:PUB_SUB_CONNECT]) {
                    void(^onError)(Fault *) = [waitingSubscription valueForKey:@"onError"];
                    onError(fault);
                }
            }
        }];
    }
}

-(void)leave {
    if (self.isJoined) {
        [self removeAllListeners];
        self.isJoined = NO;
    }
}

-(void)addJoinListener:(void(^)(void))responseBlock error:(void (^)(Fault *))errorBlock {
    if (self.isJoined) {
        [self.rt addJoinListener:self.isJoined response:responseBlock error:errorBlock];
    }
    else {
        [self addWaitingListener:PUB_SUB_CONNECT selector:nil connectResponse:responseBlock response:nil error:errorBlock];
    }
}

-(void)removeJoinListeners {
    [self.rt removeJoinListeners];
}

-(void)addMessageListenerString:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self addMessageListener:[publishMessageInfoWrapper wrapResponseBlock:responseBlock error:errorBlock class:[NSString class]] error:errorBlock];
}

-(void)addMessageListenerString:(NSString *)selector response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self addMessageListener:selector response:[publishMessageInfoWrapper wrapResponseBlock:responseBlock error:errorBlock class:[NSString class]] error:errorBlock];
}

-(void)addMessageListenerDictionary:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self addMessageListener:[publishMessageInfoWrapper wrapResponseBlock:responseBlock error:errorBlock class:[NSDictionary class]] error:errorBlock];}

-(void)addMessageListenerDictionary:(NSString *)selector response:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self addMessageListener:selector response:[publishMessageInfoWrapper wrapResponseBlock:responseBlock error:errorBlock class:[NSDictionary class]] error:errorBlock];
}

-(void)addMessageListenerCustomObject:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock class:(Class)classType {
    [self addMessageListener:[publishMessageInfoWrapper wrapResponseBlockToCustomObject:responseBlock error:errorBlock class:classType] error:errorBlock];
}

-(void)addMessageListenerCustomObject:(NSString *)selector response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock class:(Class)classType {
    [self addMessageListener:selector response:[publishMessageInfoWrapper wrapResponseBlockToCustomObject:responseBlock error:errorBlock class:classType] error:errorBlock];
}

-(void)addMessageListener:(void(^)(PublishMessageInfo *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self addMessageListener:nil response:responseBlock error:errorBlock];
}

-(void)addMessageListener:(NSString *)selector response:(void (^)(PublishMessageInfo *))responseBlock error:(void (^)(Fault *))errorBlock {
    if (self.isJoined) {
        [self.rt addMessageListener:selector response:responseBlock error:errorBlock];
    }
    else {
        [self addWaitingListener:PUB_SUB_MESSAGES selector:selector connectResponse:nil response:responseBlock error:errorBlock];
    }
}

-(void)removeMessageListeners:(NSString *)selector {
    [self.rt removeMessageListeners:selector];
}

-(void)removeMessageListeners {
    [self.rt removeMessageListeners:nil];
}

-(void)addCommandListener:(void (^)(CommandObject *))responseBlock error:(void(^)(Fault *))errorBlock; {
    if (self.isJoined) {
        [self.rt addCommandListener:responseBlock error:errorBlock];
    }
    else {
        [self addWaitingListener:PUB_SUB_COMMANDS selector:nil connectResponse:nil response:responseBlock error:errorBlock];
    }
}

-(void)removeCommandListeners {
    [self.rt removeCommandListeners];
}

-(void)addUserStatusListener:(void (^)(UserStatusObject *))responseBlock error:(void (^)(Fault *))errorBlock {
    if (self.isJoined) {
        [self.rt addUserStatusListener:responseBlock error:errorBlock];
    }
    else {
        [self addWaitingListener:PUB_SUB_USERS selector:nil connectResponse:nil response:responseBlock error:errorBlock];
    }
}

-(void)removeUserStatusListeners {
    [self.rt removeUserStatusListeners];
}

-(void)removeAllListeners {
    [self removeJoinListeners];
    [self removeMessageListeners];
    [self removeCommandListeners];
    [self removeUserStatusListeners];
}

-(void)addWaitingListener:(NSString *)event selector:(NSString *)selector connectResponse:(void(^)(void))connectResponseBlock response:(void(^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    NSDictionary *waitingObject;
    if (connectResponseBlock) {
        if (selector) {
            waitingObject = @{@"event"              : event,
                              @"selector"           : selector,
                              @"onConnectResponse"  : connectResponseBlock,
                              @"onError"            : errorBlock};
        }
        else {
            waitingObject = @{@"event"              : event,
                              @"onConnectResponse"  : connectResponseBlock,
                              @"onError"            : errorBlock};
        }
    }
    else if (responseBlock) {
        if (selector) {
            waitingObject = @{@"event"      : event,
                              @"selector"   : selector,
                              @"onResponse" : responseBlock,
                              @"onError"    : errorBlock};
        }
        else {
            waitingObject = @{@"event"      : event,
                              @"onResponse" : responseBlock,
                              @"onError"    : errorBlock};
        }
    }
    [self.waitingSubscriptions addObject:waitingObject];
}

-(void)subscribeForWaitingListeners {
    for (NSDictionary *waitingSubscription in self.waitingSubscriptions) {
        if ([[waitingSubscription valueForKey:@"event"] isEqualToString:PUB_SUB_MESSAGES]) {
            if ([waitingSubscription valueForKey:@"selector"]) {
                [self addMessageListener:[waitingSubscription valueForKey:@"selector"] response:[waitingSubscription valueForKey:@"onResponse"] error:[waitingSubscription valueForKey:@"onError"]];
            }
            else {
                [self addMessageListener:[waitingSubscription valueForKey:@"onResponse"] error:[waitingSubscription valueForKey:@"onError"]];
            }
        }
        else if ([[waitingSubscription valueForKey:@"event"] isEqualToString:PUB_SUB_COMMANDS]) {
            [self addCommandListener:[waitingSubscription valueForKey:@"onResponse"] error:[waitingSubscription valueForKey:@"onError"]];
        }
        else if ([[waitingSubscription valueForKey:@"event"] isEqualToString:PUB_SUB_USERS]) {
            [self addUserStatusListener:[waitingSubscription valueForKey:@"onResponse"] error:[waitingSubscription valueForKey:@"onError"]];
        }
    }
    [self.waitingSubscriptions removeAllObjects];
}

@end
