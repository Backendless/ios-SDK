//
//  IDataStore.h
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

#import <Foundation/Foundation.h>
#import "LoadRelationsQueryBuilder.h"
#import "DataQueryBuilder.h"

@class QueryOptions, BackendlessDataQuery, Fault, ObjectProperty;
@protocol IResponder;

@protocol IDataStore <NSObject>

// sync methods with fault return (as exception)
-(id)save:(id)entity;
-(NSNumber *)remove:(id)entity;
-(NSNumber *)removeID:(NSString *)objectID;
-(NSArray *)find;
-(NSArray *)find:(DataQueryBuilder *)queryBuilder;
-(NSArray<ObjectProperty*> *)describe;
-(id)findFirst;
-(id)findFirst:(int)relationsDepth;
-(id)findLast;
-(id)findLast:(int)relationsDepth;
-(id)findById:(id)objectID;
-(id)findById:(id)objectID queryBuilder:(DataQueryBuilder *)queryBuilder;
-(id)findById:(id)objectID relationsDepth:(int)relationsDepth;
-(NSNumber *)getObjectCount;
-(NSNumber *)getObjectCount:(DataQueryBuilder *)queryBuilder;
//
-(NSNumber *)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects;
-(NSNumber *)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause;
-(NSNumber *)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects;
-(NSNumber *)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause;
-(NSNumber *)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects;
-(NSNumber *)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause;

-(NSArray*)loadRelations:(NSString *)objectID queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder;

// async methods with block-based callbacks
-(void)save:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)remove:(id)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeID:(NSString *)objectID response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)find:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)find:(DataQueryBuilder *)queryBuilder response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findFirst:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findLast:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)describeResponse:(void(^)(NSArray<ObjectProperty*> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findFirst:(int)relationsDepth response:(void(^)(id result))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findLast:(int)relationsDepth response:(void(^)(id result))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(id)objectID response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(id)objectID queryBuilder:(DataQueryBuilder *)queryBuilder response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(id)objectID relationsDepth:(int)relationsDepth response:(void(^)(id result))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getObjectCount:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getObjectCount:(DataQueryBuilder *)queryBuilder response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
//
-(void)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;

-(void)loadRelations:(NSString *)objectID queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
@end
