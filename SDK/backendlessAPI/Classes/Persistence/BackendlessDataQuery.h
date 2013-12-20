//
//  BackendlessDataQuery.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
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
#import "AbstractQuery.h"

#define BACKENDLESS_DATA_QUERY [BackendlessDataQuery query]

@class QueryOptions;

@interface BackendlessDataQuery : AbstractQuery {
    
    NSArray     *properties;
    NSString    *whereClause;
    QueryOptions *queryOptions;    
}
@property (strong, nonatomic) NSArray *properties;
@property (strong, nonatomic) NSString *whereClause;
@property (strong, nonatomic) QueryOptions *queryOptions;
@property (strong, nonatomic) BackendlessCachePolicy *cachePolicy;

-(id)init:(NSArray *)_properties where:(NSString *)_whereClause query:(QueryOptions *)_queryOptions;
+(BackendlessDataQuery *)query;
+(BackendlessDataQuery *)query:(NSArray *)_properties where:(NSString *)_whereClause query:(QueryOptions *)_queryOptions;

@end
