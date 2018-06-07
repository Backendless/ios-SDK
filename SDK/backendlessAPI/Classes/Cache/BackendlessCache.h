//
//  BackendlessCache.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
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
#import "BackendlessCachePolicy.h"
@class BackendlessCacheKey;
@protocol IResponder;

#define backendlessCache [BackendlessCache sharedInstance]

@interface BackendlessCache : NSObject

@property (strong, nonatomic) BackendlessCachePolicy *cachePolicy;
@property (strong, nonatomic, readonly) NSNumber *storedType;
@property (strong, nonatomic, readonly) NSMutableDictionary *cacheData;

+(BackendlessCache *)sharedInstance;

-(void)addCacheObject:(id)object forKey:(BackendlessCacheKey *)key;
-(void)addCacheObject:(id)object forClassName:(NSString *)className query:(id)query;
-(id)objectForClassName:(NSString *)className query:(id)query;
-(id)objectForCacheKey:(BackendlessCacheKey *)key;
-(BOOL)hasResultForClassName:(NSString *)className query:(id)query;
-(void)clearCacheForClassName:(NSString *)className query:(id)query;
-(void)clearCacheForKey:(BackendlessCacheKey *)key;
-(void)clearAllCache;
-(void)storedType:(BackendlessCacheStoredEnum)storedType;
-(void)clearFromDisc;
-(void)saveOnDisc;
-(void)loadFromDisc;
-(id)invokeSync:(NSString *)className method:(NSString *)methodName args:(NSArray *)args;
-(void)invokeAsync:(NSString *)className method:(NSString *)methodName args:(NSArray *)args responder:(id <IResponder>)responder;

@end
