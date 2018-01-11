//
//  RTDataStore.h
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
#import "BulkResultObject.h"

typedef enum {
    MAPDRIVENDATASTORE = 0,
    DATASTOREFACTORY = 1
} DataStoreTypeEnum;

@interface RTDataStore : RTListener

-(instancetype)initWithTableName:(NSString *)tableName withEntity:(Class)tableEntity dataStoreType:(UInt32)dataStoreType;
-(Class)getTableEntity;
-(UInt32)getType;

-(void)addErrorListener:(void(^)(Fault *))errorBlock;
-(void)removeErrorListeners:(void(^)(Fault *))errorBlock;
-(void)removeErrorListeners;

-(void)addCreateListener:(void(^)(id))onCreate;
-(void)addCreateListener:(NSString *)whereClause onCreate:(void(^)(id))onCreate;
-(void)removeCreateListeners:(NSString *)whereClause onCreate:(void(^)(id))onCreate;
-(void)removeCreateListenersWithCallback:(void(^)(id))onCreate;
-(void)removeCreateListenersWithWhereClause:(NSString *)whereClause;
-(void)removeCreateListeners;

-(void)addUpdateListener:(void(^)(id))onUpdate;
-(void)addUpdateListener:(NSString *)whereClause onUpdate:(void(^)(id))onUpdate;
-(void)removeUpdateListeners:(NSString *)whereClause onUpdate:(void(^)(id))onUpdate;
-(void)removeUpdateListenersWithCallback:(void(^)(id))onUpdate;
-(void)removeUpdateListenersWithWhereClause:(NSString *)whereClause;
-(void)removeUpdateListeners;

-(void)addDeleteListener:(void(^)(id))onDelete;
-(void)addDeleteListener:(NSString *)whereClause onDelete:(void(^)(id))onDelete;
-(void)removeDeleteListeners:(NSString *)whereClause onDelete:(void(^)(id))onDelete;
-(void)removeDeleteListenersWithCallback:(void(^)(id))onDelete;
-(void)removeDeleteListenersWithWhereClause:(NSString *)whereClause;
-(void)removeDeleteListeners;

-(void)addBulkUpdateListener:(void(^)(BulkResultObject *))onBulkUpdate;
-(void)removeBulkUpdateListeners:(void(^)(BulkResultObject *))onBulkUpdate;
-(void)removeBulkUpdateListeners;

-(void)addBulkDeleteListener:(void(^)(NSNumber *))onBulkDelete;
-(void)removeBulkDeleteListeners:(void(^)(NSNumber *))onBulkDelete;
-(void)removeBulkDeleteListeners;

-(void)removeAllListeners;

@end

