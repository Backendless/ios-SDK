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
#import "ObjectSerializer.h"
#import "IResponseAdapter.h"
#import "MapAdapter.h"
#import "RTFactory.h"

#define FAULT_NO_ENTITY [Fault fault:@"Entity is missing or null" detail:@"Entity is missing or null" faultCode:@"1900"]
#define FAULT_OBJECT_ID_IS_NOT_EXIST [Fault fault:@"objectId is missing or null" detail:@"objectId is missing or null" faultCode:@"1901"]
#define FAULT_FIELD_IS_NULL [Fault fault:@"Field is missing or null" detail:@"Field is missing or null" faultCode:@"1903"]

// SERVICE NAME
static NSString *SERVER_PERSISTENCE_SERVICE_PATH  = @"com.backendless.services.persistence.PersistenceService";
// METHOD NAMES
static NSString *METHOD_SAVE = @"save";
static NSString *METHOD_REMOVE = @"remove";
static NSString *METHOD_FIND = @"find";
static NSString *METHOD_COUNT = @"count";
static NSString *METHOD_FIRST = @"first";
static NSString *METHOD_LAST = @"last";
static NSString *UPDATE_BULK = @"updateBulk";
static NSString *REMOVE_BULK = @"removeBulk";

@implementation MapDrivenDataStore

@synthesize rt;

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
        self.rt = [rtFactory createDataStore:_tableName withEntity:nil dataStoreType:MAPDRIVENDATASTORE];
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
-(id)save:(id)entity {
    if (!entity) {
        return [backendless throwFault:FAULT_NO_ENTITY];
    }
    NSArray *args = @[_tableName, entity];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_SAVE args:args responseAdapter:[MapAdapter new]];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(NSNumber *)remove:(NSDictionary<NSString*,id> *)entity {
    if (!entity) {
        return [backendless throwFault:FAULT_NO_ENTITY];
    }
    NSArray *args = @[_tableName, entity];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_REMOVE args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSNumber *)removeById:(NSString *)objectId {
    if (!objectId) {
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    }
    NSArray *args = @[_tableName, objectId];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_REMOVE args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSArray *)find {
    NSArray *args = @[_tableName, [DataQueryBuilder new]];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIND args:args responseAdapter:[MapAdapter new]];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    for (NSMutableDictionary *dictionary in result) {
        [self setNullToNil:dictionary];
    }
    return (NSArray *)result;
}

-(NSArray *)find:(DataQueryBuilder *)queryBuilder {
    if (!queryBuilder) {
        [backendless throwFault:FAULT_FIELD_IS_NULL];
    }
    NSArray *args = @[_tableName, [queryBuilder build]];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIND args:args responseAdapter:[MapAdapter new]];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    for (NSMutableDictionary *dictionary in (NSMutableArray *)result) {
        [self setNullToNil:dictionary];
    }
    NSArray *bc = (NSArray *)result;
    return [self fixClassCollection:bc];
}

-(id)findFirst {
    NSArray *args = @[_tableName];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIRST args:args responseAdapter:[MapAdapter new]];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return [result isKindOfClass:NSDictionary.class]?[self setNullToNil:(NSMutableDictionary *) result]:[self setNullToNil:(NSMutableDictionary *) [Types propertyDictionary:result]];
}

-(id)findFirst:(DataQueryBuilder *)queryBuilder {
    if (!queryBuilder) {
        [backendless throwFault:FAULT_FIELD_IS_NULL];
    }
    NSArray *args = @[_tableName, [queryBuilder getRelated]?[queryBuilder getRelated]:@[], [queryBuilder getRelationsDepth]?[queryBuilder getRelationsDepth]:[NSNull null], [queryBuilder getProperties]];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIRST args:args responseAdapter:[MapAdapter new]];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return [result isKindOfClass:NSDictionary.class]?[self setNullToNil:(NSMutableDictionary *) result]:[self setNullToNil:(NSMutableDictionary *) [Types propertyDictionary:result]];
}

-(id)findLast {
    NSArray *args = @[_tableName];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LAST args:args responseAdapter:[MapAdapter new]];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return [result isKindOfClass:NSDictionary.class]?[self setNullToNil:(NSMutableDictionary *) result]:[self setNullToNil:(NSMutableDictionary *) [Types propertyDictionary:result]];
}

