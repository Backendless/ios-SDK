//
//  SharedObject.m
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

#import "SharedObject.h"
#import "RTSharedObject.h"
#import "SharedObjectService.h"

@interface SharedObject()
@property (strong, nonatomic, readwrite) NSString *name;
@property (strong, nonatomic) RTSharedObject *rt;
@property (nonatomic, readwrite) BOOL isConnected;
@property (nonatomic) BOOL rememberCommands;
@property (nonatomic, readwrite) NSMutableArray *waitingSubscriptions;
@property (nonatomic, readwrite) NSMutableArray *waitingCommands;
@end

@implementation SharedObject

-(instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        self.name = name;
        self.rt = [[RTSharedObject alloc] initWithName:name];
        self.isConnected = NO;
        self.rememberCommands = YES;
        self.waitingSubscriptions = [NSMutableArray new];
        self.waitingCommands = [NSMutableArray new];
    }
    return self;
}

-(instancetype)connect:(NSString *)name {
    return [sharedObjectService connect:name];
}

-(void)connect {
    __weak __typeof__(self) weakSelf = self;
    [self.rt connect:^(id result) {
        __typeof__(self) strongSelf = weakSelf;
        strongSelf.isConnected = YES;        
        for (NSDictionary *waitingSubscription in self.waitingSubscriptions) {
            if ([[waitingSubscription valueForKey:@"event"] isEqualToString:RSO_CONNECT]) {
                void(^onConnectResponse)(void) = [waitingSubscription valueForKey:@"onConnectResponse"];
                onConnectResponse();
            }
        }
        [self subscribeForWaitingListeners];
        [self callWaitingCommands];
    } onError: ^(Fault *fault) {
        for (NSDictionary *waitingSubscription in self.waitingSubscriptions) {
            if ([[waitingSubscription valueForKey:@"event"] isEqualToString:RSO_CONNECT]) {
                void(^onError)(Fault *) = [waitingSubscription valueForKey:@"onError"];
                onError(fault);
            }
        }
    }];
}

-(void)setInvocationTarget:(id)invocationTarget {
    self.rt.invocationTarget = invocationTarget;
}

-(void)disconnect {
    [self removeConnectListeners];
    [self removeChangesListeners];
    [self removeClearListeners];
    [self removeCommandListeners];
    [self removeUserStatusListeners];
    [self removeInvokeListeners];
    self.isConnected = NO;
    self.rememberCommands = NO;
    [self.waitingSubscriptions removeAllObjects];
}

-(void)addConnectListener:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt addConnectListener:self.isConnected response:responseBlock error:errorBlock];
    }
    else {
        [self addWaitingListener:RSO_CONNECT connectResponse:responseBlock response:nil error:errorBlock];
    }
}

-(void)removeConnectListeners:(void(^)(void))responseBlock {
    [self.rt removeConnectListener:responseBlock];
}

-(void)removeConnectListeners {
    [self.rt removeConnectListener:nil];
}

-(void)addChangesListener:(void(^)(SharedObjectChanges *))responseBlock error:(void(^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt addChangesListener:responseBlock error:errorBlock];
    }
    else {
        [self addWaitingListener:RSO_CHANGES connectResponse:nil response:responseBlock error:errorBlock];
    }
}

-(void)removeChangesListeners:(void(^)(SharedObjectChanges *))responseBlock {
    [self.rt removeChangesListener:responseBlock];
}

-(void)removeChangesListeners {
    [self.rt removeChangesListener:nil];
}

-(void)addClearListener:(void(^)(UserInfo *))responseBlock error:(void(^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt addClearListener:responseBlock error:errorBlock];
    }
    else {
        [self addWaitingListener:RSO_CLEARED connectResponse:nil response:responseBlock error:errorBlock];
    }
}

-(void)removeClearListeners:(void(^)(UserInfo *))responseBlock {
    [self.rt removeClearListener:responseBlock];
}

-(void)removeClearListeners {
    [self.rt removeClearListener:nil];
}

-(void)addCommandListener:(void(^)(CommandObject *))responseBlock error:(void(^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt addCommandListener:responseBlock error:errorBlock];
    }
    else {
        [self addWaitingListener:RSO_COMMANDS connectResponse:nil response:responseBlock error:errorBlock];
    }
}

-(void)removeCommandListeners:(void(^)(CommandObject *))responseBlock {
    [self.rt removeCommandListener:responseBlock];
}

-(void)removeCommandListeners {
    [self.rt removeCommandListener:nil];
}

-(void)addUserStatusListener:(void(^)(UserStatusObject *))responseBlock error:(void(^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt addUserStatusListener:responseBlock error:errorBlock];
    }
    else {
        [self addWaitingListener:RSO_USERS connectResponse:nil response:responseBlock error:errorBlock];
    }
}

-(void)removeUserStatusListeners:(void(^)(UserStatusObject *))responseBlock {
    [self.rt removeUserStatusListener:responseBlock];
}

-(void)removeUserStatusListeners {
    [self.rt removeUserStatusListener:nil];
}

