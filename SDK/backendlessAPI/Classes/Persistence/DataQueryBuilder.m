//
//  DataQueryBuilder.m
//  backendlessAPI
//
//  Created by Slava Vdovichenko on 11/10/16.
//  Copyright © 2016 BACKENDLESS.COM. All rights reserved.
//

#import "DataQueryBuilder.h"
#import "DEBUG.h"
#import "BackendlessDataQuery.h"

@interface DataQueryBuilder () {
    PagedQueryBuilder *_pagedQueryBuilder;
    QueryOptionsBuilder *_queryOptionsBuilder;
    NSMutableArray<NSString *> *_properties;
    NSString *_whereClause;
    NSMutableArray<NSString *> *_groupBy;
    NSString *_havingClause;
}
@end

@implementation DataQueryBuilder

-(instancetype)init {
    if (self = [super init]) {
        _pagedQueryBuilder = [[PagedQueryBuilder alloc] init:self];
        _queryOptionsBuilder = [[QueryOptionsBuilder alloc] init:self];
        _properties = [NSMutableArray<NSString *> new];
        _whereClause = nil;
        _groupBy = [NSMutableArray<NSString *> new];
        _havingClause = nil;
    }
    return self;
}

#pragma mark -
#pragma mark Public Methods

-(BackendlessDataQuery *)build {
    BackendlessDataQuery *dataQuery = [BackendlessDataQuery new];
    dataQuery = [_pagedQueryBuilder build];
    dataQuery.queryOptions = [_queryOptionsBuilder build];
    dataQuery.properties = _properties ? [[NSMutableArray alloc] initWithArray:_properties] : nil;
    dataQuery.whereClause = _whereClause.copy;
    dataQuery.groupBy = _groupBy ? [[NSMutableArray alloc] initWithArray:_groupBy] : nil;
    dataQuery.havingClause = _havingClause.copy;
    return dataQuery;
}

-(instancetype)setPageSize:(int)pageSize {
    [_pagedQueryBuilder setPageSize:pageSize];
    return self;
}

-(instancetype)setOffset:(int)offset {
    [_pagedQueryBuilder setOffset:offset];
    return self;
}

/**
 * Updates offset to point at next data page by adding pageSize.
 */
-(instancetype)prepareNextPage {
    [_pagedQueryBuilder prepareNextPage];
    return self;
}

/**
 * Updates offset to point at previous data page by subtracting pageSize.
 */
-(instancetype)preparePreviousPage {
    [_pagedQueryBuilder preparePreviousPage];
    return self;
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

-(NSString *)getWhereClause {
    return _whereClause;
}

-(instancetype)setWhereClause:(NSString *)whereClause {
    _whereClause = whereClause;
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

-(NSMutableArray<NSString *> *)getRelated {
    return [_queryOptionsBuilder getRelated];
}

-(instancetype)setRelated:(NSArray<NSString *> *)related {
    if (related) {
        [_queryOptionsBuilder setRelated:related];
    }
    return self;
}

-(instancetype)addRelated:(NSString *)related {
    if (related) {
        [_queryOptionsBuilder addRelated:related];
    }
    return self;
}

-(instancetype)addListRelated:(NSArray<NSString *> *)related {
    if (related) {
        [_queryOptionsBuilder addListRelated:related];
    }
    return self;
}

-(NSNumber *)getRelationsDepth {    
    return [_queryOptionsBuilder getRelationsDepth];
}

-(instancetype)setRelationsDepth:(int)relationsDepth {
    [_queryOptionsBuilder setRelationsDepth:relationsDepth];
    return self;
}

-(instancetype)setGroupByProperties:(NSArray<NSString*> *)groupBy {
    if (groupBy) {
        _groupBy = [[NSMutableArray alloc] initWithArray:groupBy];
    }
    return self;
}

-(instancetype)addGroupByProperty:(NSString *)groupBy {
    if (groupBy) {
        [_groupBy addObject:groupBy];
    }
    return self;
}

-(instancetype)addGroupByProperies:(NSArray<NSString *> *)groupBy {
    if (groupBy) {
        [_groupBy addObjectsFromArray:groupBy];
    }
    return self;
}

-(instancetype)setHavingClause:(NSString *)havingClause {
    if (havingClause) {
        _havingClause = havingClause;
    }
    return self;
}

@end
