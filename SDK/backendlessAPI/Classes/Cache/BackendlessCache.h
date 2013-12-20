//
//  BackendlessCache.h
//  backendlessAPI
//
//  Created by Yury Yaschenko on 8/12/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackendlessCachePolicy.h"

#define backendlessCache [BackendlessCache sharedInstance]
@class BackendlessCacheKey;

@protocol IResponder;

@interface BackendlessCache : NSObject

@property (nonatomic, strong) BackendlessCachePolicy *cachePolicy;
@property (nonatomic, strong, readonly) NSNumber *storedType;
@property (nonatomic, strong, readonly) NSMutableDictionary *cacheData;

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
+(BackendlessCache *)sharedInstance;

-(id)invokeSync:(NSString *)className method:(NSString *)methodName args:(NSArray *)args;
-(void)invokeAsync:(NSString *)className method:(NSString *)methodName args:(NSArray *)args responder:(id <IResponder>)responder;
@end
