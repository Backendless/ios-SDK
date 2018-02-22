//
//  SharedObject.h
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
#import "SharedObjectChanges.h"
#import "UserInfo.h"
#import "CommandObject.h"
#import "UserStatusObject.h"
#import "InvokeObject.h"

@interface SharedObject : NSObject

@property (strong, nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) BOOL isConnected;
@property (strong, nonatomic) id invocationTarget;

-(instancetype)initWithName:(NSString *)name;
-(instancetype)connect:(NSString *)name;
-(void)connect;
-(void)disconnect;

-(void)addConnectListener:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeConnectListeners:(void(^)(void))responseBlock;
-(void)removeConnectListeners;

-(void)addChangesListener:(void(^)(SharedObjectChanges *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeChangesListeners:(void(^)(SharedObjectChanges *))responseBlock;
-(void)removeChangesListeners;

-(void)addClearListener:(void(^)(UserInfo *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeClearListeners:(void(^)(UserInfo *))responseBlock;
-(void)removeClearListeners;

-(void)addCommandListener:(void(^)(CommandObject *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeCommandListeners:(void(^)(CommandObject *))responseBlock;
-(void)removeCommandListeners;

-(void)addUserStatusListener:(void(^)(UserStatusObject *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeUserStatusListeners:(void(^)(UserStatusObject *))responseBlock;
-(void)removeUserStatusListeners;

-(void)addInvokeListener:(void(^)(InvokeObject *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeInvokeListeners:(void(^)(InvokeObject *))responseBlock;
-(void)removeInvokeListeners;

-(void)removeAllListeners;

// commands

-(void)get:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)get:(NSString *)key response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)set:(NSString *)key data:(id)data response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)clear:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)sendCommand:(NSString *)commandName data:(id)data response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)invokeOn:(NSString *)method targets:(NSArray *)targets args:(NSArray *)args response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)invokeOn:(NSString *)method targets:(NSArray *)targets response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)invoke:(NSString *)method args:(NSArray *)args response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)invoke:(NSString *)method response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;

@end
