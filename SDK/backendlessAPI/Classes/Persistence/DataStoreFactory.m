//
//  DataStoreFactory.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "DataStoreFactory.h"
#include "Backendless.h"
#import "ObjectProperty.h"
#import "AuthorizationException.h"

@interface DataStoreFactory () {
    Class _entityClass;
}
@end

@implementation DataStoreFactory

-(id)init:(Class)entityClass {
    if (self = [super init]) {
        _entityClass = [entityClass retain];
        [[Types sharedInstance] addClientClassMapping:@"Users" mapped:[BackendlessUser class]];
    }
    return self;
}

+(id <IDataStore>)createDataStore:(Class)entityClass {
    return [[DataStoreFactory alloc] init:entityClass];
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC DataStoreFactory"];
    if (_entityClass) {
        [_entityClass release];
    }
    [super dealloc];
}

#pragma mark IDataStore Methods

// sync methods with fault return (as exception)

-(id)save:(id)entity {
    return [backendless.persistenceService save:entity];
}

-(NSNumber *)remove:(id)entity {
    NSString *objectId = [backendless.persistenceService getObjectId:entity];
    if ([objectId isKindOfClass:[NSString class]]) {
        return [backendless.persistenceService remove:[entity class] sid:objectId];
    }
    else {
        return [backendless.persistenceService remove:entity];
    }
}

-(NSNumber *)removeById:(NSString *)objectId {
    return [backendless.persistenceService remove:_entityClass sid:objectId];
}

-(NSArray *)find {
    return [backendless.persistenceService find:_entityClass queryBuilder:[DataQueryBuilder new]];
}

-(NSArray *)find:(DataQueryBuilder *)queryBuilder {
    return [backendless.persistenceService find:_entityClass queryBuilder:queryBuilder];
}

-(id)findFirst {
    return [backendless.persistenceService first:_entityClass];
}

- (id)findFirst:(DataQueryBuilder *)queryBuilder {
    return [backendless.persistenceService first:_entityClass queryBuilder:queryBuilder];
}

-(id)findLast {
    return [backendless.persistenceService last:_entityClass];
}

-(id)findLast:(DataQueryBuilder *)queryBuilder {
    return [backendless.persistenceService last:_entityClass queryBuilder:queryBuilder];
}

-(id)findById:(id)objectId {
    if ([objectId isKindOfClass:[NSString class]]) {
        return [backendless.persistenceService findByClassId:_entityClass objectId:objectId];
    }
    if ([objectId isKindOfClass:[NSDictionary class]]) {
        return [backendless.persistenceService findByObject:[backendless.persistenceService getEntityName:(_entityClass)] keys:objectId];
    }
    return [backendless.persistenceService findByObject:objectId];
}

-(id)findById:(id)objectId queryBuilder:(DataQueryBuilder *)queryBuilder {
    if ([objectId isKindOfClass:[NSString class]]) {
        return [backendless.persistenceService findByClassId:_entityClass objectId:objectId queryBuilder:queryBuilder];
    }
    if ([objectId isKindOfClass:[NSDictionary class]]) {
        return [backendless.persistenceService findByObject:[backendless.persistenceService getEntityName:(_entityClass)] keys:objectId queryBuilder:queryBuilder];
    }
    return [backendless.persistenceService findByObject:objectId queryBuilder:queryBuilder];
}

-(NSNumber *)getObjectCount {
    return [backendless.persistenceService getObjectCount:_entityClass];
}

-(NSNumber *)getObjectCount:(DataQueryBuilder *)queryBuilder {
    return [backendless.persistenceService getObjectCount:_entityClass queryBuilder:queryBuilder];
}

-(NSNumber *)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects {
    return [backendless.persistenceService setRelation:[backendless.persistenceService getEntityName:_entityClass] columnName:columnName parentObjectId:parentObjectId childObjects:childObjects];
}

-(NSNumber *)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause {
    return [backendless.persistenceService setRelation:[backendless.persistenceService getEntityName:(_entityClass)] columnName:columnName parentObjectId:parentObjectId whereClause:whereClause];
}

-(NSNumber *)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects {
    return [backendless.persistenceService addRelation:[backendless.persistenceService getEntityName:(_entityClass)] columnName:columnName parentObjectId:parentObjectId childObjects:childObjects];
}

-(NSNumber *)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause {
    return [backendless.persistenceService addRelation:[backendless.persistenceService getEntityName:(_entityClass)] columnName:columnName parentObjectId:parentObjectId whereClause:whereClause];
}

-(NSNumber *)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects {
    return [backendless.persistenceService deleteRelation:[backendless.persistenceService getEntityName:(_entityClass)] columnName:columnName parentObjectId:parentObjectId childObjects:childObjects];
}

-(NSNumber *)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause {
    return [backendless.persistenceService deleteRelation:[backendless.persistenceService getEntityName:(_entityClass)] columnName:columnName parentObjectId:parentObjectId whereClause:whereClause];
}

