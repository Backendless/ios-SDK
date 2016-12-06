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

-(id)removeAll:(BackendlessDataQuery *)dataQuery {
    return [backendless.persistenceService removeAll:_entityClass dataQuery:dataQuery];
}

-(NSArray *)find {
    return [self find:[BackendlessDataQuery query]];
}

-(NSArray *)find:(BackendlessDataQuery *)dataQuery {
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

-(id)load:(id)object relations:(NSArray *)relations {
    return [backendless.persistenceService load:object relations:relations];
}

-(id)findFirst:(int)relationsDepth {
    return [backendless.persistenceService first:_entityClass relations:@[] relationsDepth:relationsDepth];
}

-(id)findLast:(int)relationsDepth {
    return [backendless.persistenceService last:_entityClass relations:@[] relationsDepth:relationsDepth];
}

-(id)findID:(id)objectID {
    
    if ([objectID isKindOfClass:[NSString class]])
        return [backendless.persistenceService findByClassId:_entityClass sid:objectID];
    
    if ([objectID isKindOfClass:[NSDictionary class]])
        return [backendless.persistenceService findByObject:NSStringFromClass(_entityClass) keys:objectID];

    return [backendless.persistenceService findByObject:objectID];
}

-(id)findID:(id)objectID relationsDepth:(int)relationsDepth {
    
    if ([objectID isKindOfClass:[NSString class]])
        return [backendless.persistenceService findById:NSStringFromClass(_entityClass) sid:objectID relations:@[] relationsDepth:relationsDepth];
    
    if ([objectID isKindOfClass:[NSDictionary class]])
        return [backendless.persistenceService findByObject:NSStringFromClass(_entityClass) keys:objectID relations:@[] relationsDepth:relationsDepth];

    return [backendless.persistenceService findByObject:objectID relations:@[] relationsDepth:relationsDepth];
}

-(NSNumber *)getObjectCount {
    return [backendless.persistenceService getObjectCount:_entityClass];
}

-(NSNumber *)getObjectCount:(BackendlessDataQuery *)dataQuery{
    return [backendless.persistenceService getObjectCount:_entityClass dataQuery:dataQuery];
}

// sync methods with fault option

-(id)save:(id)entity fault:(Fault **)fault {
    return [backendless.persistenceService save:entity error:fault];
}

-(NSNumber *)remove:(id)entity fault:(Fault **)fault {
    NSString *objectId = [backendless.persistenceService getObjectId:entity];
    if ([objectId isKindOfClass:[NSString class]])
        return [backendless.persistenceService remove:[entity class] sid:objectId error:fault];
    else
        return [backendless.persistenceService remove:entity error:fault];
}

-(NSNumber *)removeID:(NSString *)objectID fault:(Fault **)fault {
    return [backendless.persistenceService remove:_entityClass sid:objectID error:fault];
}

-(NSArray *)removeAll:(BackendlessDataQuery *)dataQuery fault:(Fault **)fault {
    return [backendless.persistenceService removeAll:_entityClass dataQuery:dataQuery error:fault];
}

-(NSArray *)findFault:(Fault **)fault {
    return [self find:[BackendlessDataQuery query] fault:fault];
}

-(NSArray *)find:(BackendlessDataQuery *)dataQuery fault:(Fault **)fault {
    return [backendless.persistenceService find:_entityClass dataQuery:dataQuery error:fault];
}

-(id)findFirstFault:(Fault **)fault {
    return [backendless.persistenceService first:_entityClass error:fault];
}

-(id)findLastFault:(Fault **)fault {
    return [backendless.persistenceService last:_entityClass error:fault];
}

-(NSArray<ObjectProperty*> *)describe:(Fault **)fault {
    return [backendless.persistenceService describe:NSStringFromClass(_entityClass) error:fault];
}

-(id)load:(id)object relations:(NSArray *)relations fault:(Fault **)fault {
    return [backendless.persistenceService load:object relations:relations error:fault];
}

-(id)findFirst:(int)relationsDepth fault:(Fault **)fault {
    return [backendless.persistenceService first:_entityClass relations:@[] relationsDepth:relationsDepth error:fault];
}

-(id)findLast:(int)relationsDepth fault:(Fault **)fault {
    return [backendless.persistenceService last:_entityClass relations:@[] relationsDepth:relationsDepth error:fault];
}

-(id)findID:(id)objectID fault:(Fault **)fault {
    
    if ([objectID isKindOfClass:[NSString class]])
        return [backendless.persistenceService findByClassId:_entityClass sid:objectID error:fault];
    
    if ([objectID isKindOfClass:[NSDictionary class]])
        return [backendless.persistenceService findByObject:NSStringFromClass(_entityClass) keys:objectID error:fault];
    
    return [backendless.persistenceService findByObject:objectID error:fault];
}

-(id)findID:(id)objectID relationsDepth:(int)relationsDepth fault:(Fault **)fault {
    
    if ([objectID isKindOfClass:[NSString class]])
        return [backendless.persistenceService findById:NSStringFromClass(_entityClass) sid:objectID relations:@[] relationsDepth:relationsDepth error:fault];
    
    if ([objectID isKindOfClass:[NSDictionary class]])
        return [backendless.persistenceService findByObject:NSStringFromClass(_entityClass) keys:objectID relations:@[] relationsDepth:relationsDepth error:fault];
    
    return [backendless.persistenceService findByObject:objectID relations:@[] relationsDepth:relationsDepth error:fault];
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
    [self find:[BackendlessDataQuery query] response:responseBlock error:errorBlock];
}

-(void)find:(BackendlessDataQuery *)dataQuery response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
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

-(void)load:(id)object relations:(NSArray *)relations response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.persistenceService load:object relations:relations response:responseBlock error:errorBlock];
}

-(void)findFirst:(int)relationsDepth response:(void(^)(id result))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService first:_entityClass relations:@[] relationsDepth:relationsDepth response:responseBlock error:errorBlock];
}

-(void)findLast:(int)relationsDepth response:(void(^)(id result))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService last:_entityClass relations:@[] relationsDepth:relationsDepth response:responseBlock error:errorBlock];
}

-(void)findID:(id)objectID response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    
    if ([objectID isKindOfClass:[NSString class]])
        [backendless.persistenceService findByClassId:_entityClass sid:objectID response:responseBlock error:errorBlock];
    else
        if ([objectID isKindOfClass:[NSDictionary class]])
            [backendless.persistenceService findByObject:NSStringFromClass(_entityClass) keys:objectID response:responseBlock error:errorBlock];
        else
            [backendless.persistenceService findByObject:objectID response:responseBlock error:errorBlock];
}

-(void)findID:(id)objectID relationsDepth:(int)relationsDepth response:(void(^)(id result))responseBlock error:(void(^)(Fault *))errorBlock {
    
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

-(void)getObjectCount:(BackendlessDataQuery *)dataQuery response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService getObjectCount:_entityClass dataQuery:dataQuery response:responseBlock error:errorBlock];
}

@end
