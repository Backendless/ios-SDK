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
#import "EventHandler.h"

@class QueryOptions, Fault, ObjectProperty;
@protocol IResponder;

@protocol IDataStore <NSObject>

@property (strong, nonatomic) EventHandler *rt;

// sync methods with fault return (as exception)
-(id)save:(id)entity;
-(NSNumber *)remove:(id)entity;
-(NSNumber *)removeById:(NSString *)objectId;
-(NSArray *)find;
-(NSArray *)find:(DataQueryBuilder *)queryBuilder;
-(id)findFirst;
-(id)findFirst:(DataQueryBuilder *)queryBuilder;
-(id)findLast;
-(id)findLast:(DataQueryBuilder *)queryBuilder;
-(id)findById:(id)objectId;
-(id)findById:(id)objectId queryBuilder:(DataQueryBuilder *)queryBuilder;
-(NSNumber *)getObjectCount;
-(NSNumber *)getObjectCount:(DataQueryBuilder *)queryBuilder;
-(NSNumber *)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects;
-(NSNumber *)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause;
-(NSNumber *)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects;
-(NSNumber *)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause;
-(NSNumber *)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects;
-(NSNumber *)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause;
-(NSArray *)loadRelations:(NSString *)objectId queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder;
-(NSNumber *)updateBulk:(NSString *)whereClause changes:(NSDictionary<NSString *, id> *)changes;
-(NSNumber *)removeBulk:(NSString *)whereClause;

// async methods with block-based callbacks
-(void)save:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)remove:(id)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeById:(NSString *)objectId response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)find:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)find:(DataQueryBuilder *)queryBuilder response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findFirst:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findFirst:(DataQueryBuilder *)queryBuilder response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findLast:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findLast:(DataQueryBuilder *)queryBuilder response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(id)objectId response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(id)objectId queryBuilder:(DataQueryBuilder *)queryBuilder response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getObjectCount:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getObjectCount:(DataQueryBuilder *)queryBuilder response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)loadRelations:(NSString *)objectId queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)updateBulk:(NSString *)whereClause changes:(NSDictionary<NSString *,id> *)changes response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)removeBulk:(NSString *)whereClause response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;

@end
