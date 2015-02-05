//
//  BackendlessCachePolicy.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2014 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

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


@interface BackendlessCachePolicy : NSObject <NSCopying>

@property (nonatomic, strong) NSNumber *timeToLive;
@property (nonatomic, strong) NSNumber *cachePolicy;

-(void)cachePolicy:(BackendlessCachePolicyEnum)cachePolicy;
-(BackendlessCachePolicyEnum)valCachePolicy;
-(void)timeToLive:(int)timeToLive;
-(int)valTimeToLive;
@end
