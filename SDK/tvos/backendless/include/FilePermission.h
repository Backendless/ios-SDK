//
//  FilePermission.h
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
    FILE_READ,
    FILE_WRITE,
    FILE_REMOVE,
} FilePermissionOperation;

@interface FilePermission : NSObject

// sync methods with fault return (as exception)
-(void)grantForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation;
-(void)denyForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation;
-(void)grantForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation;
-(void)denyForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation;
-(void)grantForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation;
-(void)denyForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation;
-(void)grantForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation;
-(void)denyForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation;

// async methods with block-based callbacks
-(void)grantForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)denyForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)grantForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)denyForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)grantForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)denyForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)grantForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)denyForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;

@end
