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

#define FAULT_NO_RESULT [Fault fault:@"Result is NULL" detail:@"Result is NULL" faultCode:@"16900"]
#define FAULT_NO_ENTITY [Fault fault:@"Entity is NULL" detail:@"Entity is NULL" faultCode:@"16901"]
#define FAULT_NO_KEY [Fault fault:@"Key is NULL" detail:@"Key is NULL" faultCode:@"16902"]

// SERVICE NAME
static NSString *SERVER_CACHE_SERVICE_PATH = @"com.backendless.services.redis.CacheService";
// METHOD NAMES
static NSString *METHOD_PUT_BYTES = @"putBytes";
static NSString *METHOD_CONTAINS_KEY = @"containsKey";
static NSString *METHOD_GET_BYTES = @"getBytes";
static NSString *METHOD_EXPIRE_IN = @"expireIn";
static NSString *METHOD_EXPIRE_AT = @"expireAt";
static NSString *METHOD_DELETE = @"delete";

@interface CacheService ()
-(id)onGet:(id)response;
@end

@implementation CacheService

-(id)init {
	if ( (self=[super init]) ) {
        
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC CacheService"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

// sync methods with fault option

#if OLD_ASYNC_WITH_FAULT

-(BOOL)put:(NSString *)key object:(id)entity fault:(Fault **)fault {
    return [self put:key object:entity timeToLive:0 fault:fault];
}

-(BOOL)put:(NSString *)key object:(id)entity timeToLive:(int)seconds fault:(Fault **)fault {
    
    Fault *noValid = key ? (entity ? nil : [backendless throwFault:FAULT_NO_ENTITY]) : [backendless throwFault:FAULT_NO_KEY];
    if (noValid) {
        if (fault) {
            (*fault) = noValid;
        }
        return NO;
    }
    
    BinaryStream *stream = [AMFSerializer serializeToBytes:entity];
    NSData *data = [NSData dataWithBytes:stream.buffer length:stream.size];
    NSNumber *time = [NSNumber numberWithInt:((seconds > 0) && (seconds <= 7200))?seconds:0];
    NSArray *args = @[backendless.appID, backendless.versionNum, key, data, time];
    id result = [invoker invokeSync:SERVER_CACHE_SERVICE_PATH method:METHOD_PUT_BYTES args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if (fault) {
            (*fault) = result;
        }
        return NO;
    }
    
    return YES;
}

-(id)get:(NSString *)key fault:(Fault **)fault {
    
    if (!key) {
        if (fault) {
            (*fault) = [backendless throwFault:FAULT_NO_KEY];
        }
        return nil;
    }
    
    NSArray *args = @[backendless.appID, backendless.versionNum, key];
    id result = [invoker invokeSync:SERVER_CACHE_SERVICE_PATH method:METHOD_GET_BYTES args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if (fault) {
            (*fault) = result;
        }
        return nil;
    }
    if (![result isKindOfClass:[NSData class]]) {
        if (fault) {
            (*fault) = [backendless throwFault:FAULT_NO_RESULT];
        }
        return nil;
    }
    
    return [self onGet:result];
}

-(NSNumber *)contains:(NSString *)key fault:(Fault **)fault {
    
    if (!key) {
        if (fault) {
            (*fault) = [backendless throwFault:FAULT_NO_KEY];
        }
        return nil;
    }
    
    NSArray *args = @[backendless.appID, backendless.versionNum, key];
    id result = [invoker invokeSync:SERVER_CACHE_SERVICE_PATH method:METHOD_CONTAINS_KEY args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if (fault) {
            (*fault) = result;
        }
        return nil;
    }
    if (![result isKindOfClass:[NSNumber class]]) {
        NSLog(@"CacheService -> contains: %@", result);
        if (fault) {
            (*fault) = [backendless throwFault:FAULT_NO_RESULT];
        }
        return nil;
    }
    
    return result;
}

-(BOOL)expireIn:(NSString *)key timeToLive:(int)seconds fault:(Fault **)fault {
    
    if (!key) {
        if (fault) {
            (*fault) = [backendless throwFault:FAULT_NO_KEY];
        }
        return NO;
    }
    
    NSNumber *time = [NSNumber numberWithInt:((seconds > 0) && (seconds <= 7200))?seconds:0];
    NSArray *args = @[backendless.appID, backendless.versionNum, key, time];
    id result = [invoker invokeSync:SERVER_CACHE_SERVICE_PATH method:METHOD_EXPIRE_IN args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if (fault) {
            (*fault) = result;
        }
        return NO;
    }
    
    return YES;
}

-(BOOL)expireAt:(NSString *)key timestamp:(NSDate *)timestamp fault:(Fault **)fault {
    
    if (!key) {
        if (fault) {
            (*fault) = [backendless throwFault:FAULT_NO_KEY];
        }
        return NO;
    }
    
    NSArray *args = @[backendless.appID, backendless.versionNum, key, timestamp];
    id result = [invoker invokeSync:SERVER_CACHE_SERVICE_PATH method:METHOD_EXPIRE_AT args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if (fault) {
            (*fault) = result;
        }
        return NO;
    }
    
    return YES;
}

-(BOOL)remove:(NSString *)key fault:(Fault **)fault {
    
    if (!key) {
        if (fault) {
            (*fault) = [backendless throwFault:FAULT_NO_KEY];
        }
        return NO;
    }
    
    NSArray *args = @[backendless.appID, backendless.versionNum, key];
    id result = [invoker invokeSync:SERVER_CACHE_SERVICE_PATH method:METHOD_DELETE args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if (fault) {
            (*fault) = result;
        }
        return NO;
    }
    
    return YES;
}
#else

#if 0 // wrapper for work without exception

id result = nil;
@try {
}
@catch (Fault *fault) {
    result = fault;
}
@finally {
    if ([result isKindOfClass:Fault.class]) {
        if (fault)(*fault) = result;
        return nil;
    }
    return result;
}

#endif

-(BOOL)put:(NSString *)key object:(id)entity fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self put:key object:entity];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

-(BOOL)put:(NSString *)key object:(id)entity timeToLive:(int)seconds fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self put:key object:entity timeToLive:seconds];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

