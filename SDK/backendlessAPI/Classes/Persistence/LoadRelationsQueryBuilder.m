//
//  LoadRelationsQueryBuilder.h
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

#import "LoadRelationsQueryBuilder.h"
#import "DEBUG.h"
#import "QueryOptions.h"
#import "BackendlessDataQuery.h"
#import "PagedQueryBuilder.h"
#import "QueryOptionsBuilder.h"

@interface LoadRelationsQueryBuilder () {
    NSString *_relationName;
    Class _relationType;
    PagedQueryBuilder *_pagedQueryBuilder;
    NSMutableArray<NSString *> *_properties;
    QueryOptionsBuilder *_queryOptionsBuilder;
}
@end

@implementation LoadRelationsQueryBuilder

-(instancetype)init {
    if (self = [super init]) {
        _pagedQueryBuilder = [[PagedQueryBuilder alloc] init:self];
        _properties = [NSMutableArray<NSString *> new];
        _queryOptionsBuilder = [[QueryOptionsBuilder alloc] init:self];
        _relationName = nil;
        _relationType = nil;
    }
    return self;
}

-(instancetype)initWithClass:(Class)relationType {
    if ( (self=[super init]) ) {
        _pagedQueryBuilder = [[PagedQueryBuilder alloc] init:self];
        _properties = [NSMutableArray<NSString *> new];
        _queryOptionsBuilder = [[QueryOptionsBuilder alloc] init:self];
        _relationName = nil;
        _relationType = relationType;
    }
    return self;
}

-(void)LoadRelationsQueryBuilder:(Class)relationType{
    _pagedQueryBuilder = [[PagedQueryBuilder alloc] init:self];
    _relationType = relationType;
}

+(instancetype)ofMap {
    LoadRelationsQueryBuilder *queryBuilder = [[LoadRelationsQueryBuilder alloc] initWithClass:NSDictionary.class];
    return queryBuilder;
}

+(instancetype)of:(Class)relationType {
    return [[LoadRelationsQueryBuilder alloc] initWithClass:relationType];
}

#pragma mark -
#pragma mark Public Methods

-(BackendlessDataQuery *)build {
    BackendlessDataQuery *dataQuery = [_pagedQueryBuilder build];
    dataQuery.properties = _properties ? [[NSMutableArray alloc] initWithArray:_properties] : nil;
    QueryOptions *queryOptions = [QueryOptions new];
    [queryOptions addRelated:_relationName];
    dataQuery.queryOptions = queryOptions;
    return dataQuery;
}

-(instancetype) setRelationName:(NSString*) relationName {
    _relationName = relationName;
    return self;
}

-(instancetype) setPageSize:(int)pageSize {
    [_pagedQueryBuilder setPageSize:pageSize];
    return self;
}

-(instancetype)setOffset:(int)offset {
    [_pagedQueryBuilder setOffset:offset];
    return self;
}

-(instancetype)prepareNextPage {
    [_pagedQueryBuilder prepareNextPage];
    return self;
}

-(instancetype)preparePreviousPage {
    [_pagedQueryBuilder preparePreviousPage];
    return self;
}

-(Class)getRelationType {
    return _relationType;
}

-(NSMutableArray<NSString*> *)getProperties {
    return _properties;
}

-(instancetype)setProperties:(NSArray<NSString*> *)properties {
    if (properties) {
        _properties = [[NSMutableArray alloc] initWithArray:properties];
    }
    return self;
}

-(instancetype)addProperty:(NSString *)property {
    if (property) {
        [_properties addObject:property];
    }
    return self;
}

-(instancetype)addProperties:(NSArray<NSString *> *)properties {
    if (properties) {
        [_properties addObjectsFromArray:properties];
    }
    return self;
}

-(NSMutableArray<NSString *> *)getSortBy {
    return [_queryOptionsBuilder getSortBy];
}

-(instancetype)setSortBy:(NSArray<NSString *> *)sortBy {
    if (sortBy) {
        [_queryOptionsBuilder setSortBy:sortBy];
    }
    return self;
}

-(instancetype)addSortBy:(NSString *)sortBy {
    if (sortBy) {
        [_queryOptionsBuilder addSortBy:sortBy];
    }
    return self;
}

-(instancetype)addListSortBy:(NSArray<NSString *> *)sortBy {
    if (sortBy) {
        [_queryOptionsBuilder addListSortBy:sortBy];
    }
    return self;
}

@end
