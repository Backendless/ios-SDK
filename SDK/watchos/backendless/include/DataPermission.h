//
//  DataPermission.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
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
@class Fault;

typedef enum {
    DATA_UPDATE,
    DATA_FIND,
    DATA_REMOVE,
} DataPermissionOperation;

@interface DataPermission : NSObject

// sync methods with fault return (as exception)
-(void)grantForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation;
-(void)denyForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation;
-(void)grantForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation;
-(void)denyForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation;
-(void)grantForAllUsers:(id)entity operation:(DataPermissionOperation)operation;
-(void)denyForAllUsers:(id)entity operation:(DataPermissionOperation)operation;
-(void)grantForAllRoles:(id)entity operation:(DataPermissionOperation)operation;
-(void)denyForAllRoles:(id)entity operation:(DataPermissionOperation)operation;

// async methods with block-based callbacks
-(void)grantForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)denyForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)grantForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)denyForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)grantForAllUsers:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)denyForAllUsers:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)grantForAllRoles:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)denyForAllRoles:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;

@end
