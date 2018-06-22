//
//  BackendlessCacheKey.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "BackendlessCacheKey.h"

@implementation BackendlessCacheKey

-(BackendlessCacheKey *)initWithClass:(Class)_class query:(id)query {
    if (self = [super init]) {
        _className = NSStringFromClass(_class);
        _query = [query retain];
    }
    return self;
}

-(BackendlessCacheKey *)initWithClassName:(NSString *)className query:(id)query {
    if (self = [super init]) {
        _className = [className retain];
        _query = [query retain];
    }
    return self;
}

-(void)dealloc {
    [_className release];
    [_query release];
    [super dealloc];
}

-(NSUInteger)hash {
    return [_className hash];
}

-(BOOL)isEqual:(BackendlessCacheKey *)object {
    if (![_className isEqualToString:object.className]) {
        return NO;
    }
    NSLog(@"%@", [_query class]);
    if (![_query isEqualToQuery:object.query]) {
        return NO;
    }
    return YES;
}

+(BackendlessCacheKey *)cacheKeyWithClass:(Class)_class query:(id)query {
    return [[[BackendlessCacheKey alloc] initWithClass:_class query:query] autorelease];
}

+(BackendlessCacheKey *)cacheKeyWithClassName:(NSString *)className query:(id)query {
    return [[[BackendlessCacheKey alloc] initWithClassName:className query:query] autorelease];
}

-(id)copyWithZone:(NSZone *)zone {
    return [self retain];
}

@end
