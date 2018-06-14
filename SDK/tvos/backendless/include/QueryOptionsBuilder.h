//
//  QueryOptionsBuilder.h
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
@class QueryOptions;

@protocol IQueryOptionsBuilder <NSObject>

-(NSMutableArray<NSString *> *)getSortBy;
-(id)setSortBy:(NSArray<NSString *> *)sortBy;
-(id)addSortBy:(NSString *)sortBy;
-(id)addListSortBy:(NSArray<NSString *> *)sortBy;
-(NSMutableArray<NSString *> *)getRelated;
-(id)setRelated:(NSArray<NSString *> *)related;
-(id)addRelated:(NSString *)related;
-(id)addListRelated:(NSArray<NSString *> *)related;
-(NSNumber *)getRelationsDepth;
-(id)setRelationsDepth:(int)relationsDepth;

@end

@interface QueryOptionsBuilder : NSObject <IQueryOptionsBuilder>

-(instancetype)init:(id)builder;
-(QueryOptions *)build;

@end
