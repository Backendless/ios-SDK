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

@class BackendlessCollection, QueryOptions, BackendlessDataQuery, Fault;
@protocol IResponder;

@protocol IDataStore <NSObject>

// sync
-(id)save:(id)entity;
-(id)findID:(NSString *)objectID;
-(NSNumber *)remove:(id)entity;
-(NSNumber *)removeID:(NSString *)objectID;
-(void)removeAll:(BackendlessDataQuery *)dataQuery;
-(BackendlessCollection *)find:(BackendlessDataQuery *)dataQuery;
-(id)findFirst;
-(id)findLast;
-(NSArray *)describe;
-(void)load:(id)object relations:(NSArray *)relations;

// async methods with responder
-(void)save:(id)entity responder:(id <IResponder>)responder;
-(void)findID:(NSString *)objectID responder:(id <IResponder>)responder;
-(void)remove:(id)entity responder:(id <IResponder>)responder;
-(void)removeID:(NSString *)objectID responder:(id <IResponder>)responder;
-(void)removeAll:(BackendlessDataQuery *)dataQuery responder:(id <IResponder>)responder;
-(void)find:(BackendlessDataQuery *)dataQuery responder:(id <IResponder>)responder;
-(void)findFirst:(id <IResponder>)responder;
-(void)findLast:(id <IResponder>)responder;
-(void)describeResponder:(id <IResponder>)responder;
-(void)load:(id)object relations:(NSArray *)relations responder:(id <IResponder>)responder;

// async methods with block-base callbacks
-(void)save:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findID:(NSString *)objectID response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)remove:(id)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeID:(NSString *)objectID response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeAll:(BackendlessDataQuery *)dataQuery responder:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)find:(BackendlessDataQuery *)dataQuery response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findFirst:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findLast:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)describeResponse:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)load:(id)object relations:(NSArray *)relations response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
@end
