//
//  RemoteSharedObject.m
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

#import "WeborbSharedObject.h"
#import "RTRSO.h"

@interface SharedObject()
@property (strong, nonatomic, readwrite) NSString *name;
@property (strong, nonatomic) RTRSO *rt;
@property (nonatomic, readwrite) BOOL isConnected;
@end

@implementation SharedObject

-(void)setInvocationTarget:(id)invocationTarget {
    self.rt.invocationTarget = invocationTarget;
}

-(instancetype)initWithRSOName:(NSString *)sharedObjectName {
    if (self = [super init]) {
        self.name = sharedObjectName;
        self.rt = [[RTRSO alloc] initWithRSOName:sharedObjectName];
        self.isConnected = NO;
        [self connect];
    }
    return self;
}

-(instancetype)connect:(NSString *)sharedObjectName {
    [self initWithRSOName:sharedObjectName];
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
        [self removeErrorListeners];
        [self removeConnectListeners];
        [self removeChangesListeners];
        [self removeClearListeners];
        [self removeCommandListeners];
        [self removeUserStatusListeners];
        [self removeInvokeListeners];
        self.isConnected = NO;
    }
}

-(void)addErrorListener:(void(^)(Fault *))errorBlock {
    [self.rt addErrorListener:errorBlock];
}

-(void)removeErrorListeners:(void(^)(Fault *))errorBlock {
    [self.rt removeErrorListener:errorBlock];
}

-(void)removeErrorListeners {
    [self.rt removeErrorListener:nil];
}

-(void)addConnectListener:(void(^)(void))onConnect {
    [self.rt addConnectListener:self.isConnected onConnect:onConnect];
}

-(void)removeConnectListeners:(void(^)(void))onConnect {
    [self.rt removeConnectListener:onConnect];
}

-(void)removeConnectListeners {
    [self.rt removeConnectListener:nil];
}

-(void)addChangesListener:(void(^)(SharedObjectChanges *))onChanges {
    [self.rt addChangesListener:onChanges];
}

-(void)removeChangesListeners:(void(^)(SharedObjectChanges *))onChanges {
    [self.rt removeChangesListener:onChanges];
}

-(void)removeChangesListeners {
    [self.rt removeChangesListener:nil];
}

-(void)addClearListener:(void(^)(RSOClearedObject *))onClear {
    [self.rt addClearListener:onClear];
}

-(void)removeClearListeners:(void(^)(RSOClearedObject *))onClear {
    [self.rt removeClearListener:onClear];
}

-(void)removeClearListeners {
    [self.rt removeClearListener:nil];
}

-(void)addCommandListener:(void(^)(CommandObject *))onCommand {
    [self.rt addCommandListener:onCommand];
}

-(void)removeCommandListeners:(void(^)(CommandObject *))onCommand {
    [self.rt removeCommandListener:onCommand];
}

-(void)removeCommandListeners {
    [self.rt removeCommandListener:nil];
}

-(void)addUserStatusListener:(void(^)(UserStatusObject *))onUserStatus {
    [self.rt addUserStatusListener:onUserStatus];
}

-(void)removeUserStatusListeners:(void(^)(UserStatusObject *))onUserStatus {
    [self.rt removeUserStatusListener:onUserStatus];
}

-(void)removeUserStatusListeners {
    [self.rt removeUserStatusListener:nil];
}

-(void)addInvokeListener:(void(^)(InvokeObject *))onInvoke {
    [self.rt addInvokeListener:onInvoke];
}

-(void)removeInvokeListeners:(void(^)(InvokeObject *))onInvoke {
    [self.rt removeInvokeListener:onInvoke];
}

-(void)removeInvokeListeners {
    [self.rt removeInvokeListener:nil];
}

-(void)removeAllListeners {
    [self removeErrorListeners];
    [self removeConnectListeners];
    [self removeChangesListeners];
    [self removeClearListeners];
    [self removeCommandListeners];
    [self removeUserStatusListeners];
    [self removeInvokeListeners];
}

-(void)get:(void (^)(id))onSuccess onError:(void (^)(Fault *))onError {
    [self.rt get:nil onSuccess:onSuccess onError:onError];
}

-(void)get:(NSString *)key onSuccess:(void(^)(id))onSuccess onError:(void (^)(Fault *))onError {
    [self.rt get:key onSuccess:onSuccess onError:onError];
}

-(void)set:(NSString *)key data:(id)data onSuccess:(void(^)(id))onSuccess onError:(void (^)(Fault *))onError {
    [self.rt set:key data:data onSuccess:onSuccess onError:onError];
}

-(void)clear:(void(^)(id))onSuccess onError:(void (^)(Fault *))onError {
    [self.rt clear:onSuccess onError:onError];
}

-(void)sendCommand:(NSString *)commandName data:(id)data onSuccess:(void (^)(id))onSuccess onError:(void (^)(Fault *))onError {
    [self.rt sendCommand:commandName data:data onSuccess:onSuccess onError:onError];
}

-(void)invokeOn:(NSString *)method targets:(NSArray *)targets args:(NSArray *)args onSuccess:(void (^)(id))onSuccess onError:(void (^)(Fault *))onError {
    [self.rt invoke:method targets:targets args:args onSuccess:onSuccess onError:onError];
}

-(void)invokeOn:(NSString *)method targets:(NSArray *)targets onSuccess:(void (^)(id))onSuccess onError:(void (^)(Fault *))onError {
    [self.rt invoke:method targets:targets args:nil onSuccess:onSuccess onError:onError];
}

-(void)invoke:(NSString *)method args:(NSArray *)args onSuccess:(void (^)(id))onSuccess onError:(void (^)(Fault *))onError {
    [self.rt invoke:method targets:nil args:args onSuccess:onSuccess onError:onError];
}

-(void)invoke:(NSString *)method onSuccess:(void (^)(id))onSuccess onError:(void (^)(Fault *))onError {
    [self.rt invoke:method targets:nil args:nil onSuccess:onSuccess onError:onError];
}

@end
