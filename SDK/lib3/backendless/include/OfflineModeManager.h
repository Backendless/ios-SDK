//
//  OfflineModeManager.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2014 BACKENDLESS.COM. All Rights Reserved.
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

@class ISDatabase;
@class BackendlessCollection, BackendlessDataQuery;
@interface OfflineModeManager : NSObject
@property (nonatomic, retain) ISDatabase *dataBase;
@property (nonatomic) BOOL isOfflineMode;
+(OfflineModeManager *)sharedInstance;
-(id)initWithDataBaseName:(NSString *)name;
-(id)initWithDefaultDataBaseName;
-(id)saveObject:(id)object;
-(id)getObjectForId:(NSString *)objectId;
-(void)startUploadData;
-(void)removeObjectWithObjectId:(NSString *)objectId;
@end
