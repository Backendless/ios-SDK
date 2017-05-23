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

@class Fault;

@interface AtomicCounters : NSObject

// sync methods with fault return (as exception)
-(NSNumber *)get:(NSString *)counterName;
-(NSNumber *)getAndIncrement:(NSString *)counterName;
-(NSNumber *)incrementAndGet:(NSString *)counterName;
-(NSNumber *)getAndDecrement:(NSString *)counterName;
-(NSNumber *)decrementAndGet:(NSString *)counterName;
-(NSNumber *)addAndGet:(NSString *)counterName value:(NSNumber *)value;
-(NSNumber *)getAndAdd:(NSString *)counterName value:(NSNumber *)value;
-(NSNumber *)compareAndSet:(NSString *)counterName expected:(NSNumber *)expected updated:(NSNumber *)updated;
-(id)reset:(NSString *)counterName;

// async methods with block-based callbacks
-(void)get:(NSString *)counterName response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)getAndIncrement:(NSString *)counterName response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)incrementAndGet:(NSString *)counterName response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)getAndDecrement:(NSString *)counterName response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)decrementAndGet:(NSString *)counterName response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)addAndGet:(NSString *)counterName value:(NSNumber *)value response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)getAndAdd:(NSString *)counterName value:(NSNumber *)value response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)compareAndSet:(NSString *)counterName expected:(NSNumber *)expected updated:(NSNumber *)updated response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)reset:(NSString *)counterName response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock;

// IAtomicCounters factory
-(id <IAtomic>)of:(NSString *)counterName;

@end
