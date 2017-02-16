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
#include "Responder.h"
#include "Backendless.h"
#import "ObjectProperty.h"

@interface DataStoreFactory () {
    Class _entityClass;
}
@end

@implementation DataStoreFactory

-(id)init {
	if ( (self=[super init]) ) {
        _entityClass = nil;
	}
	
	return self;
}

-(id)init:(Class)entityClass {
	if ( (self=[super init]) ) {
        _entityClass = [entityClass retain];
	}
	
	return self;
}

+(id <IDataStore>)createDataStore:(Class)entityClass {
    return [[DataStoreFactory alloc] init:entityClass];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC DataStoreFactory"];
    
    if (_entityClass) [_entityClass release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark IDataStore Methods

// sync methods with fault return (as exception)

-(id)save:(id)entity {
    return [backendless.persistenceService save:entity];
}

-(NSNumber *)remove:(id)entity {
    NSString *objectId = [backendless.persistenceService getObjectId:entity];
    if ([objectId isKindOfClass:[NSString class]])
        return [backendless.persistenceService remove:[entity class] sid:objectId];
    else
        return [backendless.persistenceService remove:entity];
}

-(NSNumber *)removeID:(NSString *)objectID {
    return [backendless.persistenceService remove:_entityClass sid:objectID];
}

-(NSArray *)find {
    return [self find:[DataQueryBuilder query]];
}

-(NSArray *)find:(DataQueryBuilder *)dataQuery {
    return [backendless.persistenceService find:_entityClass dataQuery:dataQuery];
}

-(id)findFirst {
    return [backendless.persistenceService first:_entityClass];
}

-(id)findLast {
    return [backendless.persistenceService last:_entityClass];
}

-(NSArray<ObjectProperty*> *)describe {
    return [backendless.persistenceService describe:NSStringFromClass(_entityClass)];
}

-(id)findFirst:(int)relationsDepth {
    return [backendless.persistenceService first:_entityClass relations:@[] relationsDepth:relationsDepth];
}

-(id)findLast:(int)relationsDepth {
    return [backendless.persistenceService last:_entityClass relations:@[] relationsDepth:relationsDepth];
}

-(id)findById:(id)objectID {
    
    if ([objectID isKindOfClass:[NSString class]])
        return [backendless.persistenceService findByClassId:_entityClass sid:objectID];
    
    if ([objectID isKindOfClass:[NSDictionary class]])
        return [backendless.persistenceService findByObject:NSStringFromClass(_entityClass) keys:objectID];

    return [backendless.persistenceService findByObject:objectID];
}

-(id)findById:(id)objectID relationsDepth:(int)relationsDepth {
    
    if ([objectID isKindOfClass:[NSString class]])
        return [backendless.persistenceService findById:NSStringFromClass(_entityClass) sid:objectID relations:@[] relationsDepth:relationsDepth];
    
    if ([objectID isKindOfClass:[NSDictionary class]])
        return [backendless.persistenceService findByObject:NSStringFromClass(_entityClass) keys:objectID relations:@[] relationsDepth:relationsDepth];

    return [backendless.persistenceService findByObject:objectID relations:@[] relationsDepth:relationsDepth];
}

-(NSNumber *)getObjectCount {
    return [backendless.persistenceService getObjectCount:_entityClass];
}

-(NSNumber *)getObjectCount:(DataQueryBuilder *)dataQuery{
    return [backendless.persistenceService getObjectCount:_entityClass dataQuery:dataQuery];
}

-(NSNumber *)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects {
    return [backendless.persistenceService setRelation:NSStringFromClass(_entityClass) columnName:columnName parentObjectId:parentObjectId childObjects:childObjects];
}

-(NSNumber *)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause{
    return [backendless.persistenceService setRelation:NSStringFromClass(_entityClass) columnName:columnName parentObjectId:parentObjectId whereClause:whereClause];
}

-(NSNumber *)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects{
    return [backendless.persistenceService addRelation:NSStringFromClass(_entityClass) columnName:columnName parentObjectId:parentObjectId childObjects:childObjects];
}

-(NSNumber *)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause{
    return [backendless.persistenceService addRelation:NSStringFromClass(_entityClass) columnName:columnName parentObjectId:parentObjectId whereClause:whereClause];
}

-(NSNumber *)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects{
    return [backendless.persistenceService deleteRelation:NSStringFromClass(_entityClass) columnName:columnName parentObjectId:parentObjectId childObjects:childObjects];
}

-(NSNumber *)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause{
    return [backendless.persistenceService deleteRelation:NSStringFromClass(_entityClass) columnName:columnName parentObjectId:parentObjectId whereClause:whereClause];
}

-(NSArray*)loadRelations:(NSString *)objectID queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder {
    return [backendless.persistenceService loadRelations:NSStringFromClass(_entityClass) objectID:(NSString *)objectID  queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder];
}

// async methods with block-base callbacks

-(void)save:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService save:entity response:responseBlock error:errorBlock];
}

