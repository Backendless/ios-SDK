//
//  PagedQueryBuilder.m
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

#import "PagedQueryBuilder.h"
#import "DEBUG.h"
#import "BackendlessDataQuery.h"

#define DEFAULT_PAGE_SIZE 10
#define DEFAULT_OFFSET 0

@interface PagedQueryBuilder () {
    int _pageSize;
    int _offset;
    id _builder;
}
@end


@implementation PagedQueryBuilder

-(instancetype)init {
    if (self = [super init]) {
        _pageSize = DEFAULT_PAGE_SIZE;
        _offset  =DEFAULT_OFFSET;
        _builder = nil;
    }
    return self;
}

-(instancetype)init:(id)builder {
    if ( (self=[super init]) ) {
        _pageSize = DEFAULT_PAGE_SIZE;
        _offset  =DEFAULT_OFFSET;
        _builder = [builder retain];
    }
    return self;
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC PagedQueryBuilder"];
    [_builder release];
    [super dealloc];
}

-(BackendlessDataQuery *)build {
    [self validateOffset:_offset];
    [self validatePageSize:_pageSize];
    BackendlessDataQuery *dataQuery = [BackendlessDataQuery new];
    dataQuery.pageSize = @(_pageSize);
    dataQuery.offset = @(_offset);
    return dataQuery;
}

-(id)setPageSize:(int)pageSize {
    [self validatePageSize:pageSize];
    _pageSize = pageSize;
    return _builder;
}

-(id)setOffset:(int)offset {
    [self validateOffset:offset];
    _offset = offset;
    return _builder;
}

-(id)prepareNextPage {
    int offset = _offset + _pageSize;
    [self validateOffset:offset];
    _offset = offset;
    return _builder;
}

-(id)preparePreviousPage {
    int offset = _offset - _pageSize;
    [self validateOffset:offset];
    _offset = offset;
    return _builder;
}

-(void)validateOffset:(int)offset {
    if (offset < 0) {
        
    }
    //throw new IllegalArgumentException( ExceptionMessage.WRONG_OFFSET );
}

-(void)validatePageSize:(int)pageSize {
    if (pageSize <= 0) {
        
    }
    //throw new IllegalArgumentException( ExceptionMessage.WRONG_PAGE_SIZE );
}

@end
