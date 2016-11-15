//
//  QueryOptionsBuilder.m
//  backendlessAPI
//
//  Created by Slava Vdovichenko on 11/9/16.
//  Copyright © 2016 BACKENDLESS.COM. All rights reserved.
//

#import "QueryOptionsBuilder.h"
#import "DEBUG.h"
#import "QueryOptions.h"

@interface QueryOptionsBuilder () {
    NSMutableArray<NSString *> *_sortBy;
    NSMutableArray<NSString *> *_related;
    int _relationsDepth;
    id _builder;
}
@end

@implementation QueryOptionsBuilder

-(instancetype)init {
    if ( (self=[super init]) ) {
        
        _sortBy = [NSMutableArray new];
        _related = [NSMutableArray new];
        _builder = nil;
    }
    
    return self;
}

-(instancetype)init:(id)builder {
    if ( (self=[super init]) ) {
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

#pragma mark -
#pragma mark Public Methods

-(QueryOptions *)build {
    
    QueryOptions *queryOptions =  [QueryOptions new];
    queryOptions.sortBy = [[NSMutableArray alloc] initWithArray:_sortBy];
    queryOptions.related = [[NSMutableArray alloc] initWithArray:_related];
    queryOptions.relationsDepth = @(_relationsDepth);
    return queryOptions;
}


#pragma mark -
#pragma mark IQueryOptionsBuilder Methods

-(NSArray<NSString *> *)getSortBy {
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

-(NSArray<NSString *> *)getRelated {
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

-(int)getRelationsDepth {
    return _relationsDepth;
}

-(id)setRelationsDepth:(int)relationsDepth {
    _relationsDepth = relationsDepth;
    return _builder;
}

@end
