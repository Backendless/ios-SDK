//
//  BackendlessDataQuery.m
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

#import "BackendlessDataQuery.h"
#import "DEBUG.h"
#import "QueryOptions.h"
#import "BackendlessCachePolicy.h"

@implementation BackendlessDataQuery
@synthesize properties, whereClause, queryOptions, cachePolicy;

-(id)init {
	if ( (self=[super init]) ) {
        properties = nil;
        whereClause = nil;
        queryOptions = [QueryOptions new];
        cachePolicy = nil;
	}
	
	return self;
}

-(id)init:(NSArray *)_properties where:(NSString *)_whereClause query:(QueryOptions *)_queryOptions {
	if ( (self=[super init]) ) {
        if (_properties.count == 0) {
            _properties = nil;
        }
        properties = (_properties) ? [_properties retain] : nil;
        whereClause = (_whereClause) ? [_whereClause retain] : nil;
        queryOptions = (_queryOptions) ? [_queryOptions retain] : [[QueryOptions query] retain];
        cachePolicy = nil;
	}
	
	return self;
}

+(BackendlessDataQuery *)query {
    return [[BackendlessDataQuery new] autorelease];
}

+(BackendlessDataQuery *)query:(NSArray *)_properties where:(NSString *)_whereClause query:(QueryOptions *)_queryOptions {
    return [[[BackendlessDataQuery alloc] init:_properties where:_whereClause query:_queryOptions] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BackendlessDataQuery: %@", self];
    
    [properties release];
    [whereClause release];
    [queryOptions release];
	[cachePolicy release];
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(NSString *)description {
    return [NSString stringWithFormat:@"<BackendlessDataQuery> -> properties: %@, whereClause: %@, queryOptions: %@", properties, whereClause, queryOptions];
}

-(BOOL)isEqualToQuery:(BackendlessDataQuery *)query
{
    if (self.queryOptions&&query.queryOptions) {
        if (![self.queryOptions isEqualToQuery:query.queryOptions]) {
            return NO;
        }
    }

    if (![[NSSet setWithArray:properties] isEqualToSet:[NSSet setWithArray:query.properties]]) {
        return NO;
    }
    if (![whereClause isEqualToString:query.whereClause]) {
        if ((whereClause.length != 0)||(query.whereClause.length != 0)) {
            return NO;
        }
    }
    return YES;
}

@end