-(void)addInvokeListener:(void(^)(InvokeObject *))responseBlock error:(void(^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt addInvokeListener:responseBlock error:errorBlock];
    }
    else {
        [self addWaitingListener:RSO_INVOKE connectResponse:nil response:responseBlock error:errorBlock];
    }
}

-(void)removeInvokeListeners:(void(^)(InvokeObject *))responseBlock {
    [self.rt removeInvokeListener:responseBlock];
}

-(void)removeInvokeListeners {
    [self.rt removeInvokeListener:nil];
}

-(void)removeAllListeners {
    [self removeConnectListeners];
    [self removeChangesListeners];
    [self removeClearListeners];
    [self removeCommandListeners];
    [self removeUserStatusListeners];
    [self removeInvokeListeners];
}

-(void)addWaitingListener:(NSString *)event connectResponse:(void(^)(void))connectResponseBlock response:(void(^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    NSDictionary *waitingObject;
    if (connectResponseBlock) {
        waitingObject = @{@"event"                : event,
                          @"onConnectResponse"    : connectResponseBlock,
                          @"onError"              : errorBlock};
    }
    else if (responseBlock) {
        waitingObject = @{@"event"                : event,
                          @"onResponse"           : responseBlock,
                          @"onError"              : errorBlock};
    }
    [self.waitingSubscriptions addObject:waitingObject];
}

-(void)subscribeForWaitingListeners {
    for (NSDictionary *waitingSubscription in self.waitingSubscriptions) {
        if ([[waitingSubscription valueForKey:@"event"] isEqualToString:RSO_CHANGES]) {
            [self addChangesListener:[waitingSubscription valueForKey:@"onResponse"] error:[waitingSubscription valueForKey:@"onError"]];
        }
        else if ([[waitingSubscription valueForKey:@"event"] isEqualToString:RSO_CLEARED]) {
            [self addClearListener:[waitingSubscription valueForKey:@"onResponse"] error:[waitingSubscription valueForKey:@"onError"]];
        }
        else if ([[waitingSubscription valueForKey:@"event"] isEqualToString:RSO_COMMANDS]) {
            [self addCommandListener:[waitingSubscription valueForKey:@"onResponse"] error:[waitingSubscription valueForKey:@"onError"]];
        }
        else if ([[waitingSubscription valueForKey:@"event"] isEqualToString:RSO_USERS]) {
            [self addUserStatusListener:[waitingSubscription valueForKey:@"onResponse"] error:[waitingSubscription valueForKey:@"onError"]];
        }
        else if ([[waitingSubscription valueForKey:@"event"] isEqualToString:RSO_INVOKE]) {
            [self addInvokeListener:[waitingSubscription valueForKey:@"onResponse"] error:[waitingSubscription valueForKey:@"onError"]];
        }
    }
    [self.waitingSubscriptions removeAllObjects];
}

// commands

-(void)get:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt get:nil onSuccess:responseBlock onError:errorBlock];
    }
    else if (self.rememberCommands) {
        NSDictionary *waitingCommand = @{@"event"       : RSO_GET,
                                         @"onResponse"  : responseBlock,
                                         @"onError"     : errorBlock};
        [self.waitingCommands addObject:waitingCommand];
    }
}

-(void)get:(NSString *)key response:(void(^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt get:key onSuccess:responseBlock onError:errorBlock];
    }
    else if (self.rememberCommands) {
        NSDictionary *waitingCommand = @{@"event"       : RSO_GET,
                                         @"onResponse"  : responseBlock,
                                         @"onError"     : errorBlock};
        if (key) {
            waitingCommand = @{@"event"         : RSO_GET,
                               @"key"           : key,
                               @"onResponse"    : responseBlock,
                               @"onError"       : errorBlock};
        }
        [self.waitingCommands addObject:waitingCommand];
    }
}

-(void)set:(NSString *)key data:(id)data response:(void(^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt set:key data:data onSuccess:responseBlock onError:errorBlock];
    }
    else if (self.rememberCommands) {
        NSDictionary *waitingCommand = @{@"event"       : RSO_SET,
                                         @"onResponse"  : responseBlock,
                                         @"onError"     : errorBlock};
        if (data) {
            waitingCommand = @{@"event"         : RSO_SET,
                               @"data"          : data,
                               @"onResponse"    : responseBlock,
                               @"onError"       : errorBlock};
        }
        [self.waitingCommands addObject:waitingCommand];
    }
}

-(void)clear:(void(^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt clear:responseBlock onError:errorBlock];
    }
    else if (self.rememberCommands) {
        NSDictionary *waitingCommand = @{@"event"       : RSO_CLEAR,
                                         @"onResponse"  : responseBlock,
                                         @"onError"     : errorBlock};
        [self.waitingCommands addObject:waitingCommand];
    }
}

-(void)sendCommand:(NSString *)commandName data:(id)data response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt sendCommand:commandName data:data onSuccess:responseBlock onError:errorBlock];
    }
    else if (self.rememberCommands) {
        NSDictionary *waitingCommand = @{@"event"       : RSO_COMMAND,
                                         @"commandName" : commandName,
                                         @"onResponse"  : responseBlock,
                                         @"onError"     : errorBlock};
        if (data) {
            waitingCommand = @{@"event"         : RSO_COMMAND,
                               @"commandName"   : commandName,
                               @"data"          : data,
                               @"onResponse"    : responseBlock,
                               @"onError"       : errorBlock};
        }
        [self.waitingCommands addObject:waitingCommand];
    }
}

