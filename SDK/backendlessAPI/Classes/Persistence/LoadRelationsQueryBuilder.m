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

@interface LoadRelationsQueryBuilder () {
    NSString *_relationName;
    Class _relationType;
    PagedQueryBuilder *_pagedQueryBuilder;
}
@end

@implementation LoadRelationsQueryBuilder

-(instancetype)init {
    if (self = [super init]) {
        _pagedQueryBuilder = [[PagedQueryBuilder alloc] init:self];
        _relationName = nil;
        _relationType = nil;
    }
    return self;
}

-(instancetype)initWithClass:(Class)relationType {
    if ( (self=[super init]) ) {
        _pagedQueryBuilder = [[PagedQueryBuilder alloc] init:self];
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

@end
