//
//  RTListener.h
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

// ОТ ЭТОГО КЛАССА НАСЛЕДУЕТСЯ DATA STORE

#import <Foundation/Foundation.h>
@class RTSubscription;
@class RTError;

#define ERROR_TYPE @"ERROR"
#define OBJECTS_CHANGES_TYPE @"OBJECTS_CHANGES"

@interface RTListener : NSObject

-(void)addSubscription:(NSString *)type options:(NSDictionary *)options onResult:(void(^)(id))onResult;
-(void)stopSubscription:(NSString *)type onResult:(void(^)(id))onResult whereClause:(NSString *)whereClause;
-(void)addSimpleListener:(NSString *)type callBack:(void (^)(id))callback;
-(void)addErrorListener:(void(^)(RTError *))onError;
-(void)removeErrorListener:(void(^)(RTError *))onError;

@end