-(id)get:(NSString *)key fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self get:key];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSNumber *)contains:(NSString *)key fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self contains:key];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BOOL)expireIn:(NSString *)key timeToLive:(int)seconds fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self expireIn:key timeToLive:seconds];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

-(BOOL)expireAt:(NSString *)key timestamp:(NSDate *)timestamp fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self expireAt:key timestamp:timestamp];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

-(BOOL)remove:(NSString *)key fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self remove:key];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

#endif

// sync methods with fault return (as exception)

-(id)put:(NSString *)key object:(id)entity {
    return [self put:key object:entity timeToLive:0];
}

-(id)put:(NSString *)key object:(id)entity timeToLive:(int)seconds {
    
    if (!key)
        return [backendless throwFault:FAULT_NO_KEY];
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    BinaryStream *stream = [AMFSerializer serializeToBytes:entity];
    NSData *data = [NSData dataWithBytes:stream.buffer length:stream.size];
    NSNumber *time = [NSNumber numberWithInt:((seconds > 0) && (seconds <= 7200))?seconds:0];
    NSArray *args = @[backendless.appID, backendless.versionNum, key, data, time];
    return [invoker invokeSync:SERVER_CACHE_SERVICE_PATH method:METHOD_PUT_BYTES args:args];
}

-(id)get:(NSString *)key {
    
    if (!key)
        return [backendless throwFault:FAULT_NO_KEY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, key];
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
    
    NSArray *args = @[backendless.appID, backendless.versionNum, key];
    return [invoker invokeSync:SERVER_CACHE_SERVICE_PATH method:METHOD_CONTAINS_KEY args:args];
}

-(id)expireIn:(NSString *)key timeToLive:(int)seconds {
    
    if (!key)
        return [backendless throwFault:FAULT_NO_KEY];
    
    NSNumber *time = [NSNumber numberWithInt:((seconds > 0) && (seconds <= 7200))?seconds:0];
    NSArray *args = @[backendless.appID, backendless.versionNum, key, time];
    return [invoker invokeSync:SERVER_CACHE_SERVICE_PATH method:METHOD_EXPIRE_IN args:args];
}

