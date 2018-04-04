//
//  PersistenceService.h
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
#import "DataPermission.h"
#import "MapDrivenDataStore.h"
#import "LoadRelationsQueryBuilder.h"
#import "DataQueryBuilder.h"
#import "IResponseAdapter.h"

#define PERSIST_OBJECT_ID @"objectId"

@class QueryOptions, Fault, ObjectProperty;
@protocol IDataStore;

@interface PersistenceService : NSObject

@property (strong, nonatomic, readonly) DataPermission *permissions;

-(NSString *)getEntityName:(NSString *)entityName;

// sync methods with fault return (as exception)
-(NSArray<ObjectProperty*> *)describe:(NSString *)entityName;
-(NSDictionary *)save:(NSString *)entityName entity:(NSDictionary *)entity;
-(NSDictionary *)update:(NSString *)entityName entity:(NSDictionary *)entity objectId:(NSString *)objectId;
-(id)save:(id)entity;
-(id)create:(id)entity;
-(id)update:(id)entity;
-(NSArray *)find:(Class)entity;
-(NSArray *)find:(Class)entity queryBuilder:(DataQueryBuilder *)queryBuilder;
-(id)first:(Class)entity;
-(id)first:(Class)entity queryBuilder:(DataQueryBuilder *)queryBuilder;
-(id)last:(Class)entity;
-(id)last:(Class)entity queryBuilder:(DataQueryBuilder *)queryBuilder;
-(id)findByObject:(id)entity relations:(NSArray *)relations;
-(id)findByObject:(id)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth;
-(id)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations;
-(id)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations relationsDepth:(int)relationsDepth;
-(id)findById:(NSString *)entityName objectId:(NSString *)objectId;
-(id)findById:(NSString *)entityName objectId:(NSString *)objectId responseAdapter:(id<IResponseAdapter>)responseAdapter;
-(id)findById:(NSString *)entityName objectId:(NSString *)objectId queryBuilder:(DataQueryBuilder *)queryBuilder;
-(id)findById:(NSString *)entityName objectId:(NSString *)objectId queryBuilder:(DataQueryBuilder *)queryBuilder responseAdapter:(id<IResponseAdapter>)responseAdapter;
-(id)findByClassId:(Class)entity objectId:(NSString *)objectId;
-(id)findByClassId:(Class)entity objectId:(NSString *)objectId queryBuilder:(DataQueryBuilder *)queryBuilder;
-(NSNumber *)remove:(id)entity;
-(NSNumber *)remove:(Class)entity objectId:(NSString *)objectId;
-(NSArray *)callStoredProcedure:(NSString *)spName arguments:(NSDictionary *)arguments;
-(NSNumber *)getObjectCount:(Class)entity;
-(NSNumber *)getObjectCount:(Class)entity queryBuilder:(DataQueryBuilder *)queryBuilder;
-(NSNumber *)setRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects;
-(NSNumber *)setRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause;
-(NSNumber *)addRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects;
-(NSNumber *)addRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause;
-(NSNumber *)deleteRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects;
-(NSNumber *)deleteRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause;
-(NSArray *)loadRelations:(NSString *)parentType objectId:(NSString *)objectId queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder;
-(NSArray *)createBulk:(id)entity objects:(NSArray *)objects;
-(NSNumber *)updateBulk:(id)entity whereClause:(NSString *)whereClause changes:(NSDictionary<NSString *, id> *)changes;
-(NSNumber *)removeBulk:(id)entity whereClause:(NSString *)whereClause;

// async methods with block-based callbacks
-(void)describe:(NSString *)entityName response:(void(^)(NSArray<ObjectProperty*> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)save:(NSString *)entityName entity:(NSDictionary *)entity response:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)update:(NSString *)entityName entity:(NSDictionary *)entity objectId:(NSString *)objectId response:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)save:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)create:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)update:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)find:(Class)entity response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)find:(Class)entity queryBuilder:(DataQueryBuilder *)queryBuilder response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)first:(Class)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)first:(Class)entity queryBuilder:(DataQueryBuilder *)queryBuilder response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)last:(Class)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)last:(Class)entity queryBuilder:(DataQueryBuilder *)queryBuilder response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByObject:(id)entity relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByObject:(id)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)entityName objectId:(NSString *)objectId response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)entityName objectId:(NSString *)objectId response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock responseAdapter:(id<IResponseAdapter>)responseAdapter;
-(void)findById:(NSString *)entityName objectId:(NSString *)objectId queryBuilder:(DataQueryBuilder *)queryBuilder response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)entityName objectId:(NSString *)objectId queryBuilder:(DataQueryBuilder *)queryBuilder response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock responseAdapter:(id<IResponseAdapter>)responseAdapter;
-(void)findByClassId:(Class)entity objectId:(NSString *)sid response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByClassId:(Class)entity objectId:(NSString *)objectId queryBuilder:(DataQueryBuilder *)queryBuilder response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)remove:(id)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)remove:(Class)entity objectId:(NSString *)sid response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)callStoredProcedure:(NSString *)spName arguments:(NSDictionary *)arguments response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getObjectCount:(Class)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getObjectCount:(Class)entity queryBuilder:(DataQueryBuilder *)queryBuilder response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)setRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)setRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)deleteRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)deleteRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)loadRelations:(NSString *)parentType objectId:(NSString *)objectId queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)createBulk:(id)entity objects:(NSArray *)objects response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)updateBulk:(id)entity whereClause:(NSString *)whereClause changes:(NSDictionary<NSString *, id> *)changes response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeBulk:(id)entity whereClause:(NSString *)whereClause response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;

// IDataStore class factory
-(id <IDataStore>)of:(Class)entityClass;
// MapDrivenDataStore factory
-(MapDrivenDataStore *)ofTable:(NSString *)tableName;

// utilites
-(id)getObjectId:(id)object;
-(NSDictionary *)getObjectMetadata:(id)object;
-(void)mapTableToClass:(NSString *)tableName type:(Class)type;
-(void)mapColumnToProperty:(Class)classToMap columnName:(NSString *)columnName propertyName:(NSString *)propertyName;
-(NSString *)typeClassName:(Class)entity;
-(NSString *)objectClassName:(id)object;
-(NSDictionary *)propertyDictionary:(id)object;
-(id)propertyObject:(id)object;

@end
