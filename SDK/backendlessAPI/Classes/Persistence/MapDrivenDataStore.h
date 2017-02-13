//
//  MapDrivenDataStore.h
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

#import <Foundation/Foundation.h>
#import "IDataStore.h"

@class BackendlessDataQuery, Fault;
@protocol IResponder;

@interface MapDrivenDataStore : NSObject <IDataStore>
@property (strong, nonatomic, readonly) NSString *tableName;

+(id)createDataStore:(NSString *)tableName;

// sync methods with fault return (as exception)
-(NSDictionary<NSString*,id> *)save:(NSDictionary<NSString*,id> *)entity;
-(NSNumber *)remove:(NSDictionary<NSString*,id> *)entity;
-(NSArray *)find;
-(NSArray *)find:(BackendlessDataQuery *)dataQuery;
-(NSDictionary<NSString*,id> *)findFirst;
-(NSDictionary<NSString*,id> *)findFirst:(int)relationsDepth;
-(NSDictionary<NSString*,id> *)findFirst:(NSArray<NSString*> *)relations;
-(NSDictionary<NSString*,id> *)findFirst:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth;
-(NSDictionary<NSString*,id> *)findLast;
-(NSDictionary<NSString*,id> *)findLast:(int)relationsDepth;
-(NSDictionary<NSString*,id> *)findLast:(NSArray<NSString*> *)relations;
-(NSDictionary<NSString*,id> *)findLast:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth;
-(NSDictionary<NSString*,id> *)findById:(NSString *)objectId;
-(NSDictionary<NSString*,id> *)findById:(NSString *)objectId relationsDepth:(int)relationsDepth;
-(NSDictionary<NSString*,id> *)findById:(NSString *)objectId relations:(NSArray<NSString*> *)relations;
-(NSDictionary<NSString*,id> *)findById:(NSString *)objectId relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth;
-(NSNumber *)getObjectCount;
-(NSNumber *)getObjectCount:(DataQueryBuilder *)dataQuery;
//
-(NSNumber *)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects;
-(NSNumber *)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause;
-(NSNumber *)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects;
-(NSNumber *)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause;
-(NSNumber *)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects;
-(NSNumber *)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause;

-(NSArray*)loadRelations:(NSString *)objectID queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder;

// async methods with block-based callbacks
-(void)save:(NSDictionary<NSString*,id> *)entity response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)remove:(NSDictionary<NSString*,id> *)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)find:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)find:(BackendlessDataQuery *)dataQuery response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findFirst:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findFirst:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findFirst:(NSArray<NSString*> *)relations response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findFirst:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findLast:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findLast:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findLast:(NSArray<NSString*> *)relations response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findLast:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)objectId response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)objectId relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)objectId relations:(NSArray<NSString*> *)relations response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)objectId relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getObjectCount:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getObjectCount:(DataQueryBuilder *)dataQuery response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
//
-(void)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)setRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)deleteRelation:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;

-(void)loadRelations:(NSString *)objectID queryBuilder:(LoadRelationsQueryBuilder *)queryBuilder response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;

@end
