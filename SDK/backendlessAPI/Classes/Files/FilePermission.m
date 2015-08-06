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

// SERVICE NAME
static NSString *SERVER_FILE_PERMISSIONS_SERVICE_PATH = @"com.backendless.services.file.FileService";
// METHOD NAMES
static NSString *METHOD_UPDATE_USER_PERMISSION = @"updateUserPermission";
static NSString *METHOD_UPDATE_ROLE_PERMISSION = @"updateRolePermissions";
static NSString *METHOD_UPDATE_ALL_USER_PERMISSION = @"updatePermissionForAllUsers";
static NSString *METHOD_UPDATE_ALL_ROLE_PERMISSION = @"updateRolePermissionsForAllRoles";
// PERMISSION TYPES
static NSString *_GRANT = @"GRANT";
static NSString *_DENY = @"DENY";

#pragma mark -
#pragma mark Private Classes

// -------------------------------------- PRIVATE CLASSES -------------------------------------------

@interface Permission : NSObject
@property (strong, nonatomic) NSString *folder;
@property (strong, nonatomic) NSString *access;
@property (strong, nonatomic) NSString *operation;
@end

@implementation Permission
@end

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

// ------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public Class

@implementation FilePermission

-(id)init {
    if ( (self=[super init]) ) {
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.file.permissions.FileUserPermission" mapped:[FileUserPermission class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.file.permissions.FileRolePermission" mapped:[FileRolePermission class]];
    }
    
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC FilePermission"];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Private Methods

-(BOOL)isUrlValid:(NSString *)url {
    return (url != nil);
}

#pragma mark -
#pragma mark Public Methods

// sync methods with fault return (as exception)

-(id)grantForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation {
    
    if (!userId)
        return [backendless throwFault:FAULT_NO_USER_ID];
    
    if (![self isUrlValid:url])
        return [backendless throwFault:FAULT_NO_URL];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, userId, [FileUserPermission grant:url operation:operation]];
    return [invoker invokeSync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_USER_PERMISSION args:args];
}

-(id)denyForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation {
    
    if (!userId)
        return [backendless throwFault:FAULT_NO_USER_ID];
    
    if (![self isUrlValid:url])
        return [backendless throwFault:FAULT_NO_URL];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, userId, [FileUserPermission deny:url operation:operation]];
    return [invoker invokeSync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_USER_PERMISSION args:args];
}

-(id)grantForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation {
    
    if (!roleName)
    return [backendless throwFault:FAULT_NO_ROLE_NAME];
    
    if (![self isUrlValid:url])
        return [backendless throwFault:FAULT_NO_URL];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, roleName, [FileRolePermission grant:url operation:operation]];
    return [invoker invokeSync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ROLE_PERMISSION args:args];
}

-(id)denyForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation {
    
    if (!roleName)
    return [backendless throwFault:FAULT_NO_ROLE_NAME];
    
    if (![self isUrlValid:url])
        return [backendless throwFault:FAULT_NO_URL];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, roleName, [FileRolePermission deny:url operation:operation]];
    return [invoker invokeSync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ROLE_PERMISSION args:args];
}

-(id)grantForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation {
    
    if (![self isUrlValid:url])
        return [backendless throwFault:FAULT_NO_URL];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, [FileUserPermission grant:url operation:operation]];
    return [invoker invokeSync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_USER_PERMISSION args:args];
}

-(id)denyForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation {
    
    if (![self isUrlValid:url])
        return [backendless throwFault:FAULT_NO_URL];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, [FileUserPermission deny:url operation:operation]];
    return [invoker invokeSync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_USER_PERMISSION args:args];
}

-(id)grantForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation {
    
    if (![self isUrlValid:url])
        return [backendless throwFault:FAULT_NO_URL];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, [FileRolePermission grant:url operation:operation]];
    return [invoker invokeSync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_ROLE_PERMISSION args:args];
}

-(id)denyForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation {
    
    if (![self isUrlValid:url])
        return [backendless throwFault:FAULT_NO_URL];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, [FileRolePermission deny:url operation:operation]];
    return [invoker invokeSync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_ROLE_PERMISSION args:args];
}

// sync methods with fault option

-(BOOL)grantForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation error:(Fault **)fault {
    
    id result = [self grantForUser:userId url:url operation:operation];
    if (![result isKindOfClass:[Fault class]])
        return YES;
    
    (*fault) = result;
    return NO;
}

-(BOOL)denyForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation error:(Fault **)fault {
    
    id result = [self denyForUser:userId url:url operation:operation];
    if (![result isKindOfClass:[Fault class]])
        return YES;
    
    (*fault) = result;
    return NO;
}

-(BOOL)grantForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation error:(Fault **)fault {
    
    id result = [self grantForRole:roleName url:url operation:operation];
    if (![result isKindOfClass:[Fault class]])
        return YES;
    
    (*fault) = result;
    return NO;
}

