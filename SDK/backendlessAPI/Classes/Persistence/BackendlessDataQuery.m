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

#define DEFAULT_PAGE_SIZE 10
#define DEFAULT_OFFSET 0

@implementation BackendlessDataQuery

-(id)init {
	if ( (self=[super init]) ) {
        
        self.pageSize = @(DEFAULT_PAGE_SIZE);
        self.offset = @(DEFAULT_OFFSET);
        self.properties = nil;
        self.whereClause = nil;
        self.queryOptions = [QueryOptions query];
	}
	
	return self;
}

-(id)init:(NSArray *)properties where:(NSString *)whereClause query:(QueryOptions *)queryOptions {
	
    if ( (self=[super init]) ) {
        
        self.pageSize = @(DEFAULT_PAGE_SIZE);
        self.offset = @(DEFAULT_OFFSET);
        self.properties = properties;
        self.whereClause = whereClause;
        self.queryOptions = queryOptions;
	}
	
	return self;
}

+(id)query {
    return [[BackendlessDataQuery new] autorelease];
}

+(id)query:(NSArray *)properties where:(NSString *)whereClause query:(QueryOptions *)queryOptions {
    return [[[BackendlessDataQuery alloc] init:properties where:whereClause query:queryOptions] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BackendlessDataQuery: %@", self];
    
    [self.pageSize release];
    [self.offset release];
    [self.properties release];
    [self.whereClause release];
    [self.queryOptions release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(NSString *)description {
    return [NSString stringWithFormat:@"<BackendlessDataQuery> -> pageSize: %@, offset: %@ properties: %@, whereClause: %@, queryOptions: %@", self.pageSize, self.offset, self.properties, self.whereClause, self.queryOptions];
}

#pragma mark -
#pragma mark NSCopying Methods

-(id)copyWithZone:(NSZone *)zone {
    
    BackendlessDataQuery *query = [BackendlessDataQuery query];
    query.pageSize = _pageSize.copy;
    query.offset = _offset.copy;
    query.properties = _properties.copy;
    query.whereClause = _whereClause.copy;
    query.queryOptions = _queryOptions.copy;
    return query;
}

@end
