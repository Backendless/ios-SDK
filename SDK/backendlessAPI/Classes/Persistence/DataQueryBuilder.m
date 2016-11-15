//
//  DataQueryBuilder.m
//  backendlessAPI
//
//  Created by Slava Vdovichenko on 11/10/16.
//  Copyright © 2016 BACKENDLESS.COM. All rights reserved.
//

#import "DataQueryBuilder.h"
#import "DEBUG.h"

@interface DataQueryBuilder () {
    PagedQueryBuilder *_pagedQueryBuilder;
    QueryOptionsBuilder *_queryOptionsBuilder;
    NSMutableArray<NSString *> *_properties;
    NSString *_whereClause;
}
@end

@implementation DataQueryBuilder

-(instancetype)init {
    if ( (self=[super init]) ) {
        _pagedQueryBuilder = [[PagedQueryBuilder alloc] init:self];
        _queryOptionsBuilder = [[QueryOptionsBuilder alloc] init:self];
        _properties = [NSMutableArray new];
        _whereClause = nil;
    }
    
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC DataQueryBuilder"];
    
    [_pagedQueryBuilder release];
    [_queryOptionsBuilder release];
    [_properties removeAllObjects];
    [_properties release];
    [_whereClause release];
    
    [super dealloc];
}

@end
