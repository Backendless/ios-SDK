//
//  MapDrivenDataStore.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2016 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "MapDrivenDataStore.h"
#include "Backendless.h"
#import "Invoker.h"
#include "Responder.h"
#import "ObjectProperty.h"
#import "ClassCastException.h"

#define FAULT_NO_ENTITY [Fault fault:@"Entity is missing or null" detail:@"Entity is missing or null" faultCode:@"1900"]
#define FAULT_OBJECT_ID_IS_NOT_EXIST [Fault fault:@"objectId is missing or null" detail:@"objectId is missing or null" faultCode:@"1901"]
#define FAULT_NAME_IS_NULL [Fault fault:@"Name is missing or null" detail:@"Name is missing or null" faultCode:@"1902"]


// SERVICE NAME
static NSString *_SERVER_PERSISTENCE_SERVICE_PATH = @"com.backendless.services.persistence.PersistenceService";
// METHOD NAMES
static NSString *_METHOD_SAVE = @"save";
static NSString *_METHOD_REMOVE = @"remove";
static NSString *_METHOD_FIND = @"find";
static NSString *_METHOD_FIRST = @"first";
static NSString *_METHOD_LAST = @"last";
static NSString *_METHOD_FINDBYID = @"findById";
static NSString *_METHOD_LOAD = @"loadRelations";

@implementation MapDrivenDataStore

-(id)init {
    if (self = [super init]) {
        _tableName = nil;
        [self setClassMapping];
    }
    return self;
}

-(id)init:(NSString *)tableName {
    if (self = [super init]) {
        _tableName = [tableName retain];
        [self setClassMapping];
    }
    return self;
}

+(id)createDataStore:(NSString *)tableName {
    return [[MapDrivenDataStore alloc] init:tableName];
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC MapDrivenDataStore"];
    [_tableName release];
    [super dealloc];
}

#pragma mark Private Methods

