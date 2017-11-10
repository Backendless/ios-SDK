//
//  RTListener+RTListenerMethods.h
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

#import "RTListener.h"

@interface RTListener ()

-(void)addSubscription:(NSString *)type options:(NSDictionary *)options onResult:(void(^)(id))onResult handleResultSelector:(SEL)handleResultSelector fromClass:(id)subscriptionClassInstance;

-(void)stopSubscription:(NSString *)event whereClause:(NSString *)whereClause onResult:(void(^)(id))onResult;
-(void)addSimpleListener:(NSString *)type callBack:(void(^)(id))callback;
-(void)removeSimpleListener:(NSString *)type callBack:(void(^)(id))callback;
-(void)removeSimpleListener:(NSString *)type;

@end
