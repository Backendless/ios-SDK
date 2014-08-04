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
#if !NEW_API_ON
#include "AtomicCounters.h"
#endif

@interface AtomicCountersFactory () {
    NSString *_name;
}
@end

@implementation AtomicCountersFactory

-(id)init {
	if ( (self=[super init]) ) {
        _name = @"DEFAULT_NAME";
	}
	
	return self;
}

-(id)init:(NSString *)name {
	if ( (self=[super init]) ) {
        _name = name?[name retain]:@"DEFAULT_NAME";
	}
	
	return self;
}

+(id <IAtomicCounters>)create:(NSString *)name {
    return [[AtomicCountersFactory alloc] init:name];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC AtomicCountersFactory"];
    
    [_name release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ICacheService Methods

// sync methods with fault option

-(NSNumber *)get:(Fault **)fault {
    return [backendless.counters get:_name fault:fault];
}

-(NSNumber *)getAndIncrement:(Fault **)fault {
    return [backendless.counters getAndIncrement:_name fault:fault];
}

-(NSNumber *)incrementAndGet:(Fault **)fault {
    return [backendless.counters incrementAndGet:_name fault:fault];
}

-(NSNumber *)getAndDecrement:(Fault **)fault {
    return [backendless.counters getAndDecrement:_name fault:fault];
}

-(NSNumber *)decrementAndGet:(Fault **)fault {
    return [backendless.counters decrementAndGet:_name fault:fault];
}

-(NSNumber *)addAndGet:(long)value fault:(Fault **)fault {
    return [backendless.counters addAndGet:_name value:value fault:fault];
}

-(NSNumber *)getAndAdd:(long)value fault:(Fault **)fault {
    return [backendless.counters getAndAdd:_name value:value fault:fault];
}

-(NSNumber *)compareAndSet:(long)expected updated:(long)updated fault:(Fault **)fault {
    return [backendless.counters compareAndSet:_name expected:expected updated:updated fault:fault];
}

// async methods with responder

-(void)getToResponder:(id<IResponder>)responder {
    [backendless.counters get:_name responder:responder];
}

-(void)getAndIncrementToResponder:(id<IResponder>)responder {
    [backendless.counters getAndIncrement:_name responder:responder];
}

-(void)incrementAndGetToResponder:(id<IResponder>)responder {
    [backendless.counters incrementAndGet:_name responder:responder];
}

-(void)getAndDecrementToResponder:(id<IResponder>)responder {
    [backendless.counters getAndDecrement:_name responder:responder];
}

-(void)decrementAndGetToResponder:(id<IResponder>)responder {
    [backendless.counters decrementAndGet:_name responder:responder];
}

-(void)addAndGet:(long)value responder:(id<IResponder>)responder {
    [backendless.counters addAndGet:_name value:value responder:responder];
}

-(void)getAndAdd:(long)value responder:(id<IResponder>)responder {
    [backendless.counters getAndAdd:_name value:value responder:responder];
}

-(void)compareAndSet:(long)expected updated:(long)updated responder:(id<IResponder>)responder {
    [backendless.counters compareAndSet:_name expected:expected updated:updated responder:responder];
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

@end
