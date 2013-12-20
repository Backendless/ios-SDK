//
//  BackendlessCachePolicy.h
//  backendlessAPI
//
//  Created by Yury Yaschenko on 8/12/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum
{
    BackendlessCachePolicyIgnoreCache,
    BackendlessCachePolicyCacheOnly,
    BackendlessCachePolicyRemoteDataOnly,
    BackendlessCachePolicyFromCacheOrRemote,
    BackendlessCachePolicyFromRemoteOrCache,
    BackendlessCachePolicyFromCacheAndRemote
} BackendlessCachePolicyEnum;

typedef enum
{
    BackendlessCacheStoredMemory,
    BackendlessCacheStoredDisc
} BackendlessCacheStoredEnum;


@interface BackendlessCachePolicy : NSObject

@property (nonatomic, strong) NSNumber *timeToLive;
@property (nonatomic, strong) NSNumber *cachePolicy;

-(void)cachePolicy:(BackendlessCachePolicyEnum)cachePolicy;
-(BackendlessCachePolicyEnum)valCachePolicy;

@end