-(id)findLast:(DataQueryBuilder *)queryBuilder {
    if (!queryBuilder) {
        [backendless throwFault:FAULT_FIELD_IS_NULL];
    }
    NSArray *args = @[_tableName, [queryBuilder getRelated]?[queryBuilder getRelated]:@[], [queryBuilder getRelationsDepth]?[queryBuilder getRelationsDepth]:[NSNull null], [queryBuilder getProperties]];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LAST args:args responseAdapter:[MapAdapter new]];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return [result isKindOfClass:NSDictionary.class]?[self setNullToNil:(NSMutableDictionary *) result]:[self setNullToNil:(NSMutableDictionary *) [Types propertyDictionary:result]];
}

-(id)findById:(NSString *)objectId {
    if (!objectId) {
        [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    }
    id result = [backendless.persistenceService findById:_tableName objectId:objectId responseAdapter:[MapAdapter new]];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return [self setNullToNil:result];
}

-(id)findById:(NSString *)objectId queryBuilder:(DataQueryBuilder *)queryBuilder {
    if (!objectId) {
        [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    }
    if (!queryBuilder) {
        [backendless throwFault:FAULT_FIELD_IS_NULL];
    }
    id result = [backendless.persistenceService findById:_tableName objectId:objectId queryBuilder:queryBuilder responseAdapter:[MapAdapter new]];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return [self setNullToNil:result];
}

-(NSNumber *)getObjectCount {
    NSArray *args = @[_tableName];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_COUNT args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSNumber *)getObjectCount:(DataQueryBuilder *)dataQuery{
    if (!dataQuery) {
        [backendless throwFault:FAULT_FIELD_IS_NULL];
    }
    NSArray *args = @[_tableName, [dataQuery build]];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_COUNT args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSNumber *)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects {
    id result = [backendless.persistenceService setRelation:_tableName columnName:columnName parentObjectId:parentObjectId childObjects:childObjects];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSNumber *)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause{
    id result = [backendless.persistenceService setRelation:_tableName columnName:columnName parentObjectId:parentObjectId whereClause:whereClause];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSNumber *)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects{
    id result = [backendless.persistenceService addRelation:_tableName columnName:columnName parentObjectId:parentObjectId childObjects:childObjects];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSNumber *)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause{
    id result = [backendless.persistenceService addRelation:_tableName columnName:columnName parentObjectId:parentObjectId whereClause:whereClause];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSNumber *)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects{
    id result = [backendless.persistenceService deleteRelation:_tableName columnName:columnName parentObjectId:parentObjectId childObjects:childObjects];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSNumber *)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause{
    id result = [backendless.persistenceService deleteRelation:_tableName columnName:columnName parentObjectId:parentObjectId whereClause:whereClause];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSArray*)loadRelations:(NSString *)objectId queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder {
    id result = [backendless.persistenceService loadRelations:_tableName objectId:(NSString *)objectId  queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSNumber *)updateBulk:(NSString *)whereClause changes:(NSDictionary<NSString *,id> *)changes {
    NSArray *args = @[_tableName, whereClause, changes];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:UPDATE_BULK args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSNumber *)removeBulk:(NSString *)whereClause {
    NSArray *args = @[_tableName, whereClause];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:REMOVE_BULK args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

// async methods with block-based callbacks

-(void)save:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    NSArray *args = @[_tableName, entity];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_SAVE args:args responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock] responseAdapter:[MapAdapter new]];
}

-(void)remove:(NSDictionary<NSString*,id> *)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    NSArray *args = @[_tableName, entity];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_REMOVE args:args responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)removeById:(NSString *)objectId response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    NSArray *args = @[_tableName, objectId];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_REMOVE args:args responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)find:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    NSArray *args = @[_tableName, [DataQueryBuilder new]];
    Responder *responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onFind:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIND args:args responder:_responder responseAdapter:[MapAdapter new]];
}

-(void)find:(DataQueryBuilder *)queryBuilder response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    NSArray *args = @[_tableName, [queryBuilder build]];
    Responder *responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onFind:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIND args:args responder:_responder responseAdapter:[MapAdapter new]];
}

-(void)findFirst:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    NSArray *args = @[_tableName];
    Responder *responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onFind:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIRST args:args responder:_responder responseAdapter:[MapAdapter new]];
}

