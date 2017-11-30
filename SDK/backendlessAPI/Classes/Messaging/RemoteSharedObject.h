//
//  RemoteSharedObject.h
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

#import <Foundation/Foundation.h>
#import "Responder.h"
#import "RSOChangesObject.h"
#import "RSOClearedObject.h"
#import "CommandObject.h"
#import "UserStatusObject.h"
#import "InvokeObject.h"

@interface RemoteSharedObject : NSObject

@property (strong, nonatomic, readonly) NSString *rsoName;
@property (nonatomic, readonly) BOOL isConnected;
@property (strong, nonatomic) id invocationTarget;

-(instancetype)initWithRSOName:(NSString *)rsoName;
-(void)connect;
-(void)disconnect;

-(void)addErrorListener:(void(^)(Fault *))errorBlock;
-(void)removeErrorListener:(void(^)(Fault *))errorBlock;
-(void)removeErrorListener;

-(void)addConnectListener:(void(^)(void))onConnect;
-(void)removeConnectListener:(void(^)(void))onConnect;
-(void)removeConnectListener;

-(void)addChangesListener:(void(^)(RSOChangesObject *))onChanges;
-(void)removeChangesListener:(void(^)(RSOChangesObject *))onChanges;
-(void)removeChangesListener;

-(void)addClearListener:(void(^)(RSOClearedObject *))onClear;
-(void)removeClearListener:(void(^)(RSOClearedObject *))onClear;
-(void)removeClearListener;

-(void)addCommandListener:(void(^)(CommandObject *))onCommand;
-(void)removeCommandListener:(void(^)(CommandObject *))onCommand;
-(void)removeCommandListener;

-(void)addUserStatusListener:(void(^)(UserStatusObject *))onUserStatus;
-(void)removeUserStatusListener:(void(^)(UserStatusObject *))onUserStatus;
-(void)removeUserStatusListener;

-(void)addInvokeListener:(void(^)(InvokeObject *))onInvoke;
-(void)removeInvokeListener:(void(^)(InvokeObject *))onInvoke;
-(void)removeInvokeListener;

-(void)removeAllListeners;

// commands

-(void)get:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError;
-(void)get:(NSString *)key onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError;
-(void)set:(NSString *)key data:(id)data onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError;
-(void)clear:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError;
-(void)sendCommand:(NSString *)commandName data:(id)data onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError;
-(void)invoke:(NSString *)method targets:(NSArray *)targets args:(NSArray *)args onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError;
-(void)invoke:(NSString *)method targets:(NSArray *)targets onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError;
-(void)invoke:(NSString *)method args:(NSArray *)args onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError;
-(void)invoke:(NSString *)method onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError;

@end
