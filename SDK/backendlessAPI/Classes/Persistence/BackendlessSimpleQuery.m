//
//  BackendlessSimpleQuery.m
//  backendlessAPI
//
//  Created by Slava Vdovichenko on 8/13/15.
//  Copyright (c) 2015 BACKENDLESS.COM. All rights reserved.
//

#import "BackendlessSimpleQuery.h"
#import "DEBUG.h"

@implementation BackendlessSimpleQuery

-(id)init {
    if (self = [super init]) {
        self.pageSize = @(DEFAULT_PAGE_SIZE);
        self.offset = @(DEFAULT_OFFSET);
    }
    return self;
}

+(id)query {
    return [[BackendlessSimpleQuery new] autorelease];
}

+(id)query:(int)pageSize offset:(int)offset {
    BackendlessSimpleQuery *_query = [BackendlessSimpleQuery query];
    _query.pageSize = @(pageSize);
    _query.offset = @(offset);
    return _query;
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC BackendlessSimpleQuery"];
    [_pageSize release];
    [_offset release];    
    [super dealloc];
}

@end
