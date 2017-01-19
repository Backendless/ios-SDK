//
//  PagedQueryBuilder.m
//  backendlessAPI
//
//  Created by Slava Vdovichenko on 11/9/16.
//  Copyright © 2016 BACKENDLESS.COM. All rights reserved.
//

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
    if ( (self=[super init]) ) {
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


#pragma mark -
#pragma mark Public Methods

-(BackendlessDataQuery *)build {
    
    [self validateOffset:_offset];
    [self validatePageSize:_pageSize];
    
    BackendlessDataQuery *dataQuery = [BackendlessDataQuery new];
    dataQuery.pageSize = @(_pageSize);
    dataQuery.offset = @(_offset);
    
    return dataQuery;
}

#pragma mark -
#pragma mark IPagedQueryBuilder Methods

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

/**
 * Updates offset to point at next data page by adding pageSize.
 */
-(id)prepareNextPage {
    
    int offset = _offset + _pageSize;
    [self validateOffset:offset];
    _offset = offset;
    
    return _builder;
}

/**
 * Updates offset to point at previous data page by subtracting pageSize.
 */
-(id)preparePreviousPage {
    
    int offset = _offset - _pageSize;
    [self validateOffset:offset];
    _offset = offset;
    
    return _builder;
}


#pragma mark -
#pragma mark Private Methods

-(void)validateOffset:(int)offset {
    if( offset < 0 ) {
        
    }
        //throw new IllegalArgumentException( ExceptionMessage.WRONG_OFFSET );
}

-(void)validatePageSize:(int)pageSize {
    if( pageSize <= 0 ) {
        
    }
        //throw new IllegalArgumentException( ExceptionMessage.WRONG_PAGE_SIZE );
}

@end