-(void)remove:(id)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    NSString *objectId = [backendless.persistenceService getObjectId:entity];
    if ([objectId isKindOfClass:[NSString class]])
        [backendless.persistenceService remove:[entity class] sid:objectId response:responseBlock error:errorBlock];
    else
        [backendless.persistenceService remove:entity response:responseBlock error:errorBlock];
}

-(void)removeID:(NSString *)objectID response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService remove:_entityClass sid:objectID response:responseBlock error:errorBlock];
}

-(void)find:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self find:[DataQueryBuilder query] response:responseBlock error:errorBlock];
}

-(void)find:(DataQueryBuilder *)dataQuery response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService find:_entityClass dataQuery:dataQuery response:responseBlock error:errorBlock];
}

-(void)findFirst:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService first:_entityClass response:responseBlock error:errorBlock];
}

-(void)findLast:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService last:_entityClass response:responseBlock error:errorBlock];
}

-(void)describeResponse:(void (^)(NSArray<ObjectProperty*> *))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.persistenceService describe:NSStringFromClass(_entityClass) response:responseBlock error:errorBlock];
}

-(void)findFirst:(int)relationsDepth response:(void(^)(id result))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService first:_entityClass relations:@[] relationsDepth:relationsDepth response:responseBlock error:errorBlock];
}

-(void)findLast:(int)relationsDepth response:(void(^)(id result))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService last:_entityClass relations:@[] relationsDepth:relationsDepth response:responseBlock error:errorBlock];
}

-(void)findById:(id)objectID response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    
    if ([objectID isKindOfClass:[NSString class]])
        [backendless.persistenceService findByClassId:_entityClass sid:objectID response:responseBlock error:errorBlock];
    else
        if ([objectID isKindOfClass:[NSDictionary class]])
            [backendless.persistenceService findByObject:NSStringFromClass(_entityClass) keys:objectID response:responseBlock error:errorBlock];
        else
            [backendless.persistenceService findByObject:objectID response:responseBlock error:errorBlock];
}

-(void)findById:(id)objectID relationsDepth:(int)relationsDepth response:(void(^)(id result))responseBlock error:(void(^)(Fault *))errorBlock {
    
    if ([objectID isKindOfClass:[NSString class]])
        [backendless.persistenceService findById:NSStringFromClass(_entityClass) sid:objectID relations:@[] relationsDepth:relationsDepth response:responseBlock error:errorBlock];
    else
        if ([objectID isKindOfClass:[NSDictionary class]])
            [backendless.persistenceService findByObject:NSStringFromClass(_entityClass) keys:objectID relations:@[] relationsDepth:relationsDepth response:responseBlock error:errorBlock];
        else
            [backendless.persistenceService findByObject:objectID relations:@[] relationsDepth:relationsDepth response:responseBlock error:errorBlock];
}

-(void)getObjectCount:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService getObjectCount:_entityClass response:responseBlock error:errorBlock];
}

-(void)getObjectCount:(DataQueryBuilder *)dataQuery response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService getObjectCount:_entityClass dataQuery:dataQuery response:responseBlock error:errorBlock];
}

-(void)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService setRelation:NSStringFromClass(_entityClass) columnName:columnName parentObjectId:parentObjectId childObjects:childObjects response:responseBlock error:errorBlock];
}

-(void)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService setRelation:NSStringFromClass(_entityClass) columnName:columnName parentObjectId:parentObjectId whereClause:whereClause response:responseBlock error:errorBlock];
}

-(void)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService addRelation:NSStringFromClass(_entityClass) columnName:columnName parentObjectId:parentObjectId childObjects:childObjects response:responseBlock error:errorBlock];
}

-(void)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService addRelation:NSStringFromClass(_entityClass) columnName:columnName parentObjectId:parentObjectId whereClause:whereClause response:responseBlock error:errorBlock];
}

-(void)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService deleteRelation:NSStringFromClass(_entityClass) columnName:columnName parentObjectId:parentObjectId childObjects:childObjects response:responseBlock error:errorBlock];
}

-(void)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService deleteRelation:NSStringFromClass(_entityClass) columnName:columnName parentObjectId:parentObjectId whereClause:whereClause response:responseBlock error:errorBlock];
}

-(void)loadRelations:(NSString *)objectID queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService loadRelations:NSStringFromClass(_entityClass) objectID:(NSString *)objectID  queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder response:responseBlock error:errorBlock];
}

@end
