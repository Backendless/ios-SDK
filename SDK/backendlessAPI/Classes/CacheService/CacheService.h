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
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
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

@protocol IResponder;
@class Fault;

@interface CacheService : NSObject
// sync methods with fault option
-(BOOL)put:(NSString *)key object:(id)entity fault:(Fault **)fault;
-(BOOL)put:(NSString *)key object:(id)entity timeToKeep:(int)expire fault:(Fault **)fault;
-(id)get:(NSString *)key fault:(Fault **)fault;
// async methods with responder
-(void)put:(NSString *)key object:(id)entity responder:(id<IResponder>)responder;
-(void)put:(NSString *)key object:(id)entity timeToKeep:(int)expire responder:(id<IResponder>)responder;
-(void)get:(NSString *)key responder:(id<IResponder>)responder;
// async methods with block-based callback
-(void)put:(NSString *)key object:(id)entity response:(void (^)(NSDictionary *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)put:(NSString *)key object:(id)entity timeToKeep:(int)expire response:(void (^)(NSDictionary *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)get:(NSString *)key response:(void (^)(NSDictionary *))responseBlock error:(void (^)(Fault *))errorBlock;
@end
