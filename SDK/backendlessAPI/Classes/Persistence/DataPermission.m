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

#define FAULT_NO_ENTITY [Fault fault:@"Entity is not valid"]
#define FAULT_NO_USER_ID [Fault fault:@"UserId is not valid"]
#define FAULT_NO_ROLE_NAME [Fault fault:@"RoleName is not valid"]
#define FAULT_OBJECT_ID_IS_NOT_EXIST [Fault fault:@"Object ID does not exist"]

#define DATA_PERMISSION_OPERATION @[@"UPDATE", @"FIND", @"REMOVE"]

// SERVICE NAME
static NSString *SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH = @"com.backendless.services.persistence.permissions.ClientPermissionService";
// METHOD NAMES
static NSString *METHOD_UPDATE_USER_PERMISSION = @"updateUserPermission";
static NSString *METHOD_UPDATE_ROLE_PERMISSION = @"updateRolePermission";
static NSString *METHOD_UPDATE_ALL_USER_PERMISSION = @"updateAllUserPermission";
static NSString *METHOD_UPDATE_ALL_ROLE_PERMISSION = @"updateAllRolePermission";
// PERMISSION TYPES
static NSString *_GRANT = @"GRANT";
static NSString *_DENY = @"DENY";

@implementation DataPermission

#pragma mark -
#pragma mark Private Methods

-(id)getEntityId:(id)object {
    NSString *objectId = [backendless.persistenceService getObjectId:object];
    return [objectId isKindOfClass:[NSString class]]?objectId:object;
}


#pragma mark -
#pragma mark Public Methods

// sync methods with fault return (as exception)

-(id)grantForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation {
    
    if (!userId)
        return [backendless throwFault:FAULT_NO_USER_ID];
    
    id sid = [self getEntityId:entity];
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[[backendless.data objectClassName:entity], userId, sid, DATA_PERMISSION_OPERATION[operation], _GRANT];
    return [invoker invokeSync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_USER_PERMISSION args:args];
}

-(id)denyForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation {
    
    if (!userId)
        return [backendless throwFault:FAULT_NO_USER_ID];
    
    id sid = [self getEntityId:entity];
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[[backendless.data objectClassName:entity], userId, sid, DATA_PERMISSION_OPERATION[operation], _DENY];
    return [invoker invokeSync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_USER_PERMISSION args:args];
}

-(id)grantForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation {
    
    if (!roleName)
        return [backendless throwFault:FAULT_NO_ROLE_NAME];
    
    id sid = [self getEntityId:entity];
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[[backendless.data objectClassName:entity], roleName, sid, DATA_PERMISSION_OPERATION[operation], _GRANT];
    return [invoker invokeSync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ROLE_PERMISSION args:args];
}

-(id)denyForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation {
    
    if (!roleName)
        return [backendless throwFault:FAULT_NO_ROLE_NAME];
    
    id sid = [self getEntityId:entity];
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[[backendless.data objectClassName:entity], roleName, sid, DATA_PERMISSION_OPERATION[operation], _DENY];
    return [invoker invokeSync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ROLE_PERMISSION args:args];
}

-(id)grantForAllUsers:(id)entity operation:(DataPermissionOperation)operation {
    
    id sid = [self getEntityId:entity];
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[[backendless.data objectClassName:entity], sid, DATA_PERMISSION_OPERATION[operation], _GRANT];
    return [invoker invokeSync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_USER_PERMISSION args:args];
}

-(id)denyForAllUsers:(id)entity operation:(DataPermissionOperation)operation {
    
    id sid = [self getEntityId:entity];
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[[backendless.data objectClassName:entity], sid, DATA_PERMISSION_OPERATION[operation], _DENY];
    return [invoker invokeSync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_USER_PERMISSION args:args];
}

-(id)grantForAllRoles:(id)entity operation:(DataPermissionOperation)operation {
    
    id sid = [self getEntityId:entity];
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[[backendless.data objectClassName:entity], sid, DATA_PERMISSION_OPERATION[operation], _GRANT];
    return [invoker invokeSync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_ROLE_PERMISSION args:args];
}

-(id)denyForAllRoles:(id)entity operation:(DataPermissionOperation)operation {
    
    id sid = [self getEntityId:entity];
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[[backendless.data objectClassName:entity], sid, DATA_PERMISSION_OPERATION[operation], _DENY];
    return [invoker invokeSync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_ROLE_PERMISSION args:args];
}

