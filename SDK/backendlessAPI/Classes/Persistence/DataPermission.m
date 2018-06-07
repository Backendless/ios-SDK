//
//  DataPermission.m
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

#import "DataPermission.h"
#import "DEBUG.h"
#import "Types.h"
#import "Responder.h"
#import "Backendless.h"
#import "Invoker.h"
#import "VoidResponseWrapper.h"

#define FAULT_NO_ENTITY [Fault fault:@"Entity is not valid"]
#define FAULT_NO_USER_ID [Fault fault:@"UserId is not valid"]
#define FAULT_NO_ROLE_NAME [Fault fault:@"RoleName is not valid"]
#define FAULT_OBJECT_ID_IS_NOT_EXIST [Fault fault:@"Object ID does not exist"]
#define DATA_PERMISSION_OPERATION @[@"UPDATE", @"FIND", @"REMOVE"]

static NSString *SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH = @"com.backendless.services.persistence.permissions.ClientPermissionService";
static NSString *_GRANT = @"GRANT";
static NSString *_DENY = @"DENY";
static NSString *METHOD_UPDATE_USER_PERMISSION = @"updateUserPermission";
static NSString *METHOD_UPDATE_ROLE_PERMISSION = @"updateRolePermission";
static NSString *METHOD_UPDATE_ALL_USER_PERMISSION = @"updateAllUserPermission";
static NSString *METHOD_UPDATE_ALL_ROLE_PERMISSION = @"updateAllRolePermission";

@implementation DataPermission

-(id)getEntityId:(id)object {
    NSString *objectId = [backendless.persistenceService getObjectId:object];
    return [objectId isKindOfClass:[NSString class]]?objectId:nil;
}

// sync methods with fault return (as exception)

-(void)grantForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation {
    if (!userId)
        [backendless throwFault:FAULT_NO_USER_ID];
    id sid = [self getEntityId:entity];
    if (!sid)
        [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    NSArray *args = @[[backendless.data objectClassName:entity], userId, sid, DATA_PERMISSION_OPERATION[operation], _GRANT];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_USER_PERMISSION args:args];
    if ([result isKindOfClass:[Fault class]]) {
        [backendless throwFault:result];
    }
}

-(void)denyForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation {
    if (!userId)
        [backendless throwFault:FAULT_NO_USER_ID];
    id sid = [self getEntityId:entity];
    if (!sid)
        [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    NSArray *args = @[[backendless.data objectClassName:entity], userId, sid, DATA_PERMISSION_OPERATION[operation], _DENY];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_USER_PERMISSION args:args];
    if ([result isKindOfClass:[Fault class]]) {
        [backendless throwFault:result];
    }
}

-(void)grantForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation {
    if (!roleName)
        [backendless throwFault:FAULT_NO_ROLE_NAME];
    id sid = [self getEntityId:entity];
    if (!sid)
        [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    NSArray *args = @[[backendless.data objectClassName:entity], roleName, sid, DATA_PERMISSION_OPERATION[operation], _GRANT];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ROLE_PERMISSION args:args];
    if ([result isKindOfClass:[Fault class]]) {
        [backendless throwFault:result];
    }
}

-(void)denyForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation {
    if (!roleName)
        [backendless throwFault:FAULT_NO_ROLE_NAME];
    id sid = [self getEntityId:entity];
    if (!sid)
        [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    NSArray *args = @[[backendless.data objectClassName:entity], roleName, sid, DATA_PERMISSION_OPERATION[operation], _DENY];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ROLE_PERMISSION args:args];
    if ([result isKindOfClass:[Fault class]]) {
        [backendless throwFault:result];
    }
}

-(void)grantForAllUsers:(id)entity operation:(DataPermissionOperation)operation {
    id sid = [self getEntityId:entity];
    if (!sid)
        [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    NSArray *args = @[[backendless.data objectClassName:entity], sid, DATA_PERMISSION_OPERATION[operation], _GRANT];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_USER_PERMISSION args:args];
    if ([result isKindOfClass:[Fault class]]) {
        [backendless throwFault:result];
    }
}

-(void)denyForAllUsers:(id)entity operation:(DataPermissionOperation)operation {
    id sid = [self getEntityId:entity];
    if (!sid)
        [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    NSArray *args = @[[backendless.data objectClassName:entity], sid, DATA_PERMISSION_OPERATION[operation], _DENY];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_USER_PERMISSION args:args];
    if ([result isKindOfClass:[Fault class]]) {
        [backendless throwFault:result];
    }
}

