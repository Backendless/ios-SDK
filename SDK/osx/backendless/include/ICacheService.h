//
//  ICacheService.h
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

@class Fault;

@protocol ICacheService <NSObject>

// sync methods with fault return (as exception)
-(void)put:(id)entity;
-(void)put:(id)entity timeToLive:(int)seconds;
-(id)get;
-(BOOL)contains;
-(void)expireIn:(int)seconds;
-(void)expireAt:(NSDate *)timestamp;
-(void)remove;

// async methods with block-based callback
-(void)put:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)put:(id)entity timeToLive:(int)seconds response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)get:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)contains:(void(^)(BOOL))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)expireIn:(int)seconds response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)expireAt:(NSDate *)timestamp response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)remove:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;

@end
