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

#define PERSIST_OBJECT_ID @"objectId"
#define PERSIST_CLASS(CLASS) [backendless.persistenceService of:[CLASS class]]

extern NSString *LOAD_ALL_RELATIONS;

@class QueryOptions, BackendlessDataQuery, Fault, ObjectProperty;
@protocol IResponder, IDataStore;


@interface PersistenceService : NSObject

@property (strong, nonatomic, readonly) DataPermission *permissions;

// sync methods with fault return (as exception)
-(NSArray<ObjectProperty*> *)describe:(NSString *)classCanonicalName;
-(NSDictionary *)save:(NSString *)entityName entity:(NSDictionary *)entity;
-(NSDictionary *)update:(NSString *)entityName entity:(NSDictionary *)entity sid:(NSString *)sid;
-(id)save:(id)entity;
-(id)create:(id)entity;
-(id)update:(id)entity;
-(NSArray *)find:(Class)entity dataQuery:(DataQueryBuilder *)dataQuery;
-(id)first:(Class)entity;
-(id)first:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth;
-(id)last:(Class)entity;
-(id)last:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth;
-(id)findByObject:(id)entity;
-(id)findByObject:(id)entity relations:(NSArray *)relations;
-(id)findByObject:(id)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth;
-(id)findByObject:(NSString *)className keys:(NSDictionary *)props;
-(id)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations;
-(id)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations relationsDepth:(int)relationsDepth;
-(id)findById:(NSString *)entityName sid:(NSString *)sid;
-(id)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations;
-(id)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations relationsDepth:(int)relationsDepth;
-(id)findByClassId:(Class)entity sid:(NSString *)sid;
-(NSNumber *)remove:(id)entity;
-(NSNumber *)remove:(Class)entity sid:(NSString *)sid;
-(NSArray *)getView:(NSString *)viewName dataQuery:(BackendlessDataQuery *)dataQuery;
-(NSArray *)callStoredProcedure:(NSString *)spName arguments:(NSDictionary *)arguments;
-(NSNumber *)getObjectCount:(Class)entity;
-(NSNumber *)getObjectCount:(Class)entity dataQuery:(DataQueryBuilder *)dataQuery;
//
-(id)setRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects;
-(NSNumber *)setRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause;
-(id)addRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects;
-(NSNumber *)addRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause;
-(id)deleteRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects;
-(NSNumber *)deleteRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause;
-(id)loadRelations:(NSString *)parentType objectID:(NSString *)objectID queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder;
/*
 Backendless.Data.of( T ).bulkCreate( List<T> objects );
 Backendless.Data.of( T ).bulkDelete( List<T> objects );
 Backendless.Data.of( T ).bulkDeleteByIds( List<String> objectIDs );
 public int Backendless.Data.of( T ).bulkDeleteByWhereClause( String whereClause );
 public int Backendless.Data.of( T ).bulkUpdate( T templateObject, String whereClause );
 */
/*
-(id)bulkCreate:(NSArray *)objects;
-(id)bulkDelete:(NSArray *)objects;
-(id)bulkDeleteByIds:(NSArray<NSString*> *)objectIDs;
-(NSNumber *)bulkDeleteByWhereClause:(NSString *)whereClause;
-(NSNumber *)bulkUpdate:(NSArray *)objects;
 */


