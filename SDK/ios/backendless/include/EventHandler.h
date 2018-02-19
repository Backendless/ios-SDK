//
//  EventHandler.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2017 BACKENDLESS.COM. All Rights Reserved.
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
#import "RTListener.h"
#import "Responder.h"
#import "BulkEvent.h"

typedef enum {
    MAPDRIVENDATASTORE = 0,
    DATASTOREFACTORY = 1
} DataStoreTypeEnum;

@interface EventHandler : RTListener

-(instancetype)initWithTableName:(NSString *)tableName withEntity:(Class)tableEntity dataStoreType:(UInt32)dataStoreType;
-(Class)getTableEntity;
-(UInt32)getType;

-(void)addCreateListener:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addCreateListener:(NSString *)whereClause response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeCreateListener:(void(^)(id))responseBlock;
-(void)removeCreateListener:(NSString *)whereClause response:(void(^)(id))responseBlock;
-(void)removeCreateListeners:(NSString *)whereClause;
-(void)removeCreateListeners;

-(void)addUpdateListener:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addUpdateListener:(NSString *)whereClause response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeUpdateListener:(void(^)(id))responseBlock;
-(void)removeUpdateListener:(NSString *)whereClause response:(void(^)(id))responseBlock;
-(void)removeUpdateListeners:(NSString *)whereClause;
-(void)removeUpdateListeners;

-(void)addDeleteListener:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addDeleteListener:(NSString *)whereClause response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeDeleteListener:(void(^)(id))responseBlock;
-(void)removeDeleteListener:(NSString *)whereClause response:(void(^)(id))responseBlock;
-(void)removeDeleteListeners:(NSString *)whereClause;
-(void)removeDeleteListeners;

-(void)addBulkUpdateListener:(void(^)(BulkEvent *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addBulkUpdateListener:(NSString *)whereClause response:(void(^)(BulkEvent *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeBulkUpdateListener:(void(^)(BulkEvent *))responseBlock;
-(void)removeBulkUpdateListener:(NSString *)whereClause response:(void(^)(BulkEvent *))responseBlock;
-(void)removeBulkUpdateListeners:(NSString *)whereClause;
-(void)removeBulkUpdateListeners;

-(void)addBulkDeleteListener:(void(^)(BulkEvent *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)addBulkDeleteListener:(NSString *)whereClause response:(void(^)(BulkEvent *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeBulkDeleteListener:(void(^)(BulkEvent *))responseBlock;
-(void)removeBulkDeleteListener:(NSString *)whereClause response:(void(^)(BulkEvent *))responseBlock;
-(void)removeBulkDeleteListeners:(BulkEvent *)whereClause;
-(void)removeBulkDeleteListeners;

-(void)removeAllListeners;

@end

