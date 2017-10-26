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
#import "Backendless.h"

@interface RTDataStore : NSObject

@property (strong, nonatomic) NSMutableDictionary<NSString *, NSMutableArray*> *simpleListener;
@property (strong, nonatomic) NSMutableDictionary *subscriptions;

@property (strong, nonatomic) NSString *subscriptionId;
@property (strong, nonatomic) NSString *event;
@property (strong, nonatomic) NSString *tableName;
@property (strong, nonatomic) id<IDataStore> dataStore;

-(void)addErrorListener:(void (^)(NSDictionary *))onError;
-(void)addCreateListener:(void (^)(id))onCreate;

@end