// sync methods with fault option
-(NSArray<ObjectProperty*> *)describe:(NSString *)classCanonicalName error:(Fault **)fault;
-(NSDictionary *)save:(NSString *)entityName entity:(NSDictionary *)entity error:(Fault **)fault;
-(NSDictionary *)update:(NSString *)entityName entity:(NSDictionary *)entity sid:(NSString *)sid error:(Fault **)fault;
-(id)save:(id)entity error:(Fault **)fault;
-(id)create:(id)entity error:(Fault **)fault;
-(id)update:(id)entity error:(Fault **)fault;
-(NSArray *)find:(Class)entity dataQuery:(DataQueryBuilder *)dataQuery error:(Fault **)fault;
-(id)first:(Class)entity error:(Fault **)fault;
-(id)first:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault;
-(id)last:(Class)entity error:(Fault **)fault;
-(id)last:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault;
-(id)findByObject:(id)entity error:(Fault **)fault;
-(id)findByObject:(id)entity relations:(NSArray *)relations error:(Fault **)fault;
-(id)findByObject:(id)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault;
-(id)findByObject:(NSString *)className keys:(NSDictionary *)props error:(Fault **)fault;
-(id)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations error:(Fault **)fault;
-(id)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault;
-(id)findById:(NSString *)entityName sid:(NSString *)sid error:(Fault **)fault;
-(id)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations error:(Fault **)fault;
-(id)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault;
-(id)findByClassId:(Class)entity sid:(NSString *)sid error:(Fault **)fault;
-(NSNumber *)remove:(id)entity error:(Fault **)fault;
-(NSNumber *)remove:(Class)entity sid:(NSString *)sid error:(Fault **)fault;
-(NSArray *)getView:(NSString *)viewName dataQuery:(BackendlessDataQuery *)dataQuery error:(Fault **)fault;
-(NSArray *)callStoredProcedure:(NSString *)spName arguments:(NSDictionary *)arguments error:(Fault **)fault;
-(NSNumber *)getObjectCount:(Class)entity error:(Fault **)fault;
-(NSNumber *)getObjectCount:(Class)entity dataQuery:(DataQueryBuilder *)dataQuery error:(Fault **)fault;
//
-(id)setRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects error:(Fault **)fault;
-(NSNumber *)setRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause error:(Fault **)fault;
-(id)addRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects error:(Fault **)fault;
-(NSNumber *)addRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause error:(Fault **)fault;
-(id)deleteRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects error:(Fault **)fault;
-(NSNumber *)deleteRelation:(NSString *)parentObject columnName: (NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause error:(Fault **)fault;
-(id)loadRelations:(NSString *)parentType objectID:(NSString *)objectID queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder error:(Fault **)fault;
/*
-(id)bulkCreate:(NSArray *)objects error:(Fault **)fault;
-(id)bulkDelete:(NSArray *)objects error:(Fault **)fault;
-(id)bulkDeleteByIds:(NSArray<NSString*> *)objectIDs error:(Fault **)fault;
-(NSNumber *)bulkDeleteByWhereClause:(NSString *)whereClause error:(Fault **)fault;
-(NSNumber *)bulkUpdate:(NSArray *)objects error:(Fault **)fault;
 */

// async methods with block-based callbacks
-(void)describe:(NSString *)classCanonicalName response:(void(^)(NSArray<ObjectProperty*> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)save:(NSString *)entityName entity:(NSDictionary *)entity response:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)update:(NSString *)entityName entity:(NSDictionary *)entity sid:(NSString *)sid response:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)save:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)create:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)update:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)find:(Class)entity dataQuery:(DataQueryBuilder *)dataQuery response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)first:(Class)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)first:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)last:(Class)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)last:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByObject:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByObject:(id)entity relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByObject:(id)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByObject:(NSString *)className keys:(NSDictionary *)props response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)entityName sid:(NSString *)sid response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByClassId:(Class)entity sid:(NSString *)sid response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)remove:(id)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)remove:(Class)entity sid:(NSString *)sid response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getView:(NSString *)viewName dataQuery:(BackendlessDataQuery *)dataQuery response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)callStoredProcedure:(NSString *)spName arguments:(NSDictionary *)arguments response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getObjectCount:(Class)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getObjectCount:(Class)entity dataQuery:(DataQueryBuilder *)dataQuery response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
//
-(void)setRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)setRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)deleteRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)deleteRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)loadRelations:(NSString *)parentType objectID:(NSString *)objectID queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;

/*
-(void)bulkCreate:(NSArray *)objects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)bulkDelete:(NSArray *)objects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)bulkDeleteByIds:(NSArray<NSString*> *)objectIDs response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)bulkDeleteByWhereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)bulkUpdate:(NSArray *)objects response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
*/

// IDataStore class factory
-(id <IDataStore>)of:(Class)entityClass;
// MapDrivenDataStore factory
-(MapDrivenDataStore *)ofTable:(NSString *)tableName;

// utilites
-(id)getObjectId:(id)object;
-(NSDictionary *)getObjectMetadata:(id)object;
-(void)mapTableToClass:(NSString *)tableName type:(Class)type;
-(NSString *)typeClassName:(Class)entity;
-(NSString *)objectClassName:(id)object;
-(NSDictionary *)propertyDictionary:(id)object;
-(id)propertyObject:(id)object;

@end