-(void)grantForAllRoles:(id)entity operation:(DataPermissionOperation)operation {
    id sid = [self getEntityId:entity];
    if (!sid)
        [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    NSArray *args = @[[backendless.data objectClassName:entity], sid, DATA_PERMISSION_OPERATION[operation], _GRANT];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_ROLE_PERMISSION args:args];
    if ([result isKindOfClass:[Fault class]]) {
        [backendless throwFault:result];
    }
}

-(void)denyForAllRoles:(id)entity operation:(DataPermissionOperation)operation {
    id sid = [self getEntityId:entity];
    if (!sid)
        [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    NSArray *args = @[[backendless.data objectClassName:entity], sid, DATA_PERMISSION_OPERATION[operation], _DENY];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_ROLE_PERMISSION args:args];
    if ([result isKindOfClass:[Fault class]]) {
        [backendless throwFault:result];
    }
}

// async methods with block-based callbacks

-(void)grantForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:[voidResponseWrapper wrapResponseBlock:responseBlock] error:errorBlock];
    if (!userId)
        return [responder errorHandler:FAULT_NO_USER_ID];
    id sid = [self getEntityId:entity];
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    NSArray *args = @[[backendless.data objectClassName:entity], userId, sid, DATA_PERMISSION_OPERATION[operation], _GRANT];
    [invoker invokeAsync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_USER_PERMISSION args:args responder:responder];
}

-(void)denyForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:[voidResponseWrapper wrapResponseBlock:responseBlock] error:errorBlock];
    if (!userId)
        return [responder errorHandler:FAULT_NO_USER_ID];
    id sid = [self getEntityId:entity];
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    NSArray *args = @[[backendless.data objectClassName:entity], userId, sid, DATA_PERMISSION_OPERATION[operation], _DENY];
    [invoker invokeAsync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_USER_PERMISSION args:args responder:responder];
}

-(void)grantForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:[voidResponseWrapper wrapResponseBlock:responseBlock] error:errorBlock];
    if (!roleName)
        return [responder errorHandler:FAULT_NO_ROLE_NAME];
    id sid = [self getEntityId:entity];
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    NSArray *args = @[[backendless.data objectClassName:entity], roleName, sid, DATA_PERMISSION_OPERATION[operation], _GRANT];
    [invoker invokeAsync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ROLE_PERMISSION args:args responder:responder];
}

-(void)denyForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:[voidResponseWrapper wrapResponseBlock:responseBlock] error:errorBlock];
    if (!roleName)
        return [responder errorHandler:FAULT_NO_ROLE_NAME];
    id sid = [self getEntityId:entity];
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    NSArray *args = @[[backendless.data objectClassName:entity], roleName, sid, DATA_PERMISSION_OPERATION[operation], _DENY];
    [invoker invokeAsync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ROLE_PERMISSION args:args responder:responder];
}

-(void)grantForAllUsers:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:[voidResponseWrapper wrapResponseBlock:responseBlock] error:errorBlock];
    id sid = [self getEntityId:entity];
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    NSArray *args = @[[backendless.data objectClassName:entity], sid, DATA_PERMISSION_OPERATION[operation], _GRANT];
    [invoker invokeAsync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_USER_PERMISSION args:args responder:responder];
}

-(void)denyForAllUsers:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:[voidResponseWrapper wrapResponseBlock:responseBlock] error:errorBlock];
    id sid = [self getEntityId:entity];
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    NSArray *args = @[[backendless.data objectClassName:entity], sid, DATA_PERMISSION_OPERATION[operation], _DENY];
    [invoker invokeAsync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_USER_PERMISSION args:args responder:responder];
}

-(void)grantForAllRoles:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:[voidResponseWrapper wrapResponseBlock:responseBlock] error:errorBlock];
    id sid = [self getEntityId:entity];
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    NSArray *args = @[[backendless.data objectClassName:entity], sid, DATA_PERMISSION_OPERATION[operation], _GRANT];
    [invoker invokeAsync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_ROLE_PERMISSION args:args responder:responder];
}

-(void)denyForAllRoles:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:[voidResponseWrapper wrapResponseBlock:responseBlock] error:errorBlock];
    id sid = [self getEntityId:entity];
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];    
    NSArray *args = @[[backendless.data objectClassName:entity], sid, DATA_PERMISSION_OPERATION[operation], _DENY];
    [invoker invokeAsync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_ROLE_PERMISSION args:args responder:responder];
}

@end
