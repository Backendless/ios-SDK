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
 *  Copyright 2014 BACKENDLESS.COM. All Rights Reserved.
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

typedef enum {
    DATA_UPDATE,
    DATA_FIND,
    DATA_REMOVE,
} DataPermissionOperation;

@class Fault;

@interface DataPermission : NSObject

// sync methods with fault return (as exception)
-(id)grantForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation;
-(id)denyForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation;
-(id)grantForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation;
-(id)denyForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation;
-(id)grantForAllUsers:(id)entity operation:(DataPermissionOperation)operation;
-(id)denyForAllUsers:(id)entity operation:(DataPermissionOperation)operation;
-(id)grantForAllRoles:(id)entity operation:(DataPermissionOperation)operation;
-(id)denyForAllRoles:(id)entity operation:(DataPermissionOperation)operation;

// async methods with block-based callbacks
-(void)grantForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)denyForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)grantForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)denyForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)grantForAllUsers:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)denyForAllUsers:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)grantForAllRoles:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)denyForAllRoles:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;

@end
