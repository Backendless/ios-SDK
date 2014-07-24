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

#import "CacheService.h"
#import "Backendless.h"
#import "Invoker.h"

#define FAULT_NO_ENTITY [Fault fault:@"Entity is not valid" faultCode:@"0000"]
#define FAULT_NO_KEY [Fault fault:@"Key is not valid" faultCode:@"0000"]

// SERVICE NAME
static NSString *SERVER_CACHE_SERVICE_PATH = @"com.backendless.services.redis.CacheService";
// METHOD NAMES
static NSString *METHOD_PUT_BYTES = @"putBytes";
static NSString *METHOD_CONTAINS_KEY = @"continesKey";
static NSString *METHOD_GET_BYTES = @"getBytes";
static NSString *METHOD_EXTEND_LIFE = @"extendLife";
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

-(BOOL)put:(NSString *)key object:(id)entity fault:(Fault **)fault {
    return [self put:key object:entity timeToKeep:0 fault:fault];
}

-(BOOL)put:(NSString *)key object:(id)entity timeToKeep:(int)expire fault:(Fault **)fault {
    
    Fault *noValid = key ? (entity ? nil : [backendless throwFault:FAULT_NO_ENTITY]) : [backendless throwFault:FAULT_NO_KEY];
    if (noValid) {
        if (fault) {
            (*fault) = noValid;
        }
        return NO;
    }
    
    BinaryStream *stream = [AMFSerializer serializeToBytes:entity];
    NSData *data = [NSData dataWithBytes:stream.buffer length:stream.size];
    NSNumber *time = [NSNumber numberWithInt:(expire > 0)?expire:0];
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
            (*fault) = [backendless throwFault:FAULT_NO_ENTITY];
        }
        return nil;
    }
    
    return [self onGet:result];
}

// async methods with responder

-(void)put:(NSString *)key object:(id)entity responder:(id<IResponder>)responder {
    [self put:key object:entity timeToKeep:0 responder:responder];
}

-(void)put:(NSString *)key object:(id)entity timeToKeep:(int)expire responder:(id<IResponder>)responder {
    
    if (!key)
        return [responder errorHandler:FAULT_NO_KEY];
    if (!entity)
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    BinaryStream *stream = [AMFSerializer serializeToBytes:entity];
    NSData *data = [NSData dataWithBytes:stream.buffer length:stream.size];
    NSNumber *time = [NSNumber numberWithInt:(expire > 0)?expire:0];
    NSArray *args = @[backendless.appID, backendless.versionNum, key, data, time];
    [invoker invokeAsync:SERVER_CACHE_SERVICE_PATH method:METHOD_PUT_BYTES args:args responder:responder];
}

-(void)get:(NSString *)key responder:(id<IResponder>)responder {
    
    if (!key)
        return [responder errorHandler:FAULT_NO_KEY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, key];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onGet:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_CACHE_SERVICE_PATH method:METHOD_PUT_BYTES args:args responder:_responder];
}

// async methods with block-based callback

-(void)put:(NSString *)key object:(id)entity response:(void (^)(NSDictionary *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self put:key object:entity timeToKeep:0 responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)put:(NSString *)key object:(id)entity timeToKeep:(int)expire response:(void (^)(NSDictionary *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self put:key object:entity timeToKeep:expire responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)get:(NSString *)key response:(void (^)(NSDictionary *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self get:key responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
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