// async methods with responder

-(void)grantForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation responder:(id <IResponder>)responder {
    
    if (!userId)
        return [responder errorHandler:FAULT_NO_USER_ID];
    
    id sid = [self getEntityId:entity];
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[[backendless.data objectClassName:entity], userId, sid, DATA_PERMISSION_OPERATION[operation], _GRANT];
    return [invoker invokeAsync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_USER_PERMISSION args:args responder:responder];
}

-(void)denyForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation responder:(id <IResponder>)responder {
    
    if (!userId)
        return [responder errorHandler:FAULT_NO_USER_ID];
    
    id sid = [self getEntityId:entity];
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[[backendless.data objectClassName:entity], userId, sid, DATA_PERMISSION_OPERATION[operation], _DENY];
    return [invoker invokeAsync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_USER_PERMISSION args:args responder:responder];
}

-(void)grantForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation responder:(id <IResponder>)responder {
    
    if (!roleName)
        return [responder errorHandler:FAULT_NO_ROLE_NAME];
    
    id sid = [self getEntityId:entity];
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[[backendless.data objectClassName:entity], roleName, sid, DATA_PERMISSION_OPERATION[operation], _GRANT];
    return [invoker invokeAsync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ROLE_PERMISSION args:args responder:responder];
}

-(void)denyForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation responder:(id <IResponder>)responder {
    
    if (!roleName)
        return [responder errorHandler:FAULT_NO_ROLE_NAME];
    
    id sid = [self getEntityId:entity];
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[[backendless.data objectClassName:entity], roleName, sid, DATA_PERMISSION_OPERATION[operation], _DENY];
    return [invoker invokeAsync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ROLE_PERMISSION args:args responder:responder];
}

-(void)grantForAllUsers:(id)entity operation:(DataPermissionOperation)operation responder:(id <IResponder>)responder {
    
    id sid = [self getEntityId:entity];
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[[backendless.data objectClassName:entity], sid, DATA_PERMISSION_OPERATION[operation], _GRANT];
    return [invoker invokeAsync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_USER_PERMISSION args:args responder:responder];
}

-(void)denyForAllUsers:(id)entity operation:(DataPermissionOperation)operation responder:(id <IResponder>)responder {
    
    id sid = [self getEntityId:entity];
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[[backendless.data objectClassName:entity], sid, DATA_PERMISSION_OPERATION[operation], _DENY];
    return [invoker invokeAsync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_USER_PERMISSION args:args responder:responder];
}

-(void)grantForAllRoles:(id)entity operation:(DataPermissionOperation)operation responder:(id <IResponder>)responder {
    
    id sid = [self getEntityId:entity];
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[[backendless.data objectClassName:entity], sid, DATA_PERMISSION_OPERATION[operation], _GRANT];
    return [invoker invokeAsync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_ROLE_PERMISSION args:args responder:responder];
}

-(void)denyForAllRoles:(id)entity operation:(DataPermissionOperation)operation responder:(id <IResponder>)responder {
    
    id sid = [self getEntityId:entity];
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[[backendless.data objectClassName:entity], sid, DATA_PERMISSION_OPERATION[operation], _DENY];
    return [invoker invokeAsync:SERVER_PERSISTENCE_PERMISSIONS_SERVICE_PATH method:METHOD_UPDATE_ALL_ROLE_PERMISSION args:args responder:responder];
}

// async methods with block-based callbacks

-(void)grantForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self grantForUser:userId entity:entity operation:operation responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)denyForUser:(NSString *)userId entity:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self denyForUser:userId entity:entity operation:operation responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)grantForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self grantForRole:roleName entity:entity operation:operation responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)denyForRole:(NSString *)roleName entity:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self denyForRole:roleName entity:entity operation:operation responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)grantForAllUsers:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self grantForAllUsers:entity operation:operation responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)denyForAllUsers:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self denyForAllUsers:entity operation:operation responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)grantForAllRoles:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self grantForAllRoles:entity operation:operation responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)denyForAllRoles:(id)entity operation:(DataPermissionOperation)operation response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self denyForAllRoles:entity operation:operation responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

@end
