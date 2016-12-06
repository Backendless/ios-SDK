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

@class QueryOptions, BackendlessDataQuery, Fault, ObjectProperty;
@protocol IResponder;

@protocol IDataStore <NSObject>

// sync methods with fault return (as exception)
-(id)save:(id)entity;
-(NSNumber *)remove:(id)entity;
-(NSNumber *)removeID:(NSString *)objectID;
-(id)removeAll:(BackendlessDataQuery *)dataQuery;
-(NSArray *)find;
-(NSArray *)find:(BackendlessDataQuery *)dataQuery;
-(id)findFirst;
-(id)findLast;
-(NSArray<ObjectProperty*> *)describe;
-(id)load:(id)object relations:(NSArray *)relations;
-(id)findFirst:(int)relationsDepth;
-(id)findLast:(int)relationsDepth;
-(id)findID:(id)objectID;
-(id)findID:(id)objectID relationsDepth:(int)relationsDepth;
-(NSNumber *)getObjectCount;
-(NSNumber *)getObjectCount:(BackendlessDataQuery *)dataQuery;

// sync methods with fault option
-(id)save:(id)entity fault:(Fault **)fault;
-(NSNumber *)remove:(id)entity fault:(Fault **)fault;
-(NSNumber *)removeID:(NSString *)objectID fault:(Fault **)fault;
-(NSArray *)removeAll:(BackendlessDataQuery *)dataQuery fault:(Fault **)fault;
-(NSArray *)findFault:(Fault **)fault;
-(NSArray *)find:(BackendlessDataQuery *)dataQuery fault:(Fault **)fault;
-(id)findFirstFault:(Fault **)fault;
-(id)findLastFault:(Fault **)fault;
-(NSArray<ObjectProperty*> *)describe:(Fault **)fault;
-(id)load:(id)object relations:(NSArray *)relations fault:(Fault **)fault;
-(id)findFirst:(int)relationsDepth fault:(Fault **)fault;
-(id)findLast:(int)relationsDepth fault:(Fault **)fault;
-(id)findID:(id)objectID fault:(Fault **)fault;
-(id)findID:(id)objectID relationsDepth:(int)relationsDepth fault:(Fault **)fault;

// async methods with block-based callbacks
-(void)save:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)remove:(id)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeID:(NSString *)objectID response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeAll:(BackendlessDataQuery *)dataQuery response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)find:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)find:(BackendlessDataQuery *)dataQuery response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findFirst:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findLast:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)describeResponse:(void(^)(NSArray<ObjectProperty*> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)load:(id)object relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findFirst:(int)relationsDepth response:(void(^)(id result))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findLast:(int)relationsDepth response:(void(^)(id result))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findID:(id)objectID response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findID:(id)objectID relationsDepth:(int)relationsDepth response:(void(^)(id result))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getObjectCount:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getObjectCount:(BackendlessDataQuery *)dataQuery response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;

@end
