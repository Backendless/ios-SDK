//
//  AtomicOperation.h
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
#import "IAtomicCounters.h"

@protocol IResponder;
@class Fault;

@interface AtomicCounters : NSObject

// sync methods with fault option
-(NSNumber *)get:(NSString *)name fault:(Fault **)fault;
-(NSNumber *)getAndIncrement:(NSString *)name fault:(Fault **)fault;
-(NSNumber *)incrementAndGet:(NSString *)name fault:(Fault **)fault;
-(NSNumber *)getAndDecrement:(NSString *)name fault:(Fault **)fault;
-(NSNumber *)decrementAndGet:(NSString *)name fault:(Fault **)fault;
-(NSNumber *)addAndGet:(NSString *)name value:(long)value fault:(Fault **)fault;
-(NSNumber *)getAndAdd:(NSString *)name value:(long)value fault:(Fault **)fault;
-(NSNumber *)compareAndSet:(NSString *)name expected:(long)expected updated:(long)updated fault:(Fault **)fault;

// async methods with responder
-(void)get:(NSString *)name responder:(id<IResponder>)responder;
-(void)getAndIncrement:(NSString *)name responder:(id<IResponder>)responder;
-(void)incrementAndGet:(NSString *)name responder:(id<IResponder>)responder;
-(void)getAndDecrement:(NSString *)name responder:(id<IResponder>)responder;
-(void)decrementAndGet:(NSString *)name responder:(id<IResponder>)responder;
-(void)addAndGet:(NSString *)name value:(long)value responder:(id<IResponder>)responder;
-(void)getAndAdd:(NSString *)name value:(long)value responder:(id<IResponder>)responder;
-(void)compareAndSet:(NSString *)name expected:(long)expected updated:(long)updated responder:(id<IResponder>)responder;

// async methods with block-based callback
-(void)get:(NSString *)name response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)getAndIncrement:(NSString *)name response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)incrementAndGet:(NSString *)name response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)getAndDecrement:(NSString *)name response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)decrementAndGet:(NSString *)name response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)addAndGet:(NSString *)name value:(long)value response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)getAndAdd:(NSString *)name value:(long)value response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)compareAndSet:(NSString *)name expected:(long)expected updated:(long)updated response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;

// IAtomicCounters factory
-(id <IAtomicCounters>)of:(NSString *)name;

@end