-(id)expireAt:(NSString *)key timestamp:(NSDate *)timestamp {
    
    if (!key)
        return [backendless throwFault:FAULT_NO_KEY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, key, timestamp];
    return [invoker invokeSync:SERVER_CACHE_SERVICE_PATH method:METHOD_EXPIRE_AT args:args];
}

-(id)remove:(NSString *)key {
    
    if (!key)
        return [backendless throwFault:FAULT_NO_KEY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, key];
    return [invoker invokeSync:SERVER_CACHE_SERVICE_PATH method:METHOD_DELETE args:args];
}

// async methods with responder

-(void)put:(NSString *)key object:(id)entity responder:(id<IResponder>)responder {
    [self put:key object:entity timeToLive:0 responder:responder];
}

-(void)put:(NSString *)key object:(id)entity timeToLive:(int)seconds responder:(id<IResponder>)responder {
    
    if (!key)
        return [responder errorHandler:FAULT_NO_KEY];
    if (!entity)
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    BinaryStream *stream = [AMFSerializer serializeToBytes:entity];
    NSData *data = [NSData dataWithBytes:stream.buffer length:stream.size];
    NSNumber *time = [NSNumber numberWithInt:((seconds > 0) && (seconds <= 7200))?seconds:0];
    NSArray *args = @[backendless.appID, backendless.versionNum, key, data, time];
    [invoker invokeAsync:SERVER_CACHE_SERVICE_PATH method:METHOD_PUT_BYTES args:args responder:responder];
}

-(void)get:(NSString *)key responder:(id<IResponder>)responder {
    
    if (!key)
        return [responder errorHandler:FAULT_NO_KEY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, key];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onGet:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_CACHE_SERVICE_PATH method:METHOD_GET_BYTES args:args responder:_responder];
}

-(void)contains:(NSString *)key responder:(id<IResponder>)responder {
    
    if (!key)
        return [responder errorHandler:FAULT_NO_KEY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, key];
    [invoker invokeAsync:SERVER_CACHE_SERVICE_PATH method:METHOD_CONTAINS_KEY args:args responder:responder];
}

-(void)expireIn:(NSString *)key timeToLive:(int)seconds responder:(id<IResponder>)responder {
    
    if (!key)
        return [responder errorHandler:FAULT_NO_KEY];
    
    NSNumber *time = [NSNumber numberWithInt:((seconds > 0) && (seconds <= 7200))?seconds:0];
    NSArray *args = @[backendless.appID, backendless.versionNum, key, time];
    [invoker invokeAsync:SERVER_CACHE_SERVICE_PATH method:METHOD_EXPIRE_IN args:args responder:responder];
}

-(void)expireAt:(NSString *)key timestamp:(NSDate *)timestamp responder:(id<IResponder>)responder {
    
    if (!key)
        return [responder errorHandler:FAULT_NO_KEY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, key, timestamp];
    [invoker invokeAsync:SERVER_CACHE_SERVICE_PATH method:METHOD_EXPIRE_AT args:args responder:responder];
}

-(void)remove:(NSString *)key responder:(id<IResponder>)responder {
    
    if (!key)
        return [responder errorHandler:FAULT_NO_KEY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, key];
    [invoker invokeAsync:SERVER_CACHE_SERVICE_PATH method:METHOD_DELETE args:args responder:responder];
}

// async methods with block-based callbacks

-(void)put:(NSString *)key object:(id)entity response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self put:key object:entity timeToLive:0 responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)put:(NSString *)key object:(id)entity timeToLive:(int)seconds response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self put:key object:entity timeToLive:seconds responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)get:(NSString *)key response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self get:key responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)contains:(NSString *)key response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self contains:key responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)expireIn:(NSString *)key timeToLive:(int)seconds response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self expireIn:key timeToLive:seconds responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)expireAt:(NSString *)key timestamp:(NSDate *)timestamp response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self expireAt:key timestamp:timestamp responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)remove:(NSString *)key response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self remove:key responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

// ICacheService factory

-(id <ICacheService>)with:(NSString *)key {
    return [CacheFactory create:key];
}

-(id <ICacheService>)with:(NSString *)key type:(Class)entityClass {
    return [CacheFactory create:key type:entityClass];
}

#pragma mark -
#pragma mark Private Methods

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
