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

-(instancetype)init {
	if ( (self=[super init]) ) {
        
        pageSize = DEFAULT_PAGE_SIZE;
        offset = DEFAULT_OFFSET;
        self.properties = nil;
        self.whereClause = nil;
        self.queryOptions = [QueryOptions query];
	}
	
	return self;
}

-(instancetype)init:(NSArray *)properties where:(NSString *)whereClause query:(QueryOptions *)queryOptions {
	
    if ( (self=[super init]) ) {
        
        pageSize = DEFAULT_PAGE_SIZE;
        offset = DEFAULT_OFFSET;
        //self.properties = properties;
        self.properties = [[NSMutableArray alloc] initWithArray:properties];
        self.whereClause = whereClause;
        self.queryOptions = queryOptions;
	}
	
	return self;
}

+(instancetype)query {
    return [[BackendlessDataQuery new] autorelease];
}

+(instancetype)query:(NSArray *)properties where:(NSString *)whereClause query:(QueryOptions *)queryOptions {
    return [[[BackendlessDataQuery alloc] init:properties where:whereClause query:queryOptions] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BackendlessDataQuery: %@", self];
    
    [self.properties release];
    [self.whereClause release];
    [self.queryOptions release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark getters / setters

-(NSNumber *)pageSize {
    //[DebLog logY:@" ------ pageSize"];
    return @(pageSize);
}

-(void)setPageSize:(NSNumber *)_pageSize {
    //[DebLog logY:@" ------ setPageSize"];
    pageSize = [_pageSize intValue];
}

-(NSNumber *)offset {
    //[DebLog logY:@" ------ offset"];
    return @(offset);
}

-(void)setOffset:(NSNumber *)_offset {
    //[DebLog logY:@" ------ setOffset"];
    offset = [_offset intValue];
}

#pragma mark -
#pragma mark Public Methods

-(BOOL)addProperty:(NSString *)property {
    
    if (!property || !property.length)
        return NO;
    
    if (!self.properties) self.properties = [NSMutableArray new];
    [self.properties addObject:property];
    return YES;
}


-(void)prepareForNextPage {
    offset += pageSize;
}

-(void)prepareForPreviousPage {
    offset -= pageSize;
}


-(NSString *)description {
    return [NSString stringWithFormat:@"<BackendlessDataQuery> -> pageSize: %@, offset: %@ properties: %@, whereClause: %@, queryOptions: %@", self.pageSize, self.offset, self.properties, self.whereClause, self.queryOptions];
}

#pragma mark -
#pragma mark NSCopying Methods

-(id)copyWithZone:(NSZone *)zone {
    
    BackendlessDataQuery *query = [BackendlessDataQuery query];
    query.pageSize = self.pageSize.copy;
    query.offset = self.offset.copy;
    query.properties = self.properties.copy;
    query.whereClause = self.whereClause.copy;
    query.queryOptions = self.queryOptions.copy;
    return query;
}

@end
