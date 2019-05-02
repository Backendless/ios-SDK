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

#import <Foundation/Foundation.h>
#import "PagedQueryBuilder.h"

@interface LoadRelationsQueryBuilder : NSObject

+(instancetype)ofMap;
+(instancetype)of:(Class)relationType;

-(BackendlessDataQuery *)build;
-(instancetype) setRelationName:(NSString*) relationName;
-(instancetype) setPageSize:(int)pageSize;
-(instancetype) setOffset:(int)offset;
-(instancetype) prepareNextPage;
-(instancetype) preparePreviousPage;
-(NSMutableArray<NSString*> *)getRelationType;

-(NSMutableArray<NSString*> *)getProperties;
-(instancetype)setProperties:(NSArray<NSString*> *)properties;
-(instancetype)addProperty:(NSString *)property;
-(instancetype)addProperties:(NSArray<NSString *> *)properties;

-(NSMutableArray<NSString *> *)getSortBy;
-(instancetype)setSortBy:(NSArray<NSString *> *)sortBy;
-(instancetype)addSortBy:(NSString *)sortBy;
-(instancetype)addListSortBy:(NSArray<NSString *> *)sortBy;

@end
