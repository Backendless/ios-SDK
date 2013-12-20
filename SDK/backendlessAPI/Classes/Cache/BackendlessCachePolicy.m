//
//  BackendlessCachePolicy.m
//  backendlessAPI
//
//  Created by Yury Yaschenko on 8/12/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import "BackendlessCachePolicy.h"

@implementation BackendlessCachePolicy
-(id)init
{
    self = [super init];
    if (self) {
        _timeToLive = [[NSNumber alloc] initWithInt:-1];
        _cachePolicy = [[NSNumber alloc] initWithInt:BackendlessCachePolicyIgnoreCache];
    }
    return self;
}

-(void)dealloc
{
    [_timeToLive release];
    [_cachePolicy release];
    [super dealloc];
}

-(BackendlessCachePolicyEnum)valCachePolicy
{
    return (BackendlessCachePolicyEnum)[_cachePolicy integerValue];
}
-(void)cachePolicy:(BackendlessCachePolicyEnum)cachePolicy
{
    [_cachePolicy release];
    _cachePolicy = [[NSNumber alloc] initWithInt:cachePolicy];
    
}
@end