-(void)invokeOn:(NSString *)method targets:(NSArray *)targets args:(NSArray *)args response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt invoke:method targets:targets args:args onSuccess:responseBlock onError:errorBlock];
    }
    else if (self.rememberCommands) {
        NSDictionary *waitingCommand = @{@"event"       : RSO_INVOKE,
                                         @"method"      : method,
                                         @"onResponse"  : responseBlock,
                                         @"onError"     : errorBlock};
        if (targets) {
            waitingCommand = @{@"event"         : RSO_INVOKE,
                               @"method"        : method,
                               @"targets"       : targets,
                               @"onResponse"    : responseBlock,
                               @"onError"       : errorBlock};
        }
        if (args) {
            waitingCommand = @{@"event"         : RSO_INVOKE,
                               @"method"        : method,
                               @"args"          : args,
                               @"onResponse"    : responseBlock,
                               @"onError"       : errorBlock};
        }
        if (targets && args) {
            waitingCommand = @{@"event"         : RSO_INVOKE,
                               @"method"        : method,
                               @"targets"       : targets,
                               @"args"          : args,
                               @"onResponse"    : responseBlock,
                               @"onError"       : errorBlock};
        }
        [self.waitingCommands addObject:waitingCommand];
    }
}

-(void)invokeOn:(NSString *)method targets:(NSArray *)targets response:(void(^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt invoke:method targets:targets args:nil onSuccess:responseBlock onError:errorBlock];
    }
    else if (self.rememberCommands) {
        NSDictionary *waitingCommand = @{@"event"       : RSO_INVOKE,
                                         @"method"      : method,
                                         @"onResponse"  : responseBlock,
                                         @"onError"     : errorBlock};
        if (targets) {
            waitingCommand = @{@"event"         : RSO_INVOKE,
                               @"method"        : method,
                               @"targets"       : targets,
                               @"onResponse"    : responseBlock,
                               @"onError"       : errorBlock};
        }
        [self.waitingCommands addObject:waitingCommand];
    }
}

-(void)invoke:(NSString *)method args:(NSArray *)args response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt invoke:method targets:nil args:args onSuccess:responseBlock onError:errorBlock];
    }
    else if (self.rememberCommands) {
        NSDictionary *waitingCommand = @{@"event"       : RSO_INVOKE,
                                         @"method"      : method,
                                         @"onResponse"  : responseBlock,
                                         @"onError"     : errorBlock};
        if (args) {
            waitingCommand = @{@"event"         : RSO_INVOKE,
                               @"method"        : method,
                               @"args"          : args,
                               @"onResponse"    : responseBlock,
                               @"onError"       : errorBlock};
        }
        [self.waitingCommands addObject:waitingCommand];
    }
}

-(void)invoke:(NSString *)method response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt invoke:method targets:nil args:nil onSuccess:responseBlock onError:errorBlock];
    }
    else if (self.rememberCommands) {
        NSDictionary *waitingCommand = @{@"event"       : RSO_INVOKE,
                                         @"method"      : method,
                                         @"onResponse"  : responseBlock,
                                         @"onError"     : errorBlock};
        [self.waitingCommands addObject:waitingCommand];
    }
}

-(void)callWaitingCommands {
    for (NSDictionary *waitingCommand in self.waitingCommands) {
        if ([[waitingCommand valueForKey:@"event"] isEqualToString:RSO_GET]) {
            [self get:[waitingCommand valueForKey:@"key"] response:[waitingCommand valueForKey:@"onResponse"] error:[waitingCommand valueForKey:@"onError"]];
        }
        else if ([[waitingCommand valueForKey:@"event"] isEqualToString:RSO_SET]) {
            [self set:[waitingCommand valueForKey:@"key"] data:[waitingCommand valueForKey:@"data"] response:[waitingCommand valueForKey:@"onResponse"] error:[waitingCommand valueForKey:@"onError"]];
        }
        else if ([[waitingCommand valueForKey:@"event"] isEqualToString:RSO_CLEAR]) {
            [self clear:[waitingCommand valueForKey:@"onResponse"] error:[waitingCommand valueForKey:@"onError"]];
        }
        
        
        else if ([[waitingCommand valueForKey:@"event"] isEqualToString:RSO_INVOKE]) {
            if ([waitingCommand valueForKey:@"targets"]) {
                [self invokeOn:[waitingCommand valueForKey:@"method"] targets:[waitingCommand valueForKey:@"targets"] args:[waitingCommand valueForKey:@"args"] response:[waitingCommand valueForKey:@"onResponse"] error:[waitingCommand valueForKey:@"onError"]];
            }
            else {
                [self invoke:[waitingCommand valueForKey:@"method"] args:[waitingCommand valueForKey:@"args"] response:[waitingCommand valueForKey:@"onResponse"] error:[waitingCommand valueForKey:@"onError"]];
            }
        }
    }
}

@end
