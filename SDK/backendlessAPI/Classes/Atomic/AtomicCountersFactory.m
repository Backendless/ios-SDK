//
//  AtomicOperationFactory.m
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

#import "AtomicCountersFactory.h"
#include "Backendless.h"

@interface AtomicCountersFactory () {
    NSString *_name;
}
@end

@implementation AtomicCountersFactory

-(id)init {
	if (self=[super init]) {
        _name = @"DEFAULT_NAME";
	}
	return self;
}

-(id)init:(NSString *)counterName {
	if (self=[super init]) {
        _name = counterName?[counterName retain]:@"DEFAULT_NAME";
	}
	return self;
}

+(id <IAtomic>)create:(NSString *)counterName {
    return [[AtomicCountersFactory alloc] init:counterName];
}

-(void)dealloc {
	[DebLog logN:@"DEALLOC AtomicCountersFactory"];
    [_name release];	
	[super dealloc];
}

#pragma mark -
#pragma mark ICacheService Methods

// sync methods with fault return (as exception)

-(NSNumber *)get {
    return [backendless.counters get:_name ];
}

-(NSNumber *)getAndIncrement {
    return [backendless.counters getAndIncrement:_name];
}

-(NSNumber *)incrementAndGet {
    return [backendless.counters incrementAndGet:_name];
}

-(NSNumber *)getAndDecrement {
    return [backendless.counters getAndDecrement:_name];
}

-(NSNumber *)decrementAndGet {
    return [backendless.counters decrementAndGet:_name];
}

-(NSNumber *)addAndGet:(long)value {
    return [backendless.counters addAndGet:_name value:value];
}

-(NSNumber *)getAndAdd:(long)value {
    return [backendless.counters getAndAdd:_name value:value];
}

-(NSNumber *)compareAndSet:(long)expected updated:(long)updated  {
    return [backendless.counters compareAndSet:_name expected:expected updated:updated];
}

-(id)reset {
    return [backendless.counters reset:_name];
}

// async methods with block-based callback

-(void)get:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.counters get:_name response:responseBlock error:errorBlock];
}

-(void)getAndIncrement:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.counters getAndIncrement:_name response:responseBlock error:errorBlock];
}

-(void)incrementAndGet:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.counters incrementAndGet:_name response:responseBlock error:errorBlock];
}

-(void)getAndDecrement:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.counters getAndDecrement:_name response:responseBlock error:errorBlock];
}

-(void)decrementAndGet:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.counters decrementAndGet:_name response:responseBlock error:errorBlock];
}

-(void)addAndGet:(long)value response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.counters addAndGet:_name value:value response:responseBlock error:errorBlock];
}

-(void)getAndAdd:(long)value response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.counters getAndAdd:_name value:value response:responseBlock error:errorBlock];
}

-(void)compareAndSet:(long)expected updated:(long)updated response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.counters compareAndSet:_name expected:expected updated:updated response:responseBlock error:errorBlock];
}

-(void)reset:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.counters reset:_name response:responseBlock error:errorBlock];
}

@end
