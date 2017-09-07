//
//  LoadRelationsQueryBuilder.m
//  backendlessAPI
//
//  Created by Admin on 12/6/16.
//  Copyright © 2016 BACKENDLESS.COM. All rights reserved.
//

#import "LoadRelationsQueryBuilder.h"
#import "DEBUG.h"
#import "QueryOptions.h"
#import "BackendlessDataQuery.h"
#import "PagedQueryBuilder.h"

@interface LoadRelationsQueryBuilder () {
    NSString *_relationName;
    NSMutableArray<NSString *> *_relationNames;
    Class _relationType;
    PagedQueryBuilder *_pagedQueryBuilder;
}
@end

@implementation LoadRelationsQueryBuilder

-(instancetype)init {
    if (self = [super init]) {
        _pagedQueryBuilder = [[PagedQueryBuilder alloc] init:self];
        _relationName = nil;
        _relationNames = [NSMutableArray<NSString *> new];
        _relationType = nil;
    }
    return self;
}

-(instancetype)initWithClass:(Class)relationType {
    if ( (self=[super init]) ) {
        _pagedQueryBuilder = [[PagedQueryBuilder alloc] init:self];
        _relationName = nil;
        _relationNames = [NSMutableArray<NSString *> new];
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
    QueryOptions *queryOptions = [QueryOptions new];
    if (_relationName) {
        [queryOptions addRelated:@[_relationName]];
    }
    else if ([_relationNames count] > 0) {
        [queryOptions addRelated:_relationNames];
    }
    dataQuery.queryOptions = queryOptions;
    return dataQuery;
}

// deprecated
-(instancetype) setRelationName:(NSString*) relationName {
    _relationName = relationName;
    return self;
}
//

// **************************************************

-(instancetype) addRelation:(NSString *)name {
    [_relationNames addObject:name];
    return self;
}

-(instancetype) setRelations:(NSArray<NSString *> *)names {
    _relationNames = (NSMutableArray<NSString *> *)names;
    return self;
}

// **************************************************

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

@end
