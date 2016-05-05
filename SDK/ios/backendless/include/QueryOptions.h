//
//  QueryOptions.h
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

@interface QueryOptions : NSObject <NSCopying>

@property (strong, nonatomic) NSNumber *pageSize;
@property (strong, nonatomic) NSNumber *offset;
@property (strong, nonatomic) NSArray *sortBy;
@property (strong, nonatomic) NSMutableArray *related;
@property (strong, nonatomic) NSNumber *relationsDepth;

-(id)initWithPageSize:(int)_pageSize offset:(int)_offset;
+(id)query;
+(id)query:(int)_pageSize offset:(int)_offset;

-(QueryOptions *)pageSize:(int)_pageSize;
-(QueryOptions *)offset:(int)_offset;
-(QueryOptions *)sortBy:(NSArray *)_sortBy;
-(QueryOptions *)related:(NSArray *)_related;
-(NSDictionary *)getQuery;
-(BOOL)addRelated:(NSString *)_related;
-(BOOL)isEqualToQuery:(QueryOptions *)query;
@end