-(BOOL)denyForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation error:(Fault **)fault {
    
    id result = [self denyForRole:roleName url:url operation:operation];
    if (![result isKindOfClass:[Fault class]])
        return YES;
    
    (*fault) = result;
    return NO;
}

-(BOOL)grantForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation error:(Fault **)fault {
    
    id result = [self grantForAllUsers:url operation:operation];
    if (![result isKindOfClass:[Fault class]])
        return YES;
    
    (*fault) = result;
    return NO;
}

-(BOOL)denyForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation error:(Fault **)fault {
    
    id result = [self denyForAllUsers:url operation:operation];
    if (![result isKindOfClass:[Fault class]])
        return YES;
    
    (*fault) = result;
    return NO;
}

-(BOOL)grantForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation error:(Fault **)fault {
    
    id result = [self grantForAllRoles:url operation:operation];
    if (![result isKindOfClass:[Fault class]])
        return YES;
    
    (*fault) = result;
    return NO;
}

-(BOOL)denyForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation error:(Fault **)fault {
    
    id result = [self denyForAllRoles:url operation:operation];
    if (![result isKindOfClass:[Fault class]])
        return YES;
    
    (*fault) = result;
    return NO;
}

// async methods with responder

-(void)grantForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation responder:(id <IResponder>)responder {
    
    if (!userId)
        return [responder errorHandler:FAULT_NO_USER_ID];
    
    if (![self isUrlValid:url])
        return [responder errorHandler:FAULT_NO_URL];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, userId, [FileUserPermission grant:url operation:operation]];
    return [invoker invokeAsync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_USER_PERMISSION args:args responder:responder];
}

-(void)denyForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation responder:(id <IResponder>)responder {
    
    if (!userId)
        return [responder errorHandler:FAULT_NO_USER_ID];
    
    if (![self isUrlValid:url])
        return [responder errorHandler:FAULT_NO_URL];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, userId, [FileUserPermission deny:url operation:operation]];
    return [invoker invokeAsync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_USER_PERMISSION args:args responder:responder];
}

-(void)grantForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation responder:(id <IResponder>)responder {
    
    if (!roleName)
        return [responder errorHandler:FAULT_NO_ROLE_NAME];
    
    if (![self isUrlValid:url])
        return [responder errorHandler:FAULT_NO_URL];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, roleName, [FileRolePermission grant:url operation:operation]];
    return [invoker invokeAsync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ROLE_PERMISSION args:args responder:responder];
}

-(void)denyForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation responder:(id <IResponder>)responder {
    
    if (!roleName)
        return [responder errorHandler:FAULT_NO_ROLE_NAME];
    
    if (![self isUrlValid:url])
        return [responder errorHandler:FAULT_NO_URL];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, roleName, [FileRolePermission deny:url operation:operation]];
    return [invoker invokeAsync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ROLE_PERMISSION args:args responder:responder];
}

-(void)grantForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation responder:(id <IResponder>)responder {
    
    if (![self isUrlValid:url])
        return [responder errorHandler:FAULT_NO_URL];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, [FileUserPermission grant:url operation:operation]];
    return [invoker invokeAsync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_USER_PERMISSION args:args responder:responder];
}

-(void)denyForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation responder:(id <IResponder>)responder {
    
    if (![self isUrlValid:url])
        return [responder errorHandler:FAULT_NO_URL];
    
    NSArray *args = @[backendless.appID, backendless.versionNum,[FileUserPermission deny:url operation:operation]];
    return [invoker invokeAsync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_USER_PERMISSION args:args responder:responder];
}

-(void)grantForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation responder:(id <IResponder>)responder {
    
    if (![self isUrlValid:url])
        return [responder errorHandler:FAULT_NO_URL];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, [FileRolePermission grant:url operation:operation]];
    return [invoker invokeAsync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_ROLE_PERMISSION args:args responder:responder];
}

-(void)denyForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation responder:(id <IResponder>)responder {
    
    if (![self isUrlValid:url])
        return [responder errorHandler:FAULT_NO_URL];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, [FileRolePermission deny:url operation:operation]];
    return [invoker invokeAsync:SERVER_FILE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_ROLE_PERMISSION args:args responder:responder];
}

// async methods with block-based callbacks

-(void)grantForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self grantForUser:userId url:url operation:operation responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)denyForUser:(NSString *)userId url:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self denyForUser:userId url:url operation:operation responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)grantForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self grantForRole:roleName url:url operation:operation responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)denyForRole:(NSString *)roleName url:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self denyForRole:roleName url:url operation:operation responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)grantForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self grantForAllUsers:url operation:operation responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)denyForAllUsers:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self denyForAllUsers:url operation:operation responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)grantForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self grantForAllRoles:url operation:operation responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)denyForAllRoles:(NSString *)url operation:(FilePermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self denyForAllRoles:url operation:operation responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

@end
