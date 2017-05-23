//
//  CacheService.h
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
#import "ICacheService.h"

@class Fault;

@interface CacheService : NSObject

// sync methods with fault return (as exception)
-(void)put:(NSString *)key object:(id)entity;
-(void)put:(NSString *)key object:(id)entity timeToLive:(int)seconds;
-(id)get:(NSString *)key;
-(NSNumber *)contains:(NSString *)key;
-(id)expireIn:(NSString *)key timeToLive:(int)seconds;
-(id)expireAt:(NSString *)key timestamp:(NSDate *)timestamp;
-(id)remove:(NSString *)key;

// async methods with block-based callbacks
-(void)put:(NSString *)key object:(id)entity response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)put:(NSString *)key object:(id)entity timeToLive:(int)seconds response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)get:(NSString *)key response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)contains:(NSString *)key response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)expireIn:(NSString *)key timeToLive:(int)seconds response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)expireAt:(NSString *)key timestamp:(NSDate *)timestamp response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)remove:(NSString *)key response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock;

// ICacheService factory
-(id <ICacheService>)with:(NSString *)key;
-(id <ICacheService>)with:(NSString *)key type:(Class)entityClass;

@end
