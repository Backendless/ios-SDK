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

-(id)init {
	if ( (self=[super init]) ) {
        
        self.properties = nil;
        self.whereClause = nil;
        self.queryOptions = [QueryOptions query];
        self.cachePolicy = nil;
	}
	
	return self;
}

-(id)init:(NSArray *)properties where:(NSString *)whereClause query:(QueryOptions *)queryOptions {
	
    if ( (self=[super init]) ) {
        
        self.properties = properties;
        self.whereClause = whereClause;
        self.queryOptions = queryOptions;
        self.cachePolicy = nil;
	}
	
	return self;
}

+(BackendlessDataQuery *)query {
    return [[BackendlessDataQuery new] autorelease];
}

+(BackendlessDataQuery *)query:(NSArray *)properties where:(NSString *)whereClause query:(QueryOptions *)queryOptions {
    return [[[BackendlessDataQuery alloc] init:properties where:whereClause query:queryOptions] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BackendlessDataQuery: %@", self];
    
    [self.properties release];
    [self.whereClause release];
    [self.queryOptions release];
	[self.cachePolicy release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(NSString *)description {
    return [NSString stringWithFormat:@"<BackendlessDataQuery> -> properties: %@, whereClause: %@, queryOptions: %@", self.properties, self.whereClause, self.queryOptions];
}

-(BOOL)isEqualToQuery:(BackendlessDataQuery *)query
{
    if (self.queryOptions && query.queryOptions) {
        if (![self.queryOptions isEqualToQuery:query.queryOptions]) {
            return NO;
        }
    }

    if (![[NSSet setWithArray:self.properties] isEqualToSet:[NSSet setWithArray:query.properties]]) {
        return NO;
    }
    if (![self.whereClause isEqualToString:query.whereClause]) {
        if ((self.whereClause.length != 0) || (query.whereClause.length != 0)) {
            return NO;
        }
    }
    return YES;
}

@end
