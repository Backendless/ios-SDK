//
//  CacheService.m
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

#import "CacheService.h"
#import "Backendless.h"
#import "Invoker.h"
#import "CacheFactory.h"
#import "VoidResponseWrapper.h"

#define FAULT_NO_RESULT [Fault fault:@"Result is NULL" detail:@"Result is NULL" faultCode:@"16900"]
#define FAULT_NO_ENTITY [Fault fault:@"Entity is NULL" detail:@"Entity is NULL" faultCode:@"16901"]
#define FAULT_NO_KEY [Fault fault:@"Key is NULL" detail:@"Key is NULL" faultCode:@"16902"]

static NSString *SERVER_CACHE_SERVICE_PATH = @"com.backendless.services.redis.CacheService";
static NSString *METHOD_PUT_BYTES = @"putBytes";
static NSString *METHOD_CONTAINS_KEY = @"containsKey";
static NSString *METHOD_GET_BYTES = @"getBytes";
static NSString *METHOD_EXPIRE_IN = @"expireIn";
static NSString *METHOD_EXPIRE_AT = @"expireAt";
static NSString *METHOD_DELETE = @"delete";

@implementation CacheService

-(void)dealloc {
    [DebLog logN:@"DEALLOC CacheService"];
    [super dealloc];
}

// sync methods with fault return (as exception)

-(void)put:(NSString *)key object:(id)entity {
    [self put:key object:entity timeToLive:0];
}

-(void)put:(NSString *)key object:(id)entity timeToLive:(int)seconds {
    if (!key)
        [backendless throwFault:FAULT_NO_KEY];
    if (!entity)
        [backendless throwFault:FAULT_NO_ENTITY];
    BinaryStream *stream = [AMFSerializer serializeToBytes:entity];
    NSData *data = [NSData dataWithBytes:stream.buffer length:stream.size];
    NSNumber *time = [NSNumber numberWithInt:((seconds > 0) && (seconds <= 7200))?seconds:0];
    NSArray *args = @[key, data, time];
    [invoker invokeSync:SERVER_CACHE_SERVICE_PATH method:METHOD_PUT_BYTES args:args];
}

-(id)get:(NSString *)key {
    if (!key)
        return [backendless throwFault:FAULT_NO_KEY];
    NSArray *args = @[key];
    id result = [invoker invokeSync:SERVER_CACHE_SERVICE_PATH method:METHOD_GET_BYTES args:args];
    if ([result isKindOfClass:Fault.class])
        return result;
    if (![result isKindOfClass:NSData.class])
        return [backendless throwFault:FAULT_NO_RESULT];
    return [self onGet:result];
}

-(NSNumber *)contains:(NSString *)key {
    if (!key)
        return [backendless throwFault:FAULT_NO_KEY];
    NSArray *args = @[key];
    return [invoker invokeSync:SERVER_CACHE_SERVICE_PATH method:METHOD_CONTAINS_KEY args:args];
}

-(void)expireIn:(NSString *)key timeToLive:(int)seconds {
    if (!key)
        [backendless throwFault:FAULT_NO_KEY];
    NSNumber *time = [NSNumber numberWithInt:((seconds > 0) && (seconds <= 7200))?seconds:0];
    NSArray *args = @[key, time];
    id result = [invoker invokeSync:SERVER_CACHE_SERVICE_PATH method:METHOD_EXPIRE_IN args:args];
    if ([result isKindOfClass:[Fault class]]) {
        [backendless throwFault:result];
    }
}

-(void)expireAt:(NSString *)key timestamp:(NSDate *)timestamp {
    if (!key)
        [backendless throwFault:FAULT_NO_KEY];
    NSArray *args = @[key, timestamp];
    id result = [invoker invokeSync:SERVER_CACHE_SERVICE_PATH method:METHOD_EXPIRE_AT args:args];
    if ([result isKindOfClass:[Fault class]]) {
        [backendless throwFault:result];
    }
}

