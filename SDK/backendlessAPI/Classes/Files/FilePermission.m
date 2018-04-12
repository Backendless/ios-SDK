//
//  FilePermission.m
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

#import "FilePermission.h"
#import "DEBUG.h"
#import "Types.h"
#import "Responder.h"
#import "Backendless.h"
#import "Invoker.h"

#define FAULT_NO_URL [Fault fault:@"URL is not valid"]
#define FAULT_NO_USER_ID [Fault fault:@"UserId is not valid"]
#define FAULT_NO_ROLE_NAME [Fault fault:@"RoleName is not valid"]
#define FILE_PERMISSION_OPERATION @[@"READ", @"WRITE", @"DELETE"]

static NSString *SERVER_FILE_PERMISSIONS_SERVICE_PATH = @"com.backendless.services.file.FileService";
static NSString *METHOD_UPDATE_USER_PERMISSION = @"updateUserPermission";
static NSString *METHOD_UPDATE_ROLE_PERMISSION = @"updateRolePermissions";
static NSString *METHOD_UPDATE_ALL_USER_PERMISSION = @"updatePermissionForAllUsers";
static NSString *METHOD_UPDATE_ALL_ROLE_PERMISSION = @"updateRolePermissionsForAllRoles";
static NSString *_GRANT = @"GRANT";
static NSString *_DENY = @"DENY";

// ****************************************

@interface Permission : NSObject
@property (strong, nonatomic) NSString *folder;
@property (strong, nonatomic) NSString *access;
@property (strong, nonatomic) NSString *operation;
@end

@implementation Permission
@end

// ****************************************

@interface FileUserPermission : Permission

+(id)grant:(NSString *)url operation:(FilePermissionOperation)operation;
+(id)deny:(NSString *)url operation:(FilePermissionOperation)operation;

@end

@implementation FileUserPermission

+(id)grant:(NSString *)url operation:(FilePermissionOperation)operation {
    FileUserPermission *permission = [FileUserPermission new];
    permission.folder = url;
    permission.access = _GRANT;
    permission.operation = FILE_PERMISSION_OPERATION[operation];
    return [permission autorelease];
}

+(id)deny:(NSString *)url operation:(FilePermissionOperation)operation {
    FileUserPermission *permission = [FileUserPermission new];
    permission.folder = url;
    permission.access = _DENY;
    permission.operation = FILE_PERMISSION_OPERATION[operation];
    return [permission autorelease];
}

@end

// ****************************************

@interface FileRolePermission : Permission

+(id)grant:(NSString *)url operation:(FilePermissionOperation)operation;
+(id)deny:(NSString *)url operation:(FilePermissionOperation)operation;

@end

@implementation FileRolePermission

+(id)grant:(NSString *)url operation:(FilePermissionOperation)operation {
    FileRolePermission *permission = [FileRolePermission new];
    permission.folder = url;
    permission.access = _GRANT;
    permission.operation = FILE_PERMISSION_OPERATION[operation];
    return [permission autorelease];
}

+(id)deny:(NSString *)url operation:(FilePermissionOperation)operation {
    FileRolePermission *permission = [FileRolePermission new];
    permission.folder = url;
    permission.access = _DENY;
    permission.operation = FILE_PERMISSION_OPERATION[operation];
    return [permission autorelease];
}

@end

// ****************************************

@implementation FilePermission

-(id)init {
    if (self = [super init]) {
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.file.permissions.FileUserPermission" mapped:FileUserPermission.class];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.file.permissions.FileRolePermission" mapped:FileRolePermission.class];
    }
    return self;
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC FilePermission"];
    [super dealloc];
}

-(BOOL)isUrlValid:(NSString *)url {
    return (url != nil);
}

// sync methods with fault return (as exception)

-(id)grantForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation {
    if (!userId)
        return [backendless throwFault:FAULT_NO_USER_ID];
    if (![self isUrlValid:url])
        return [backendless throwFault:FAULT_NO_URL];
    NSArray *args = @[userId, [FileUserPermission grant:url operation:operation]];
    return [invoker invokeSync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_USER_PERMISSION args:args];
}

-(id)denyForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation {
    if (!userId)
        return [backendless throwFault:FAULT_NO_USER_ID];
    if (![self isUrlValid:url])
        return [backendless throwFault:FAULT_NO_URL];
    NSArray *args = @[userId, [FileUserPermission deny:url operation:operation]];
    return [invoker invokeSync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_USER_PERMISSION args:args];
}

