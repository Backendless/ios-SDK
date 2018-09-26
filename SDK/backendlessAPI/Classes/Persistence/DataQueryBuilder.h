//
//  DataQueryBuilder.h
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
#import "QueryOptionsBuilder.h"

@interface DataQueryBuilder : NSObject

-(instancetype)init;
-(BackendlessDataQuery *)build;
-(instancetype)setPageSize:(int)pageSize;
-(int)getPageSize;
-(instancetype)setOffset:(int)offset;
-(int)getOffset;
-(instancetype)prepareNextPage;
-(instancetype)preparePreviousPage;
-(NSMutableArray<NSString*> *)getProperties;
-(instancetype)setProperties:(NSArray<NSString*> *)properties;
-(instancetype)addProperty:(NSString *)property;
-(instancetype)addProperties:(NSArray<NSString *> *)properties;
-(NSString *)getWhereClause;
-(instancetype)setWhereClause:(NSString *)whereClause;
-(NSMutableArray<NSString *> *)getSortBy;
-(instancetype)setSortBy:(NSArray<NSString *> *)sortBy;
-(instancetype)addSortBy:(NSString *)sortBy;
-(instancetype)addListSortBy:(NSArray<NSString *> *)sortBy;
-(NSMutableArray<NSString *> *)getRelated;
-(instancetype)setRelated:(NSArray<NSString *> *)related;
-(instancetype)addRelated:(NSString *)related;
-(instancetype)addListRelated:(NSArray<NSString *> *)related;
-(NSNumber *)getRelationsDepth;
-(instancetype)setRelationsDepth:(int)relationsDepth;
-(instancetype)setGroupByProperties:(NSArray<NSString*> *)groupBy;
-(instancetype)addGroupByProperty:(NSString *)groupBy;
-(instancetype)addGroupByProperies:(NSArray<NSString *> *)groupBy;
-(instancetype)setHavingClause:(NSString *)havingClause;

@end