-(void)remove:(NSString *)key {
    if (!key)
        [backendless throwFault:FAULT_NO_KEY];
    NSArray *args = @[key];
    id result = [invoker invokeSync:SERVER_CACHE_SERVICE_PATH method:METHOD_DELETE args:args];
    if ([result isKindOfClass:[Fault class]]) {
        [backendless throwFault:result];
    }
}

// async methods with block-based callbacks

-(void)put:(NSString *)key object:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self put:key object:entity timeToLive:0 response:responseBlock error:errorBlock];
}

-(void)put:(NSString *)key object:(id)entity timeToLive:(int)seconds response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!key)
        return [responder errorHandler:FAULT_NO_KEY];
    if (!entity)
        return [responder errorHandler:FAULT_NO_ENTITY];
    BinaryStream *stream = [AMFSerializer serializeToBytes:entity];
    NSData *data = [NSData dataWithBytes:stream.buffer length:stream.size];
    NSNumber *time = [NSNumber numberWithInt:((seconds > 0) && (seconds <= 7200))?seconds:0];
    NSArray *args = @[key, data, time];
    [invoker invokeAsync:SERVER_CACHE_SERVICE_PATH method:METHOD_PUT_BYTES args:args responder:responder];
}

-(void)get:(NSString *)key response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!key)
        return [responder errorHandler:FAULT_NO_KEY];
    NSArray *args = @[key];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onGet:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_CACHE_SERVICE_PATH method:METHOD_GET_BYTES args:args responder:_responder];
}

-(void)contains:(NSString *)key response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!key)
        return [responder errorHandler:FAULT_NO_KEY];
    NSArray *args = @[key];
    [invoker invokeAsync:SERVER_CACHE_SERVICE_PATH method:METHOD_CONTAINS_KEY args:args responder:responder];
}

-(void)expireIn:(NSString *)key timeToLive:(int)seconds response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:[voidResponseWrapper wrapResponseBlock:responseBlock] error:errorBlock];
    if (!key)
        return [responder errorHandler:FAULT_NO_KEY];
    NSNumber *time = [NSNumber numberWithInt:((seconds > 0) && (seconds <= 7200))?seconds:0];
    NSArray *args = @[key, time];
    [invoker invokeAsync:SERVER_CACHE_SERVICE_PATH method:METHOD_EXPIRE_IN args:args responder:responder];
}

-(void)expireAt:(NSString *)key timestamp:(NSDate *)timestamp response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:[voidResponseWrapper wrapResponseBlock:responseBlock] error:errorBlock];
    if (!key)
        return [responder errorHandler:FAULT_NO_KEY];
    NSArray *args = @[key, timestamp];
    [invoker invokeAsync:SERVER_CACHE_SERVICE_PATH method:METHOD_EXPIRE_AT args:args responder:responder];
}

-(void)remove:(NSString *)key response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:[voidResponseWrapper wrapResponseBlock:responseBlock] error:errorBlock];
    if (!key)
        return [responder errorHandler:FAULT_NO_KEY];
    NSArray *args = @[key];
    [invoker invokeAsync:SERVER_CACHE_SERVICE_PATH method:METHOD_DELETE args:args responder:responder];
}

// ICacheService factory

-(id <ICacheService>)with:(NSString *)key {
    return [CacheFactory create:key];
}

-(id <ICacheService>)with:(NSString *)key type:(Class)entityClass {
    return [CacheFactory create:key type:entityClass];
}

// callbacks

-(id)onGet:(id)response {
    if (![response isKindOfClass:[NSData class]]) {
        [DebLog logY:@"CacheService -> onGet: (ERROR) response = %@\n backendless.headers = %@", response, backendless.headers];
        return nil;
    }
    NSData *data = (NSData *)response;
    BinaryStream *stream = [BinaryStream streamWithStream:(char *)[data bytes] andSize:data.length];
    id obj = [AMFSerializer deserializeFromBytes:stream];
    [DebLog log:@"CacheService -> onGet: obj = %@\n backendless.headers = %@", obj, backendless.headers];
    return  [(NSObject *)obj isKindOfClass:[NSNull class]]?nil:obj;
}

@end
