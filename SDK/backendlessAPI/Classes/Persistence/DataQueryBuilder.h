//
//  DataQueryBuilder.h
//  backendlessAPI
//
//  Created by Slava Vdovichenko on 11/10/16.
//  Copyright © 2016 BACKENDLESS.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PagedQueryBuilder.h"
#import "QueryOptionsBuilder.h"

@interface DataQueryBuilder : NSObject 

-(instancetype)init;
-(BackendlessDataQuery *)build;
-(instancetype)setPageSize:(int)pageSize;
-(instancetype)setOffset:(int)offset;
/**
 * Updates offset to point at next data page by adding pageSize.
 */
-(instancetype)prepareNextPage;
/**
 * Updates offset to point at previous data page by subtracting pageSize.
 */
-(instancetype)preparePreviousPage;
-(NSMutableArray<NSString*> *)getProperties;
-(instancetype)setProperties:(NSArray<NSString*> *)properties;
-(instancetype)addProperty:(NSString *)property ;
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
-(int)getRelationsDepth;
-(instancetype)setRelationsDepth:(int)relationsDepth;

@end
