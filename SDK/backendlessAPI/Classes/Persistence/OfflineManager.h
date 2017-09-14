//
//  OfflineManager.h
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
#import "Backendless.h"
@class BEReachability;

typedef enum {
    CREATE = 0,
    UPDATE = 1,
    DELETE = 2,
    OTHER = 3
} PersistentStorageOperation;

@interface OfflineManager : NSObject

@property (nonatomic, copy) void (^responseBlock)(void);
@property (nonatomic, copy) void (^errorBlock)(Fault *);
@property(nonatomic) BOOL internetActive;
@property(nonatomic, strong) NSString *tableName;
@property(nonatomic, strong) id<IDataStore> dataStore;

-(void)openDB;
-(void)closeDB;
-(void)dropTable;
-(void)insertIntoDB:(NSArray *)insertObjects withNeedUpload:(int)needUpload withOperation:(int)operation response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)updateRecord:(id)object withNeedUpload:(int)needUpload response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)deleteFromTableWithObjectId:(NSString *)objectId response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(NSArray *)readFromDB:(DataQueryBuilder *)queryBuilder;
-(void)markObjectForDeleteWithObjectId:(NSString *)objectId response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;

@end
