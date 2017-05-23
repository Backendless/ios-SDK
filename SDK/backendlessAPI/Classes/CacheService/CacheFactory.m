//
//  CacheFactory.m
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

#import "CacheFactory.h"
#include "Backendless.h"

#define FAULT_NO_ENTITY_TYPE [Fault fault:@"Entity type is not valid" faultCode:@"0000"]

@interface CacheFactory () {
    NSString *_key;
    Class _entityClass;
}
@end

@implementation CacheFactory

-(id)init {
    if ( (self=[super init]) ) {
        _key = @"DEFAULT_KEY";
        _entityClass = nil;
    }
    return self;
}

-(id)init:(NSString *)key type:(Class)entityClass {
    if ( (self=[super init]) ) {
        _key = [key retain];
        _entityClass = [entityClass retain];
    }
    return self;
}

+(id <ICacheService>)create:(NSString *)key {
    return [[CacheFactory alloc] init:key type:nil];
}

+(id <ICacheService>)create:(NSString *)key type:(Class)entityClass {
    return [[CacheFactory alloc] init:key type:entityClass];
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC CacheFactory"];
    [_key release];
    [_entityClass release];
    [super dealloc];
}

#pragma mark -
#pragma mark Private Methods

-(Fault *)entityValidation:(id)entity {
    return (_entityClass && ![(NSObject *)entity isKindOfClass:_entityClass]) ? [backendless throwFault:FAULT_NO_ENTITY_TYPE] : nil;
}

#pragma mark -
#pragma mark ICacheService Methods

// sync methods with fault return (as exception)

-(void)put:(id)entity {
    [self put:entity timeToLive:0];
}

-(void)put:(id)entity timeToLive:(int)seconds {
    Fault *fault = [self entityValidation:entity];
    fault ? [backendless throwFault:fault] : [backendless.cache put:_key object:entity timeToLive:seconds];
}

-(id)get {
    return [backendless.cache get:_key];
}

-(NSNumber *)contains {
    return [backendless.cache contains:_key];
}

-(id)expireIn:(int)seconds {
    return [backendless.cache expireIn:_key timeToLive:seconds];
}

-(id)expireAt:(NSDate *)timestamp {
    return [backendless.cache expireAt:_key timestamp:timestamp];
}

-(id)remove {
    return [backendless.cache remove:_key];
}

// async methods with block-based callback

-(void)put:(id)entity response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self put:entity timeToLive:0 response:responseBlock error:errorBlock];
}

-(void)put:(id)entity timeToLive:(int)seconds response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    id<IResponder> responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    Fault *noValid = [self entityValidation:entity];
    noValid ? [responder errorHandler:noValid] : [backendless.cache put:_key object:entity timeToLive:seconds response:responseBlock error:errorBlock];
}

-(void)get:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.cache get:_key response:responseBlock error:errorBlock];
}

-(void)contains:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.cache contains:_key response:responseBlock error:errorBlock];
}

-(void)expireIn:(int)seconds response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.cache expireIn:_key timeToLive:seconds response:responseBlock error:errorBlock];
}

-(void)expireAt:(NSDate *)timestamp response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.cache expireAt:_key timestamp:timestamp response:responseBlock error:errorBlock];
}

-(void)remove:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.cache remove:_key response:responseBlock error:errorBlock];
}

@end
