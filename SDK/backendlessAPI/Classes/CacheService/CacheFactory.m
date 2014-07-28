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
#if !NEW_API_ON
#include "CacheService.h"
#endif

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

// sync methods with fault option

-(BOOL)put:(id)entity fault:(Fault **)fault {
    return [self put:entity timeToKeep:0 fault:fault];
}

-(BOOL)put:(id)entity timeToKeep:(int)expire fault:(Fault **)fault {
    
    Fault *noValid = [self entityValidation:entity];
    if (noValid) {
        if (fault) {
            (*fault) = noValid;
        }
        return NO;
    }
    
    return [backendless.cacheService put:_key object:entity timeToKeep:expire fault:fault];
}

-(id)get:(Fault **)fault {
    return [backendless.cacheService get:_key fault:fault];
}

-(NSNumber *)contains:(Fault **)fault {
    return [backendless.cacheService contains:_key fault:fault];
}

-(BOOL)expire:(int)expire fault:(Fault **)fault {
    return [backendless.cacheService expire:_key timeToKeep:expire fault:fault];
}

-(BOOL)delete:(Fault **)fault {
    return [backendless.cacheService delete:_key fault:fault];
}

// async methods with responder

-(void)put:(id)entity responder:(id<IResponder>)responder {
    [self put:entity timeToKeep:0 responder:responder];
}

-(void)put:(id)entity timeToKeep:(int)expire responder:(id<IResponder>)responder {
    Fault *noValid = [self entityValidation:entity];
    noValid ? [responder errorHandler:noValid] : [backendless.cacheService put:_key object:entity timeToKeep:expire responder:responder];
}

-(void)getToResponder:(id<IResponder>)responder {
    [backendless.cacheService get:_key responder:responder];
}

-(void)containsToResponder:(id<IResponder>)responder {
    [backendless.cacheService contains:_key responder:responder];
}

-(void)expire:(int)expire responder:(id<IResponder>)responder {
    [backendless.cacheService expire:_key timeToKeep:expire responder:responder];
}

-(void)deleteToResponder:(id<IResponder>)responder {
    [backendless.cacheService delete:_key responder:responder];
}

// async methods with block-based callback

-(void)put:(id)entity response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self put:entity timeToKeep:0 response:responseBlock error:errorBlock];
}

-(void)put:(id)entity timeToKeep:(int)expire response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self put:entity timeToKeep:expire responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)get:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.cacheService get:_key response:responseBlock error:errorBlock];
}

-(void)contains:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.cacheService contains:_key response:responseBlock error:errorBlock];
}

-(void)expire:(int)expire response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.cacheService expire:_key timeToKeep:expire response:responseBlock error:errorBlock];
}

-(void)delete:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [backendless.cacheService delete:_key response:responseBlock error:errorBlock];
}

@end
