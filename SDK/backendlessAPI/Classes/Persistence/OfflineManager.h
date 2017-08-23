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

#define offlineManager [OfflineManager sharedInstance]

@interface OfflineManager : NSObject

@property(nonatomic) BOOL internetActive;
@property(nonatomic, strong) NSString *tableName;

+(OfflineManager *)sharedInstance;
-(void)openDB;
-(void)closeDB;
-(void)dropTable;
-(void)insertIntoDB:(NSArray *)insertObjects;
-(NSArray *)readFromDB:(DataQueryBuilder *)queryBuilder;
-(void)updateRecord:(id)object;

@end
