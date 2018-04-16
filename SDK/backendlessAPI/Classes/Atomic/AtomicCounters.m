//
//  AtomicOperation.m
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

#import "AtomicCounters.h"
#import "Backendless.h"
#import "Invoker.h"
#import "AtomicCountersFactory.h"
#import "VoidResponseWrapper.h"

#define FAULT_NO_NAME [Fault fault:@"Name is NULL" detail:@"Name is NULL" faultCode:@"8900"]

static NSString *SERVER_ATOMIC_OPERATION_SERVICE_PATH = @"com.backendless.services.redis.AtomicOperationService";
static NSString *METHOD_GET = @"get";
static NSString *METHOD_GET_AND_INCREMENT = @"getAndIncrement";
static NSString *METHOD_INCREMENT_AND_GET = @"incrementAndGet";
static NSString *METHOD_GET_AND_DECREMENT = @"getAndDecrement";
static NSString *METHOD_DECREMENT_AND_GET = @"decrementAndGet";
static NSString *METHOD_ADD_AND_GET = @"addAndGet";
static NSString *METHOD_GET_AND_ADD = @"getAndAdd";
static NSString *METHOD_COMPARE_AND_SET = @"compareAndSet";
static NSString *METHOD_RESET = @"reset";

@implementation AtomicCounters

-(void)dealloc {
    [DebLog logN:@"DEALLOC AtomicCounters"];
    [super dealloc];
}

// sync methods with fault return (as exception)

-(NSNumber *)get:(NSString *)counterName {
    if (!counterName)
        return [backendless throwFault:FAULT_NO_NAME];
    NSArray *args = @[counterName];
    return [invoker invokeSync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_GET args:args];
}

-(NSNumber *)getAndIncrement:(NSString *)counterName {
    if (!counterName)
        return [backendless throwFault:FAULT_NO_NAME];
    NSArray *args = @[counterName];
    return [invoker invokeSync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_GET_AND_INCREMENT args:args];
}

-(NSNumber *)incrementAndGet:(NSString *)counterName {
    if (!counterName)
        return [backendless throwFault:FAULT_NO_NAME];
    NSArray *args = @[counterName];
    return [invoker invokeSync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_INCREMENT_AND_GET args:args];
}

-(NSNumber *)getAndDecrement:(NSString *)counterName {
    if (!counterName)
        return [backendless throwFault:FAULT_NO_NAME];
    NSArray *args = @[counterName];
    return [invoker invokeSync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_GET_AND_DECREMENT args:args];
}

-(NSNumber *)decrementAndGet:(NSString *)counterName {
    if (!counterName)
        return [backendless throwFault:FAULT_NO_NAME];
    NSArray *args = @[counterName];
    return [invoker invokeSync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_DECREMENT_AND_GET args:args];
}

-(NSNumber *)addAndGet:(NSString *)counterName value:(NSNumber *)value {
    if (!counterName)
        return [backendless throwFault:FAULT_NO_NAME];
    NSArray *args = @[counterName, value];
    return [invoker invokeSync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_ADD_AND_GET args:args];
}

-(NSNumber *)getAndAdd:(NSString *)counterName value:(NSNumber *)value {
    if (!counterName)
        return [backendless throwFault:FAULT_NO_NAME];
    NSArray *args = @[counterName, value];
    return [invoker invokeSync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_GET_AND_ADD args:args];
}

-(NSNumber *)compareAndSet:(NSString *)counterName expected:(NSNumber *)expected updated:(NSNumber *)updated {
    if (!counterName)
        return [backendless throwFault:FAULT_NO_NAME];
    NSArray *args = @[counterName, expected, updated];
    return [invoker invokeSync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_COMPARE_AND_SET args:args];
}

-(void)reset:(NSString *)counterName  {
    if (!counterName)
        [backendless throwFault:FAULT_NO_NAME];
    NSArray *args = @[counterName];
    id result = [invoker invokeSync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_RESET args:args];
    if ([result isKindOfClass:[Fault class]]) {
        [backendless throwFault:result];
    }
}

// async methods with block-based callbacks

-(void)get:(NSString *)counterName response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!counterName)
        return [responder errorHandler:FAULT_NO_NAME];
    NSArray *args = @[counterName];
    [invoker invokeAsync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_GET args:args responder:responder];
}

-(void)getAndIncrement:(NSString *)counterName response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!counterName)
        return [responder errorHandler:FAULT_NO_NAME];
    NSArray *args = @[counterName];
    [invoker invokeAsync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_GET_AND_INCREMENT args:args responder:responder];
}

-(void)incrementAndGet:(NSString *)counterName response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!counterName)
        return [responder errorHandler:FAULT_NO_NAME];
    NSArray *args = @[counterName];
    [invoker invokeAsync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_INCREMENT_AND_GET args:args responder:responder];
}

-(void)getAndDecrement:(NSString *)counterName response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!counterName)
        return [responder errorHandler:FAULT_NO_NAME];
    NSArray *args = @[counterName];
    [invoker invokeAsync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_GET_AND_DECREMENT args:args responder:responder];
}

-(void)decrementAndGet:(NSString *)counterName response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!counterName)
        return [responder errorHandler:FAULT_NO_NAME];
    NSArray *args = @[counterName];
    [invoker invokeAsync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_DECREMENT_AND_GET args:args responder:responder];
}

-(void)addAndGet:(NSString *)counterName value:(NSNumber *)value response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!counterName)
        return [responder errorHandler:FAULT_NO_NAME];
    NSArray *args = @[counterName, value];
    [invoker invokeAsync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_ADD_AND_GET args:args responder:responder];
}

-(void)getAndAdd:(NSString *)counterName value:(NSNumber *)value response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!counterName)
        return [responder errorHandler:FAULT_NO_NAME];
    NSArray *args = @[counterName, value];
    [invoker invokeAsync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_GET_AND_ADD args:args responder:responder];
}

-(void)compareAndSet:(NSString *)counterName expected:(NSNumber *)expected updated:(NSNumber *)updated response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!counterName)
        return [responder errorHandler:FAULT_NO_NAME];
    NSArray *args = @[counterName, expected, updated];
    [invoker invokeAsync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_COMPARE_AND_SET args:args responder:responder];
}

-(void)reset:(NSString *)counterName response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:[voidResponseWrapper wrapResponseBlock:responseBlock] error:errorBlock];
    if (!counterName)
        return [responder errorHandler:FAULT_NO_NAME];
    NSArray *args = @[counterName];
    [invoker invokeAsync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_RESET args:args responder:responder];
}

// IAtomicCounters factory
-(id <IAtomic>)of:(NSString *)counterName {
    return [AtomicCountersFactory create:counterName];
}

@end
