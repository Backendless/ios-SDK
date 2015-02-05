//
//  ProtectedBackendlessGeoQuery.h
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
#import "BackendlessGeoQuery.h"

@interface ProtectedBackendlessGeoQuery : NSObject
-(id)initWithQuery:(BackendlessGeoQuery *)query;
+(id)protectedQuery:(BackendlessGeoQuery *)query;
-(BackendlessGeoQuery *)query;
-(void)pageSize:(int)pageSize;
-(void)offset:(int)offset;
-(double)latitude;
-(double)longitude;
-(double)radius;
-(UNITS)units;
-(NSArray *)categories;
-(BOOL)includeMeta;
-(NSDictionary *)metadata;
-(NSArray *)searchRectangle;
-(int)pageSize;
-(int)offset;
-(NSString *)whereClause;
-(NSDictionary *)relativeFindMetadata;
-(double)relativeFindPercentThreshold;
-(double)dpp;
-(int)clusterGridSize;
@end