-(NSArray *)loadRelations:(NSString *)objectId queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder {
    return [backendless.persistenceService loadRelations:[backendless.persistenceService getEntityName:(_entityClass)] objectId:(NSString *)objectId  queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder];
}

// async methods with block-base callbacks

-(void)save:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService save:entity response:responseBlock error:errorBlock];
}

-(void)remove:(id)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    NSString *objectId = [backendless.persistenceService getObjectId:entity];
    if ([objectId isKindOfClass:[NSString class]]) {
        [backendless.persistenceService remove:[entity class] sid:objectId response:responseBlock error:errorBlock];
    }
    else {
        [backendless.persistenceService remove:entity response:responseBlock error:errorBlock];
    }
}

-(void)removeById:(NSString *)objectId response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService remove:_entityClass sid:objectId response:responseBlock error:errorBlock];
}

-(void)find:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService find:_entityClass queryBuilder:[DataQueryBuilder new] response:responseBlock error:errorBlock];
}

-(void)find:(DataQueryBuilder *)queryBuilder response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService find:_entityClass queryBuilder:queryBuilder response:responseBlock error:errorBlock];
}

-(void)findFirst:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService first:_entityClass response:responseBlock error:errorBlock];
}

-(void)findFirst:(DataQueryBuilder *)queryBuilder response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.persistenceService first:_entityClass queryBuilder:queryBuilder response:responseBlock error:errorBlock];
}

-(void)findLast:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService last:_entityClass response:responseBlock error:errorBlock];
}

-(void)findLast:(DataQueryBuilder *)queryBuilder response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.persistenceService last:_entityClass queryBuilder:queryBuilder response:responseBlock error:errorBlock];
}

-(void)findById:(id)objectId response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    if ([objectId isKindOfClass:[NSString class]]) {
        [backendless.persistenceService findByClassId:_entityClass sid:objectId response:responseBlock error:errorBlock];
    }
    else {
        if ([objectId isKindOfClass:[NSDictionary class]]) {
            [backendless.persistenceService findByObject:[backendless.persistenceService getEntityName:(_entityClass)] keys:objectId response:responseBlock error:errorBlock];
        }
        else {
            [backendless.persistenceService findByObject:objectId response:responseBlock error:errorBlock];
        }
    }
}

-(void)findById:(id)objectId queryBuilder:(DataQueryBuilder *)queryBuilder response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    if ([objectId isKindOfClass:[NSString class]]) {
        [backendless.persistenceService findByClassId:_entityClass objectId:objectId queryBuilder:queryBuilder response:responseBlock error:errorBlock];
    }
    else {
        if ([objectId isKindOfClass:[NSDictionary class]]) {
            [backendless.persistenceService findByObject:[backendless.persistenceService getEntityName:(_entityClass)] keys:objectId queryBuilder:queryBuilder response:responseBlock error:errorBlock];
        }
        else {
            [backendless.persistenceService findByObject:objectId queryBuilder:queryBuilder response:responseBlock error:errorBlock];
        }
    }
}

-(void)getObjectCount:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService getObjectCount:_entityClass response:responseBlock error:errorBlock];
}

-(void)getObjectCount:(DataQueryBuilder *)queryBuilder response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService getObjectCount:_entityClass queryBuilder:queryBuilder response:responseBlock error:errorBlock];
}

-(void)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService setRelation:[backendless.persistenceService getEntityName:(_entityClass)] columnName:columnName parentObjectId:parentObjectId childObjects:childObjects response:responseBlock error:errorBlock];
}

-(void)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService setRelation:[backendless.persistenceService getEntityName:(_entityClass)] columnName:columnName parentObjectId:parentObjectId whereClause:whereClause response:responseBlock error:errorBlock];
}

-(void)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService addRelation:[backendless.persistenceService getEntityName:(_entityClass)] columnName:columnName parentObjectId:parentObjectId childObjects:childObjects response:responseBlock error:errorBlock];
}

-(void)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService addRelation:[backendless.persistenceService getEntityName:(_entityClass)] columnName:columnName parentObjectId:parentObjectId whereClause:whereClause response:responseBlock error:errorBlock];
}

-(void)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService deleteRelation:[backendless.persistenceService getEntityName:(_entityClass)] columnName:columnName parentObjectId:parentObjectId childObjects:childObjects response:responseBlock error:errorBlock];
}

-(void)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService deleteRelation:[backendless.persistenceService getEntityName:(_entityClass)] columnName:columnName parentObjectId:parentObjectId whereClause:whereClause response:responseBlock error:errorBlock];
}

-(void)loadRelations:(NSString *)objectId queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService loadRelations:[backendless.persistenceService getEntityName:(_entityClass)] objectId:(NSString *)objectId  queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder response:responseBlock error:errorBlock];
}

@end
