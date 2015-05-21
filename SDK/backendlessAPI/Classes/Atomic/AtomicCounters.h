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

// sync methods with fault return (as exception)
-(NSNumber *)get:(NSString *)counterName;
-(NSNumber *)getAndIncrement:(NSString *)counterName;
-(NSNumber *)incrementAndGet:(NSString *)counterName;
-(NSNumber *)getAndDecrement:(NSString *)counterName;
-(NSNumber *)decrementAndGet:(NSString *)counterName;
-(NSNumber *)addAndGet:(NSString *)counterName value:(long)value;
-(NSNumber *)getAndAdd:(NSString *)counterName value:(long)value;
-(NSNumber *)compareAndSet:(NSString *)counterName expected:(long)expected updated:(long)updated;
-(id)reset:(NSString *)counterName;

// sync methods with fault option
-(NSNumber *)get:(NSString *)counterName fault:(Fault **)fault;
-(NSNumber *)getAndIncrement:(NSString *)counterName fault:(Fault **)fault;
-(NSNumber *)incrementAndGet:(NSString *)counterName fault:(Fault **)fault;
-(NSNumber *)getAndDecrement:(NSString *)counterName fault:(Fault **)fault;
-(NSNumber *)decrementAndGet:(NSString *)counterName fault:(Fault **)fault;
-(NSNumber *)addAndGet:(NSString *)counterName value:(long)value fault:(Fault **)fault;
-(NSNumber *)getAndAdd:(NSString *)counterName value:(long)value fault:(Fault **)fault;
-(NSNumber *)compareAndSet:(NSString *)counterName expected:(long)expected updated:(long)updated fault:(Fault **)fault;
-(BOOL)reset:(NSString *)counterName fault:(Fault **)fault;

// async methods with responder
-(void)get:(NSString *)counterName responder:(id<IResponder>)responder;
-(void)getAndIncrement:(NSString *)counterName responder:(id<IResponder>)responder;
-(void)incrementAndGet:(NSString *)counterName responder:(id<IResponder>)responder;
-(void)getAndDecrement:(NSString *)counterName responder:(id<IResponder>)responder;
-(void)decrementAndGet:(NSString *)counterName responder:(id<IResponder>)responder;
-(void)addAndGet:(NSString *)counterName value:(long)value responder:(id<IResponder>)responder;
-(void)getAndAdd:(NSString *)counterName value:(long)value responder:(id<IResponder>)responder;
-(void)compareAndSet:(NSString *)counterName expected:(long)expected updated:(long)updated responder:(id<IResponder>)responder;
-(void)reset:(NSString *)counterName responder:(id<IResponder>)responder;

// async methods with block-based callbacks
-(void)get:(NSString *)counterName response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)getAndIncrement:(NSString *)counterName response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)incrementAndGet:(NSString *)counterName response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)getAndDecrement:(NSString *)counterName response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)decrementAndGet:(NSString *)counterName response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)addAndGet:(NSString *)counterName value:(long)value response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)getAndAdd:(NSString *)counterName value:(long)value response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)compareAndSet:(NSString *)counterName expected:(long)expected updated:(long)updated response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)reset:(NSString *)counterName response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock;

// IAtomicCounters factory
-(id <IAtomic>)of:(NSString *)counterName;

@end