-(id)grantForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation {
    if (!roleName)
        return [backendless throwFault:FAULT_NO_ROLE_NAME];
    if (![self isUrlValid:url])
        return [backendless throwFault:FAULT_NO_URL];
    NSArray *args = @[roleName, [FileRolePermission grant:url operation:operation]];
    return [invoker invokeSync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ROLE_PERMISSION args:args];
}

-(id)denyForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation {
    if (!roleName)
        return [backendless throwFault:FAULT_NO_ROLE_NAME];
    if (![self isUrlValid:url])
        return [backendless throwFault:FAULT_NO_URL];
    NSArray *args = @[roleName, [FileRolePermission deny:url operation:operation]];
    return [invoker invokeSync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ROLE_PERMISSION args:args];
}

-(id)grantForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation {
    if (![self isUrlValid:url])
        return [backendless throwFault:FAULT_NO_URL];
    NSArray *args = @[[FileUserPermission grant:url operation:operation]];
    return [invoker invokeSync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_USER_PERMISSION args:args];
}

-(id)denyForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation {
    
    if (![self isUrlValid:url])
        return [backendless throwFault:FAULT_NO_URL];
    
    NSArray *args = @[[FileUserPermission deny:url operation:operation]];
    return [invoker invokeSync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_USER_PERMISSION args:args];
}

-(id)grantForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation {
    if (![self isUrlValid:url])
        return [backendless throwFault:FAULT_NO_URL];
    NSArray *args = @[[FileRolePermission grant:url operation:operation]];
    return [invoker invokeSync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_ROLE_PERMISSION args:args];
}

-(id)denyForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation {
    if (![self isUrlValid:url])
        return [backendless throwFault:FAULT_NO_URL];
    NSArray *args = @[[FileRolePermission deny:url operation:operation]];
    return [invoker invokeSync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_ROLE_PERMISSION args:args];
}

// async methods with block-based callbacks

-(void)grantForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!userId)
        return [responder errorHandler:FAULT_NO_USER_ID];
    if (![self isUrlValid:url])
        return [responder errorHandler:FAULT_NO_URL];
    NSArray *args = @[userId, [FileUserPermission grant:url operation:operation]];
    return [invoker invokeAsync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_USER_PERMISSION args:args responder:responder];
}

-(void)denyForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!userId)
        return [responder errorHandler:FAULT_NO_USER_ID];
    if (![self isUrlValid:url])
        return [responder errorHandler:FAULT_NO_URL];
    NSArray *args = @[userId, [FileUserPermission deny:url operation:operation]];
    return [invoker invokeAsync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_USER_PERMISSION args:args responder:responder];
}

-(void)grantForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!roleName)
        return [responder errorHandler:FAULT_NO_ROLE_NAME];
    if (![self isUrlValid:url])
        return [responder errorHandler:FAULT_NO_URL];
    NSArray *args = @[roleName, [FileRolePermission grant:url operation:operation]];
    return [invoker invokeAsync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ROLE_PERMISSION args:args responder:responder];
}

-(void)denyForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!roleName)
        return [responder errorHandler:FAULT_NO_ROLE_NAME];
    if (![self isUrlValid:url])
        return [responder errorHandler:FAULT_NO_URL];
    NSArray *args = @[roleName, [FileRolePermission deny:url operation:operation]];
    return [invoker invokeAsync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ROLE_PERMISSION args:args responder:responder];
}

-(void)grantForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (![self isUrlValid:url])
        return [responder errorHandler:FAULT_NO_URL];
    NSArray *args = @[[FileUserPermission grant:url operation:operation]];
    return [invoker invokeAsync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_USER_PERMISSION args:args responder:responder];
}

-(void)denyForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (![self isUrlValid:url])
        return [responder errorHandler:FAULT_NO_URL];
    NSArray *args = @[[FileUserPermission deny:url operation:operation]];
    return [invoker invokeAsync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_USER_PERMISSION args:args responder:responder];
}

-(void)grantForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (![self isUrlValid:url])
        return [responder errorHandler:FAULT_NO_URL];
    NSArray *args = @[[FileRolePermission grant:url operation:operation]];
    return [invoker invokeAsync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_ROLE_PERMISSION args:args responder:responder];
}

-(void)denyForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (![self isUrlValid:url])
        return [responder errorHandler:FAULT_NO_URL];
    NSArray *args = @[[FileRolePermission deny:url operation:operation]];
    return [invoker invokeAsync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_ROLE_PERMISSION args:args responder:responder];
}

@end
