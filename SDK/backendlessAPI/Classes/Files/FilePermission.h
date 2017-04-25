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
    FILE_READ,
    FILE_WRITE,
    FILE_REMOVE,
} FilePermissionOperation;

@class Fault;

@interface FilePermission : NSObject

// sync methods with fault return (as exception)
-(id)grantForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation;
-(id)denyForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation;
-(id)grantForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation;
-(id)denyForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation;
-(id)grantForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation;
-(id)denyForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation;
-(id)grantForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation;
-(id)denyForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation;

// async methods with block-based callbacks
-(void)grantForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)denyForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)grantForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)denyForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)grantForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)denyForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)grantForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)denyForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;

@end