-(void)findFirst:(DataQueryBuilder *)queryBuilder response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    NSArray *args = @[_tableName, [queryBuilder getRelated]?[queryBuilder getRelated]:@[], [queryBuilder getRelationsDepth]?[queryBuilder getRelationsDepth]:[NSNull null], [queryBuilder getProperties]];
    Responder *responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onFind:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIRST args:args responder:_responder responseAdapter:[MapAdapter new]];
}

-(void)findLast:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    NSArray *args = @[_tableName];
    Responder *responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onFind:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LAST args:args responder:_responder responseAdapter:[MapAdapter new]];
}

-(void)findLast:(DataQueryBuilder *)queryBuilder response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    NSArray *args = @[_tableName, [queryBuilder getRelated]?[queryBuilder getRelated]:@[], [queryBuilder getRelationsDepth]?[queryBuilder getRelationsDepth]:[NSNull null], [queryBuilder getProperties]];
    Responder *responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onFind:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LAST args:args responder:_responder responseAdapter:[MapAdapter new]];
}

-(void)findById:(NSString *)objectId response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    void (^wrappedBlock)(id) = ^(id dict) {
        dict = [self setNullToNil:dict];
        responseBlock(dict);
    };
    [backendless.persistenceService findById:_tableName objectId:objectId response:wrappedBlock error:errorBlock responseAdapter:[MapAdapter new]];
}

-(void)findById:(NSString *)objectId queryBuilder:(DataQueryBuilder *)queryBuilder response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    void (^wrappedBlock)(id) = ^(id dict) {
        dict = [self setNullToNil:dict];
        responseBlock(dict);
    };
    [backendless.persistenceService findById:_tableName objectId:objectId queryBuilder:queryBuilder response:wrappedBlock error:errorBlock responseAdapter:[MapAdapter new]];
}

-(void)getObjectCount:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    NSArray *args = @[_tableName];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_COUNT args:args responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getObjectCount:(DataQueryBuilder *)dataQuery response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    NSArray *args = @[_tableName, [dataQuery build]];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_COUNT args:args responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService setRelation:(_tableName) columnName:columnName parentObjectId:parentObjectId childObjects:childObjects response:responseBlock error:errorBlock];
}

-(void)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService setRelation:(_tableName) columnName:columnName parentObjectId:parentObjectId whereClause:whereClause response:responseBlock error:errorBlock];
}

-(void)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService addRelation:(_tableName) columnName:columnName parentObjectId:parentObjectId childObjects:childObjects response:responseBlock error:errorBlock];
}

-(void)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService addRelation:(_tableName) columnName:columnName parentObjectId:parentObjectId whereClause:whereClause response:responseBlock error:errorBlock];
}

-(void)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService deleteRelation:(_tableName) columnName:columnName parentObjectId:parentObjectId childObjects:childObjects response:responseBlock error:errorBlock];
}

-(void)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService deleteRelation:(_tableName) columnName:columnName parentObjectId:parentObjectId whereClause:whereClause response:responseBlock error:errorBlock];
}

-(void)loadRelations:(NSString *)objectId queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService loadRelations:(_tableName) objectId:(NSString *)objectId  queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder response:responseBlock error:errorBlock];
}

-(NSMutableDictionary *)setNullToNil:(NSMutableDictionary *)dictionary {
    if ([dictionary isKindOfClass:[NSDictionary class]] || [dictionary isKindOfClass:[NSMutableDictionary class]]) {
        for (NSString *key in [dictionary allKeys]) {
            if ([[dictionary valueForKey:key] isKindOfClass:[NSNull class]]) {
                dictionary[key] = nil;
            }
        }
    }
    return dictionary;
}

-(void)updateBulk:(NSString *)whereClause changes:(NSDictionary<NSString *,id> *)changes response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    NSArray *args = @[_tableName, whereClause, changes];
    Responder *responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onFind:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:UPDATE_BULK args:args responder:_responder];
}

- (void)removeBulk:(NSString *)whereClause response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    NSArray *args = @[_tableName, whereClause];
    Responder *responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onFind:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:REMOVE_BULK args:args responder:_responder];
}

-(id)onFind:(id)response {
    if ([response isKindOfClass:[NSArray class]]) {
        for (NSMutableDictionary *dictionary in (NSMutableArray *)response) {
            [self setNullToNil:dictionary];
        }
    }
    else if ([response isKindOfClass:[NSDictionary class]]) {
        [self setNullToNil:response];
    }
    return response;
}

@end
