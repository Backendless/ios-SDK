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

#define PERSIST_OBJECT_ID @"objectId"
#define PERSIST_CLASS(CLASS) [backendless.persistenceService of:[CLASS class]]

extern NSString *LOAD_ALL_RELATIONS;

@class BackendlessCollection, QueryOptions, BackendlessDataQuery, Fault;
@protocol IResponder, IDataStore;


@interface PersistenceService : NSObject

// sync methods
////deprecated
-(NSDictionary *)save:(NSString *)entityName entity:(NSDictionary *)entity;
-(NSDictionary *)update:(NSString *)entityName entity:(NSDictionary *)entity sid:(NSString *)sid;
-(id)save:(id)entity;
-(id)create:(id)entity;
-(id)update:(id)entity; 
-(NSNumber *)remove:(Class)entity sid:(NSString *)sid; 
-(void)removeAll:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery;
-(id)findById:(NSString *)entityName sid:(NSString *)sid;
-(id)findByClassId:(Class)entity sid:(NSString *)sid; 
-(BackendlessCollection *)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery;
-(id)first:(Class)entity;
-(id)last:(Class)entity;
-(NSArray *)describe:(NSString *)classCanonicalName;
-(id)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations;
-(id)load:(id)object relations:(NSArray *)relations;

///new
-(NSDictionary *)save:(NSString *)entityName entity:(NSDictionary *)entity error:(Fault **)fault;
-(NSDictionary *)update:(NSString *)entityName entity:(NSDictionary *)entity sid:(NSString *)sid error:(Fault **)fault;
-(id)save:(id)entity error:(Fault **)fault;
-(id)create:(id)entity error:(Fault **)fault;
-(id)update:(id)entity error:(Fault **)fault;
-(BOOL)remove:(Class)entity sid:(NSString *)sid error:(Fault **)fault;
-(BOOL)removeAll:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery error:(Fault **)fault;
-(id)findById:(NSString *)entityName sid:(NSString *)sid error:(Fault **)fault;
-(id)findByClassId:(Class)entity sid:(NSString *)sid error:(Fault **)fault;
-(BackendlessCollection *)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery error:(Fault **)fault;
-(id)first:(Class)entity error:(Fault **)fault;
-(id)last:(Class)entity error:(Fault **)fault;
-(NSArray *)describe:(NSString *)classCanonicalName error:(Fault **)fault;
-(id)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations error:(Fault **)fault;
-(id)load:(id)object relations:(NSArray *)relations error:(Fault **)fault;
-(id)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault;
-(id)first:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault;
-(id)last:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault;
-(id)load:(id)object relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault;

// async methods with responder
-(void)save:(NSString *)entityName entity:(NSDictionary *)entity responder:(id <IResponder>)responder;
-(void)update:(NSString *)entityName entity:(NSDictionary *)entity sid:(NSString *)sid responder:(id <IResponder>)responder;
-(void)save:(id)entity responder:(id <IResponder>)responder;
-(void)create:(id)entity responder:(id <IResponder>)responder;
-(void)update:(id)entity responder:(id <IResponder>)responder; 
-(void)remove:(Class)entity sid:(NSString *)sid responder:(id <IResponder>)responder;
-(void)removeAll:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery responder:(id <IResponder>)responder;
-(void)findById:(NSString *)entityName sid:(NSString *)sid responder:(id <IResponder>)responder; 
-(void)findByClassId:(Class)entity sid:(NSString *)sid responder:(id <IResponder>)responder; 
-(void)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery responder:(id <IResponder>)responder;
-(void)first:(Class)entity responder:(id <IResponder>)responder;
-(void)last:(Class)entity responder:(id <IResponder>)responder;
-(void)describe:(NSString *)classCanonicalName responder:(id <IResponder>)responder;
-(void)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations responder:(id <IResponder>)responder;
-(void)load:(id)object relations:(NSArray *)relations responder:(id <IResponder>)responder;
-(void)load:(id)object relations:(NSArray *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder;
-(void)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder;
-(void)first:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder;
-(void)last:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder;

// async methods with block-base callbacks
-(void)save:(NSString *)entityName entity:(NSDictionary *)entity response:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)update:(NSString *)entityName entity:(NSDictionary *)entity sid:(NSString *)sid response:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)save:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)create:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)update:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)remove:(Class)entity sid:(NSString *)sid response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeAll:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)entityName sid:(NSString *)sid response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByClassId:(Class)entity sid:(NSString *)sid response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)first:(Class)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)last:(Class)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)describe:(NSString *)classCanonicalName response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)load:(id)object relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)load:(id)object relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)first:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)last:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;

// IDataStore class factory
-(id <IDataStore>)of:(Class)entityClass;

// utilites
-(NSDictionary *)getObjectMetadata:(id)object;

@end
