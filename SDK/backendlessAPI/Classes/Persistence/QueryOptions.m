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
#import "Types.h"

@implementation QueryOptions

-(id)init {
	if ( (self=[super init]) ) {
#if 0 // http://bugs.backendless.com/browse/BKNDLSS-13002
        self.sortBy = nil;
#else
        self.sortBy = [[NSMutableArray alloc] initWithArray:@[@"objectId"]];
#endif
        self.related = nil;
	}
	
	return self;
}

+(instancetype)query {
    return [[QueryOptions new] autorelease];
}


-(void)dealloc {
	
	[DebLog logN:@"DEALLOC QueryOptions"];
    
    [self.sortBy release];
    [self.related release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(BOOL)addSortByOption:(NSString *)sortBy {
    
    if (!sortBy || !sortBy.length)
        return NO;
    
    if (!self.sortBy) self.sortBy = [NSMutableArray new];
    [self.sortBy addObject:sortBy];
    return YES;
}

-(BOOL)addRelated:(NSString *)related {
    
    if (!related || !related.length)
        return NO;
    
    if (!self.related) self.related = [NSMutableArray new];
    [self.related addObject:related];
    return YES;
}

-(QueryOptions *)newInstanse {
    
    QueryOptions *query = [QueryOptions query];
    query.relationsDepth = self.relationsDepth.copy;
    query.sortBy = self.sortBy.mutableCopy;
    query.related = self.related.mutableCopy;
    
    return query;    
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<QueryOptions> -> %@", [Types propertyDictionary:self]];
}

#pragma mark -
#pragma mark NSCopying Methods

-(id)copyWithZone:(NSZone *)zone {
    
    QueryOptions *query = [QueryOptions query];
    query.relationsDepth = self.relationsDepth.copy;
    query.sortBy = self.sortBy.mutableCopy;
    query.related = self.related.mutableCopy;
    
    return query;
}

@end
