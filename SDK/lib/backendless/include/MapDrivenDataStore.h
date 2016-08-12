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

@class BackendlessCollection, BackendlessDataQuery, Fault;
@protocol IResponder;

@interface MapDrivenDataStore : NSObject
@property (strong, nonatomic, readonly) NSString *tableName;

+(id)createDataStore:(NSString *)tableName;

// sync methods with fault return (as exception)
-(NSDictionary<NSString*,id> *)save:(NSDictionary<NSString*,id> *)entity;
-(NSNumber *)remove:(NSDictionary<NSString*,id> *)entity;
-(BackendlessCollection *)find;
-(BackendlessCollection *)find:(BackendlessDataQuery *)dataQuery;
-(NSDictionary<NSString*,id> *)findFirst;
-(NSDictionary<NSString*,id> *)findFirst:(int)relationsDepth;
-(NSDictionary<NSString*,id> *)findFirstWithRelations:(NSArray<NSString*> *)relations;
-(NSDictionary<NSString*,id> *)findFirst:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth;
-(NSDictionary<NSString*,id> *)findLast;
-(NSDictionary<NSString*,id> *)findLast:(int)relationsDepth;
-(NSDictionary<NSString*,id> *)findLastWithRelations:(NSArray<NSString*> *)relations;
-(NSDictionary<NSString*,id> *)findLast:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth;
-(NSDictionary<NSString*,id> *)findById:(NSString *)objectId;
-(NSDictionary<NSString*,id> *)findById:(NSString *)objectId relationsDepth:(int)relationsDepth;
-(NSDictionary<NSString*,id> *)findByIdWithRelations:(NSString *)objectId relations:(NSArray<NSString*> *)relations;
-(NSDictionary<NSString*,id> *)findById:(NSString *)objectId relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth;
-(NSDictionary<NSString*,id> *)findByEntity:(NSDictionary<NSString*,id> *)entity;
-(NSDictionary<NSString*,id> *)findByEntity:(NSDictionary<NSString*,id> *)entity relationsDepth:(int)relationsDepth;
-(NSDictionary<NSString*,id> *)findByEntityWithRelations:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations;
-(NSDictionary<NSString*,id> *)findByEntity:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth;
-(NSDictionary<NSString*,id> *)loadRelations:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations;

// sync methods with fault option
-(NSDictionary<NSString*,id> *)save:(NSDictionary<NSString*,id> *)entity fault:(Fault **)fault;
-(NSNumber *)remove:(NSDictionary<NSString*,id> *)entity fault:(Fault **)fault;
-(BackendlessCollection *)findFault:(Fault **)fault;
-(BackendlessCollection *)find:(BackendlessDataQuery *)dataQuery fault:(Fault **)fault;
-(NSDictionary<NSString*,id> *)findFirstFault:(Fault **)fault;
-(NSDictionary<NSString*,id> *)findFirst:(int)relationsDepth fault:(Fault **)fault;
-(NSDictionary<NSString*,id> *)findFirstWithRelations:(NSArray<NSString*> *)relations fault:(Fault **)fault;
-(NSDictionary<NSString*,id> *)findFirst:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth fault:(Fault **)fault;
-(NSDictionary<NSString*,id> *)findLastFault:(Fault **)fault;
-(NSDictionary<NSString*,id> *)findLast:(int)relationsDepth fault:(Fault **)fault;
-(NSDictionary<NSString*,id> *)findLastWithRelations:(NSArray<NSString*> *)relations fault:(Fault **)fault;
-(NSDictionary<NSString*,id> *)findLast:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth fault:(Fault **)fault;
-(NSDictionary<NSString*,id> *)findById:(NSString *)objectId fault:(Fault **)fault;
-(NSDictionary<NSString*,id> *)findById:(NSString *)objectId relationsDepth:(int)relationsDepth fault:(Fault **)fault;
-(NSDictionary<NSString*,id> *)findByIdWithRelations:(NSString *)objectId relations:(NSArray<NSString*> *)relations fault:(Fault **)fault;
-(NSDictionary<NSString*,id> *)findById:(NSString *)objectId relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth fault:(Fault **)fault;
-(NSDictionary<NSString*,id> *)findByEntity:(NSDictionary<NSString*,id> *)entity fault:(Fault **)fault;
-(NSDictionary<NSString*,id> *)findByEntity:(NSDictionary<NSString*,id> *)entity relationsDepth:(int)relationsDepth fault:(Fault **)fault;
-(NSDictionary<NSString*,id> *)findByEntityWithRelations:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations fault:(Fault **)fault;
-(NSDictionary<NSString*,id> *)findByEntity:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth fault:(Fault **)fault;
-(NSDictionary<NSString*,id> *)loadRelations:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations fault:(Fault **)fault;

// async methods with responder
-(void)save:(NSDictionary<NSString*,id> *)entity responder:(id <IResponder>)responder;
-(void)remove:(NSDictionary<NSString*,id> *)entity responder:(id <IResponder>)responder;
-(void)findResponder:(id <IResponder>)responder;
-(void)find:(BackendlessDataQuery *)dataQuery responder:(id <IResponder>)responder;
-(void)findFirstResponder:(id <IResponder>)responder;
-(void)findFirst:(int)relationsDepth responder:(id <IResponder>)responder;
-(void)findFirstWithRelations:(NSArray<NSString*> *)relations responder:(id <IResponder>)responder;
-(void)findFirst:(NSArray<NSString *> *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder;
-(void)findLastResponder:(id <IResponder>)responder;
-(void)findLast:(int)relationsDepth responder:(id <IResponder>)responder;
-(void)findLastWithRelations:(NSArray<NSString*> *)relations responder:(id <IResponder>)responder;
-(void)findLast:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder;
-(void)findById:(NSString *)objectId responder:(id <IResponder>)responder;
-(void)findById:(NSString *)objectId relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder;
-(void)findByIdWithRelations:(NSString *)objectId relations:(NSArray<NSString*> *)relations responder:(id <IResponder>)responder;
-(void)findById:(NSString *)objectId relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder;
-(void)findByEntity:(NSDictionary<NSString*,id> *)entity responder:(id <IResponder>)responder;
-(void)findByEntity:(NSDictionary<NSString*,id> *)entity relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder;
-(void)findByEntityWithRelations:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations responder:(id <IResponder>)responder;
-(void)findByEntity:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder;
-(void)loadRelations:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations responder:(id <IResponder>)responder;

// async methods with block-based callbacks
-(void)save:(NSDictionary<NSString*,id> *)entity response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)remove:(NSDictionary<NSString*,id> *)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)find:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)find:(BackendlessDataQuery *)dataQuery response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findFirst:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findFirst:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findFirstWithRelations:(NSArray<NSString*> *)relations response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findFirst:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findLast:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findLast:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findLastWithRelations:(NSArray<NSString*> *)relations response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findLast:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)objectId response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)objectId relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByIdWithRelations:(NSString *)objectId relations:(NSArray<NSString*> *)relations response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)objectId relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByEntity:(NSDictionary<NSString*,id> *)entity response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByEntity:(NSDictionary<NSString*,id> *)entity relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByEntityWithRelations:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findByEntity:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)loadRelations:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock;

@end
