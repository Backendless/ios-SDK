//
//  QueryOptions.m
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

#import "QueryOptions.h"
#import "DEBUG.h"

@implementation QueryOptions
@synthesize pageSize, offset, sortBy, related;

-(id)init {
	if ( (self=[super init]) ) {
        pageSize = [[NSNumber alloc] initWithInt:20];
        offset = [[NSNumber alloc] initWithInt:0];
        sortBy = nil;
        related = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(id)initWithPageSize:(int)_pageSize offset:(int)_offset {
	if ( (self=[super init]) ) {
        pageSize = [[NSNumber alloc] initWithInt:_pageSize];
        offset = [[NSNumber alloc] initWithInt:_offset];
        sortBy = nil;
        related = [[NSMutableArray alloc] init];
	}
	
	return self;
}

+(QueryOptions *)query {
    return [[QueryOptions new] autorelease];
}

+(QueryOptions *)query:(int)_pageSize offset:(int)_offset {
    return [[[QueryOptions alloc] initWithPageSize:_pageSize offset:_offset] autorelease];
}


-(void)dealloc {
	
	[DebLog logN:@"DEALLOC QueryOptions"];
    
    [pageSize release];
    [offset release];
    [sortBy release];
    [related release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(QueryOptions *)pageSize:(int)_pageSize {
    if (pageSize) [pageSize release];
    pageSize = [[NSNumber alloc] initWithInt:_pageSize];
    return self;
}

-(QueryOptions *)offset:(int)_offset {
    if (offset) [offset release];
    offset = [[NSNumber alloc] initWithInt:_offset];
    return self;
}

-(QueryOptions *)sortBy:(NSArray *)_sortBy {
    if (sortBy) [sortBy release];
    sortBy = [_sortBy retain];
    return self;
}

-(QueryOptions *)related:(NSArray *)_related {
    if (related) [related release];
    related = [[NSMutableArray alloc] initWithArray:_related];
    return self;
}
-(BOOL)addRelated:(NSString *)_related
{
    [related addObject:_related];
    return YES;
}
-(NSDictionary *)getQuery {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (pageSize) [dict setValue:pageSize forKey:@"pageSize"];
    if (offset) [dict setValue:offset forKey:@"offset"];
    if (sortBy) [dict setValue:sortBy forKey:@"sortBy"];
    if (related) [dict setValue:related forKey:@"related"];
    
    return dict;
}
-(BOOL)isEqualToQuery:(QueryOptions *)query
{
    if (![self.pageSize isEqualToNumber:query.pageSize]) {
        return NO;
    }
    if (![self.offset isEqualToNumber:query.offset]) {
        return NO;
    }
    if (![self.related isEqualToArray:query.related]) {
        return NO;
    }
    if (![self.sortBy isEqualToArray:query.sortBy]) {
        if ((self.sortBy.count !=0)||(query.sortBy.count != 0)) {
            return NO;
        }
    }
    return YES;
}
-(NSString *)description {
    return [NSString stringWithFormat:@"<QueryOptions> -> %@", [self getQuery]];
}

@end
