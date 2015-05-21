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

@protocol IResponder;
@class Fault;

@interface CacheService : NSObject

// sync methods with fault return (as exception)
-(id)put:(NSString *)key object:(id)entity;
-(id)put:(NSString *)key object:(id)entity timeToLive:(int)seconds;
-(id)get:(NSString *)key;
-(NSNumber *)contains:(NSString *)key;
-(id)expireIn:(NSString *)key timeToLive:(int)seconds;
-(id)expireAt:(NSString *)key timestamp:(NSDate *)timestamp;
-(id)remove:(NSString *)key;

// sync methods with fault option
-(BOOL)put:(NSString *)key object:(id)entity fault:(Fault **)fault;
-(BOOL)put:(NSString *)key object:(id)entity timeToLive:(int)seconds fault:(Fault **)fault;
-(id)get:(NSString *)key fault:(Fault **)fault;
-(NSNumber *)contains:(NSString *)key fault:(Fault **)fault;
-(BOOL)expireIn:(NSString *)key timeToLive:(int)seconds fault:(Fault **)fault;
-(BOOL)expireAt:(NSString *)key timestamp:(NSDate *)timestamp fault:(Fault **)fault;
-(BOOL)remove:(NSString *)key fault:(Fault **)fault;

// async methods with responder
-(void)put:(NSString *)key object:(id)entity responder:(id<IResponder>)responder;
-(void)put:(NSString *)key object:(id)entity timeToLive:(int)seconds responder:(id<IResponder>)responder;
-(void)get:(NSString *)key responder:(id<IResponder>)responder;
-(void)contains:(NSString *)key responder:(id<IResponder>)responder;
-(void)expireIn:(NSString *)key timeToLive:(int)seconds responder:(id<IResponder>)responder;
-(void)expireAt:(NSString *)key timestamp:(NSDate *)timestamp responder:(id<IResponder>)responder;
-(void)remove:(NSString *)key responder:(id<IResponder>)responder;

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
