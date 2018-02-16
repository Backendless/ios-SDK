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
@end

@implementation SharedObject

-(instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        self.name = name;
        self.rt = [[RTSharedObject alloc] initWithName:name];
        self.isConnected = NO;
    }
    return self;
}

-(instancetype)connect:(NSString *)name {
    return [sharedObjectService connect:name];
}

-(void)setInvocationTarget:(id)invocationTarget {
    self.rt.invocationTarget = invocationTarget;
}

-(void)connect {
    __weak __typeof__(self) weakSelf = self;
    [self.rt connect:^(id result) {
        __typeof__(self) strongSelf = weakSelf;
        strongSelf.isConnected = YES;
    }];
}

-(void)disconnect {
    [self removeConnectListeners];
    [self removeChangesListeners];
    [self removeClearListeners];
    [self removeCommandListeners];
    [self removeUserStatusListeners];
    [self removeInvokeListeners];
    self.isConnected = NO;
}

-(void)addConnectListener:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    [self.rt addConnectListener:self.isConnected response:responseBlock error:errorBlock];
}

-(void)removeConnectListeners:(void(^)(void))responseBlock {
    [self.rt removeConnectListener:responseBlock];
}

-(void)removeConnectListeners {
    [self.rt removeConnectListener:nil];
}

-(void)addChangesListener:(void(^)(SharedObjectChanges *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self.rt addChangesListener:responseBlock error:errorBlock];
}

-(void)removeChangesListeners:(void(^)(SharedObjectChanges *))responseBlock {
    [self.rt removeChangesListener:responseBlock];
}

-(void)removeChangesListeners {
    [self.rt removeChangesListener:nil];
}

-(void)addClearListener:(void(^)(UserInfo *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self.rt addClearListener:responseBlock error:errorBlock];
}

-(void)removeClearListeners:(void(^)(UserInfo *))responseBlock {
    [self.rt removeClearListener:responseBlock];
}

-(void)removeClearListeners {
    [self.rt removeClearListener:nil];
}

-(void)addCommandListener:(void(^)(CommandObject *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self.rt addCommandListener:responseBlock error:errorBlock];
}

-(void)removeCommandListeners:(void(^)(CommandObject *))responseBlock {
    [self.rt removeCommandListener:responseBlock];
}

-(void)removeCommandListeners {
    [self.rt removeCommandListener:nil];
}

-(void)addUserStatusListener:(void(^)(UserStatusObject *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self.rt addUserStatusListener:responseBlock error:errorBlock];
}

-(void)removeUserStatusListeners:(void(^)(UserStatusObject *))responseBlock {
    [self.rt removeUserStatusListener:responseBlock];
}

-(void)removeUserStatusListeners {
    [self.rt removeUserStatusListener:nil];
}

-(void)addInvokeListener:(void(^)(InvokeObject *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self.rt addInvokeListener:responseBlock error:errorBlock];
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
