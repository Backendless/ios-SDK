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

#define PERSIST_OBJECT_ID @"objectId"
#define PERSIST_CLASS(CLASS) [backendless.persistenceService of:[CLASS class]]

extern NSString *LOAD_ALL_RELATIONS;

@class BackendlessCollection, QueryOptions, BackendlessDataQuery, Fault, ObjectProperty;
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
-(id)load:(id)object relations:(NSArray *)relations;
-(id)load:(id)object relations:(NSArray *)relations relationsDepth:(int)relationsDepth;
-(BackendlessCollection *)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery;
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
-(id)removeAll:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery;
-(BackendlessCollection *)getView:(NSString *)viewName dataQuery:(BackendlessDataQuery *)dataQuery;
-(BackendlessCollection *)callStoredProcedure:(NSString *)spName arguments:(NSDictionary *)arguments;

// sync methods with fault option
-(NSArray<ObjectProperty*> *)describe:(NSString *)classCanonicalName error:(Fault **)fault;
-(NSDictionary *)save:(NSString *)entityName entity:(NSDictionary *)entity error:(Fault **)fault;
-(NSDictionary *)update:(NSString *)entityName entity:(NSDictionary *)entity sid:(NSString *)sid error:(Fault **)fault;
-(id)save:(id)entity error:(Fault **)fault;
-(id)create:(id)entity error:(Fault **)fault;
-(id)update:(id)entity error:(Fault **)fault;
-(id)load:(id)object relations:(NSArray *)relations error:(Fault **)fault;
-(id)load:(id)object relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault;
-(BackendlessCollection *)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery error:(Fault **)fault;
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
-(BackendlessCollection *)removeAll:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery error:(Fault **)fault;
-(BackendlessCollection *)getView:(NSString *)viewName dataQuery:(BackendlessDataQuery *)dataQuery error:(Fault **)fault;
-(BackendlessCollection *)callStoredProcedure:(NSString *)spName arguments:(NSDictionary *)arguments error:(Fault **)fault;

// async methods with responder
-(void)describe:(NSString *)classCanonicalName responder:(id <IResponder>)responder;
-(void)save:(NSString *)entityName entity:(NSDictionary *)entity responder:(id <IResponder>)responder;
-(void)update:(NSString *)entityName entity:(NSDictionary *)entity sid:(NSString *)sid responder:(id <IResponder>)responder;
-(void)save:(id)entity responder:(id <IResponder>)responder;
-(void)create:(id)entity responder:(id <IResponder>)responder;
-(void)update:(id)entity responder:(id <IResponder>)responder; 
-(void)load:(id)object relations:(NSArray *)relations responder:(id <IResponder>)responder;
-(void)load:(id)object relations:(NSArray *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder;
-(void)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery responder:(id <IResponder>)responder;
-(void)first:(Class)entity responder:(id <IResponder>)responder;
-(void)first:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder;
-(void)last:(Class)entity responder:(id <IResponder>)responder;
-(void)last:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder;
-(void)findByObject:(id)entity responder:(id <IResponder>)responder;
-(void)findByObject:(id)entity relations:(NSArray *)relations responder:(id <IResponder>)responder;
-(void)findByObject:(id)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder;
-(void)findByObject:(NSString *)className keys:(NSDictionary *)props responder:(id <IResponder>)responder;
-(void)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations responder:(id <IResponder>)responder;
-(void)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder;
-(void)findById:(NSString *)entityName sid:(NSString *)sid responder:(id <IResponder>)responder;
-(void)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations responder:(id <IResponder>)responder;
-(void)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder;
-(void)findByClassId:(Class)entity sid:(NSString *)sid responder:(id <IResponder>)responder;
-(void)remove:(id)entity responder:(id <IResponder>)responder;
-(void)remove:(Class)entity sid:(NSString *)sid responder:(id <IResponder>)responder;
-(void)removeAll:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery responder:(id <IResponder>)responder;
-(void)getView:(NSString *)viewName dataQuery:(BackendlessDataQuery *)dataQuery responder:(id <IResponder>)responder;
-(void)callStoredProcedure:(NSString *)spName arguments:(NSDictionary *)arguments responder:(id <IResponder>)responder;

// async methods with block-based callbacks
-(void)describe:(NSString *)classCanonicalName response:(void(^)(NSArray<ObjectProperty*> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)save:(NSString *)entityName entity:(NSDictionary *)entity response:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)update:(NSString *)entityName entity:(NSDictionary *)entity sid:(NSString *)sid response:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)save:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)create:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)update:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)load:(id)object relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)load:(id)object relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
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
-(void)removeAll:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getView:(NSString *)viewName dataQuery:(BackendlessDataQuery *)dataQuery response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)callStoredProcedure:(NSString *)spName arguments:(NSDictionary *)arguments response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;

// IDataStore class factory
-(id <IDataStore>)of:(Class)entityClass;

// utilites
-(id)getObjectId:(id)object;
-(NSDictionary *)getObjectMetadata:(id)object;
-(void)mapTableToClass:(NSString *)tableName type:(Class)type;
-(NSString *)typeClassName:(Class)entity;
-(NSString *)objectClassName:(id)object;
-(NSDictionary *)propertyDictionary:(id)object;
-(id)propertyObject:(id)object;

@end