-(void)setClassMapping {
    if (backendless.data) {
        return;
    }
    [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.NSArray" mapped:[NSArray class]];
    [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.ObjectProperty" mapped:[ObjectProperty class]];
    [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.model.GeoPoint" mapped:[GeoPoint class]];
    [[Types sharedInstance] addClientClassMapping:@"java.lang.ClassCastException" mapped:[ClassCastException class]];
#if !_IS_USERS_CLASS_
    [[Types sharedInstance] addClientClassMapping:@"Users" mapped:[BackendlessUser class]];
#endif
}

-(NSArray *)fixClassCollection:(NSArray *)bc {
    if (bc.count && ![bc[0] isKindOfClass:NSDictionary.class]) {
        NSMutableArray *data = [NSMutableArray array];
        for (id item in bc) {
            [data addObject:[Types propertyDictionary:item]];
        }
        bc = [NSArray arrayWithArray:data];
    }
    return bc;
}

#pragma mark Public Methods

// sync methods with fault return (as exception)
-(NSDictionary<NSString *, id> *)save:(NSDictionary<NSString *, id> *)entity {
    if (!entity) {
        return [backendless throwFault:FAULT_NO_ENTITY];
    }
    NSArray *args = @[_tableName, entity];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_SAVE args:args];
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(NSNumber *)remove:(NSDictionary<NSString*,id> *)entity {
    if (!entity) {
        return [backendless throwFault:FAULT_NO_ENTITY];
    }
    NSArray *args = @[_tableName, entity];
    return [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_REMOVE args:args];
}

-(NSArray *)find {
    return [self find:BACKENDLESS_DATA_QUERY];
}

-(NSArray *)find:(BackendlessDataQuery *)dataQuery {
    NSArray *args = @[_tableName, dataQuery?dataQuery:BACKENDLESS_DATA_QUERY];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FIND args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    NSArray *bc = (NSArray *)result;
    return [self fixClassCollection:bc];
}

-(NSDictionary<NSString *, id> *)findFirst {
    NSArray *args = @[_tableName];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FIRST args:args];
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(NSDictionary<NSString *, id> *)findFirst:(int)relationsDepth {
    return [self findFirst:@[] relationsDepth:relationsDepth];
}

-(NSDictionary<NSString *, id> *)findFirstWithRelations:(NSArray<NSString *> *)relations {
    return [self findFirst:relations relationsDepth:0];
}

-(NSDictionary<NSString *, id> *)findFirst:(NSArray<NSString *> *)relations relationsDepth:(int)relationsDepth {
    NSArray *args = @[_tableName, relations?relations:@[], @(relationsDepth)];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FIRST args:args];
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(NSDictionary<NSString *, id> *)findLast {
    NSArray *args = @[_tableName];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_LAST args:args];
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(NSDictionary<NSString *, id> *)findLast:(int)relationsDepth {
    return [self findLast:@[] relationsDepth:relationsDepth];
}

-(NSDictionary<NSString *, id> *)findLastWithRelations:(NSArray<NSString *> *)relations {
    return [self findLast:relations relationsDepth:0];
}

-(NSDictionary<NSString *, id> *)findLast:(NSArray<NSString *> *)relations relationsDepth:(int)relationsDepth {
    NSArray *args = @[_tableName, relations?relations:@[], @(relationsDepth)];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_LAST args:args];
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(id)findById:(NSString *)objectID {
    return [self findById:objectID relations:@[]];
}

-(id)findById:(NSString *)objectID queryBuilder:(DataQueryBuilder *)queryBuilder {
    return [self findById:objectID relations:@[] queryBuilder:queryBuilder];
}

-(NSDictionary<NSString *,id> *)findById:(NSString *)objectID relationsDepth:(int)relationsDepth {
    return [self findById:objectID relations:@[] relationsDepth:relationsDepth];
}

-(NSDictionary<NSString *, id> *)findById:(NSString *)objectID relations:(NSArray<NSString *> *)relations {
    if (!objectID) {
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    }
    NSArray *args = @[_tableName, objectID, relations?relations:@[]];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FINDBYID args:args];
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(NSDictionary<NSString *, id> *)findById:(NSString *)objectID relations:(NSArray<NSString *> *)relations queryBuilder:(DataQueryBuilder *)queryBuilder{
    if (!objectID) {
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    }
    NSArray *args = @[_tableName, objectID, relations?relations:@[], [queryBuilder build]];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FINDBYID args:args];
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(NSDictionary<NSString *, id> *)findById:(NSString *)objectID relations:(NSArray<NSString *> *)relations relationsDepth:(int)relationsDepth {
    if (!objectID) {
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    }
    NSArray *args = @[_tableName, objectID, relations?relations:@[], @(relationsDepth)];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FINDBYID args:args];
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(NSNumber *)getObjectCount {
    return [backendless.persistenceService getObjectCount:NSClassFromString(_tableName)];
}

-(NSNumber *)getObjectCount:(DataQueryBuilder *)dataQuery{
    return [backendless.persistenceService getObjectCount:NSClassFromString(_tableName) dataQuery:dataQuery];
}

-(NSNumber *)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects {
    return [backendless.persistenceService setRelation:_tableName columnName:columnName parentObjectId:parentObjectId childObjects:childObjects];
}

-(NSNumber *)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause{
    return [backendless.persistenceService setRelation:_tableName columnName:columnName parentObjectId:parentObjectId whereClause:whereClause];
}

-(NSNumber *)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects{
    return [backendless.persistenceService addRelation:_tableName columnName:columnName parentObjectId:parentObjectId childObjects:childObjects];
}

-(NSNumber *)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause{
    return [backendless.persistenceService addRelation:_tableName columnName:columnName parentObjectId:parentObjectId whereClause:whereClause];
}

-(NSNumber *)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects{
    return [backendless.persistenceService deleteRelation:_tableName columnName:columnName parentObjectId:parentObjectId childObjects:childObjects];
}

-(NSNumber *)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause{
    return [backendless.persistenceService deleteRelation:_tableName columnName:columnName parentObjectId:parentObjectId whereClause:whereClause];
}

-(NSArray*)loadRelations:(NSString *)objectID queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder {
    return [backendless.persistenceService loadRelations:_tableName objectID:(NSString *)objectID  queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder];
}

// async methods with block-based callbacks

-(void)save:(NSDictionary<NSString *, id> *)entity response:(void(^)(NSDictionary<NSString *, id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self save:entity responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)remove:(NSDictionary<NSString *, id> *)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self save:entity responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)find:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findResponder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)find:(BackendlessDataQuery *)dataQuery response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self find:dataQuery responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findFirst:(void(^)(NSDictionary<NSString *, id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findFirstResponder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findFirst:(int)relationsDepth response:(void(^)(NSDictionary<NSString *, id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findFirst:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findFirstWithRelations:(NSArray<NSString *> *)relations response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findFirst:relations responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findFirst:(NSArray<NSString *> *)relations relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString *, id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findFirst:relations relationsDepth:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findLast:(void(^)(NSDictionary<NSString *, id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findLastResponder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findLast:(int)relationsDepth response:(void(^)(NSDictionary<NSString *, id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findLast:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findLastWithRelations:(NSArray<NSString *> *)relations response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findLast:relations responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findLast:(NSArray<NSString *> *)relations relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString *, id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findLast:relations relationsDepth:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findById:(id)objectID response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    if ([objectID isKindOfClass:[NSString class]]) {
        [backendless.persistenceService findById:_tableName sid:objectID response:responseBlock error:errorBlock];
    }
    else {
        if ([objectID isKindOfClass:[NSDictionary class]]) {
            [backendless.persistenceService findByObject:_tableName keys:objectID response:responseBlock error:errorBlock];
        }
        else {
            [backendless.persistenceService findByObject:objectID response:responseBlock error:errorBlock];
        }
    }
}

-(void)findById:(id)objectID queryBuilder:(DataQueryBuilder *)queryBuilder response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    if ([objectID isKindOfClass:[NSString class]]) {
        [backendless.persistenceService findById:_tableName objectId:objectID queryBuilder:queryBuilder response:responseBlock error:errorBlock];
    }
    else {
        if ([objectID isKindOfClass:[NSDictionary class]]) {
            [backendless.persistenceService findByObject:_tableName keys:objectID queryBuilder:queryBuilder response:responseBlock error:errorBlock];
        }
        else {
            [backendless.persistenceService findByObject:objectID queryBuilder:queryBuilder response:responseBlock error:errorBlock];
        }
    }
}

-(void)findById:(NSString *)objectID relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString *, id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findById:objectID relationsDepth:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findById:(NSString *)objectID relations:(NSArray<NSString *> *)relations response:(void(^)(NSDictionary<NSString *, id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findById:objectID relations:relations responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findById:(NSString *)objectID relations:(NSArray<NSString *> *)relations relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString *, id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findById:objectID relations:relations relationsDepth:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getObjectCount:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService getObjectCount:_tableName response:responseBlock error:errorBlock];
}

-(void)getObjectCount:(DataQueryBuilder *)dataQuery response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService getObjectCount:_tableName dataQuery:dataQuery response:responseBlock error:errorBlock];
}

-(void)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService setRelation:(_tableName) columnName:columnName parentObjectId:parentObjectId childObjects:childObjects response:responseBlock error:errorBlock];
}

-(void)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService setRelation:(_tableName) columnName:columnName parentObjectId:parentObjectId whereClause:whereClause response:responseBlock error:errorBlock];
}

-(void)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService addRelation:(_tableName) columnName:columnName parentObjectId:parentObjectId childObjects:childObjects response:responseBlock error:errorBlock];
}

-(void)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService addRelation:(_tableName) columnName:columnName parentObjectId:parentObjectId whereClause:whereClause response:responseBlock error:errorBlock];
}

-(void)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService deleteRelation:(_tableName) columnName:columnName parentObjectId:parentObjectId childObjects:childObjects response:responseBlock error:errorBlock];
}

-(void)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService deleteRelation:(_tableName) columnName:columnName parentObjectId:parentObjectId whereClause:whereClause response:responseBlock error:errorBlock];
}

-(void)loadRelations:(NSString *)objectID queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService loadRelations:(_tableName) objectID:(NSString *)objectID  queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder response:responseBlock error:errorBlock];
}

@end
