//
//  QueryOptionsBuilder.m
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

#import "QueryOptionsBuilder.h"
#import "DEBUG.h"
#import "QueryOptions.h"

@interface QueryOptionsBuilder () {
    NSMutableArray<NSString *> *_sortBy;
    NSMutableArray<NSString *> *_related;
    NSNumber *_relationsDepth;
    id _builder;
}
@end

@implementation QueryOptionsBuilder

-(instancetype)init {
    if (self = [super init]) {
        _sortBy = [NSMutableArray new];
        _related = [NSMutableArray new];
        _builder = nil;
        _relationsDepth = nil;
    }
    return self;
}

-(instancetype)init:(id)builder {
    if (self = [super init]) {
        _sortBy = [NSMutableArray new];
        _related = [NSMutableArray new];
        _builder = [builder retain];
    }
    return self;
}


-(void)dealloc {
    [DebLog logN:@"DEALLOC QueryOptionsBuilder"];
    [_sortBy release];
    [_related release];
    [_builder release];
    [super dealloc];
}

-(QueryOptions *)build {
    QueryOptions *queryOptions =  [QueryOptions new];
    queryOptions.sortBy = [[NSMutableArray alloc] initWithArray:_sortBy];
    queryOptions.related = [[NSMutableArray alloc] initWithArray:_related];
    queryOptions.relationsDepth = _relationsDepth;
    return queryOptions;
}

-(NSMutableArray<NSString *> *)getSortBy {
    return _sortBy;
}

-(id)setSortBy:(NSArray<NSString *> *)sortBy {
    if (sortBy) {
        _sortBy = [[NSMutableArray alloc] initWithArray:sortBy];
    }
    return _builder;
}

-(id)addSortBy:(NSString *)sortBy {
    if (sortBy) {
        [_sortBy addObject:sortBy];
    }
    return _builder;
}

-(id)addListSortBy:(NSArray<NSString *> *)sortBy {
    if (sortBy) {
        [_sortBy addObjectsFromArray:sortBy];
    }
    return _builder;
}

-(NSMutableArray<NSString *> *)getRelated {
    return _related;
}

-(id)setRelated:(NSArray<NSString *> *)related {
    if (related) {
        _related = [[NSMutableArray alloc] initWithArray:related];
    }
    return _builder;
}

-(id)addRelated:(NSString *)related {
    if (related) {
        [_related addObject:related];
    }
    return _builder;
}

-(id)addListRelated:(NSArray<NSString *> *)related {
    if (related) {
        [_related addObjectsFromArray:related];
    }
    return _builder;
}

-(NSNumber *)getRelationsDepth {
    return _relationsDepth;
}

-(id)setRelationsDepth:(int)relationsDepth {
    _relationsDepth = @(relationsDepth);
    return _builder;
}

@end
