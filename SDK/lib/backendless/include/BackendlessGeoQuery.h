//
//  BackendlessGeoQuery.h
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
#import "GeoPoint.h"

typedef enum {
    METERS,
    MILES,
    YARDS,
    KILOMETERS,
    FEET
} UNITS;

@interface BackendlessGeoQuery : NSObject {
    
    NSNumber            *latitude;          // double
    NSNumber            *longitude;         // double
    NSNumber            *radius;            // double
    NSString            *units;             // string
    NSMutableArray      *categories;
    NSNumber            *includeMeta;       // BOOL
    NSMutableDictionary *metadata;
    NSArray             *searchRectangle;
    NSNumber            *pageSize;          // int
    NSNumber            *offset;            // int
    NSString            *whereClause;       
}
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) NSNumber *radius;
@property (strong, nonatomic) NSString *units;
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) NSNumber *includeMeta;
@property (strong, nonatomic) NSMutableDictionary *metadata;
@property (strong, nonatomic) NSArray *searchRectangle;
@property (strong, nonatomic) NSNumber *pageSize;
@property (strong, nonatomic) NSNumber *offset;
@property (strong, nonatomic) NSString *whereClause;
@property (strong, nonatomic) NSDictionary *relativeFindMetadata;
@property (strong, nonatomic) NSNumber *relativeFindPercentThreshold;

-(id)initWithCategories:(NSArray *)_categories;
-(id)initWithPoint:(GEO_POINT)point;
-(id)initWithPoint:(GEO_POINT)point pageSize:(int)_pageSize offset:(int)_offset;
-(id)initWithPoint:(GEO_POINT)point categories:(NSArray *)_categories;
-(id)initWithPoint:(GEO_POINT)point radius:(double)_radius units:(UNITS)_units;
-(id)initWithPoint:(GEO_POINT)point radius:(double)_radius units:(UNITS)_units categories:(NSArray *)_categories;
-(id)initWithPoint:(GEO_POINT)point radius:(double)_radius units:(UNITS)_units categories:(NSArray *)_categories metadata:(NSDictionary *)_metadata;
-(id)initWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast;
-(id)initWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast categories:(NSArray *)_categories;

+(id)query;
+(id)queryWithCategories:(NSArray *)_categories;
+(id)queryWithPoint:(GEO_POINT)point;
+(id)queryWithPoint:(GEO_POINT)point pageSize:(int)_pageSize offset:(int)_offset;
+(id)queryWithPoint:(GEO_POINT)point categories:(NSArray *)_categories;
+(id)queryWithPoint:(GEO_POINT)point radius:(double)_radius units:(UNITS)_units;
+(id)queryWithPoint:(GEO_POINT)point radius:(double)_radius units:(UNITS)_units categories:(NSArray *)_categories;
+(id)queryWithPoint:(GEO_POINT)point radius:(double)_radius units:(UNITS)_units categories:(NSArray *)_categories metadata:(NSDictionary *)_metadata;
+(id)queryWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast;
+(id)queryWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast categories:(NSArray *)_categories;

-(BOOL)relativeFindPercentThreshold:(float)_percent;
-(float)valRelativeFindPercentThreshold;
-(double)valLatitude;
-(BOOL)latitude:(double)_latitude;
-(double)valLongitude;
-(BOOL)longitude:(double)_longitude;
-(double)valRadius;
-(BOOL)radius:(double)_radius;
-(UNITS)valUnits;
-(BOOL)units:(UNITS)_units;
-(NSArray *)valCategories;
-(BOOL)categories:(NSArray *)_categories;
-(BOOL)valIncludeMeta;
-(BOOL)includeMeta:(BOOL)_includeMeta;
-(NSDictionary *)valMetadata;
-(BOOL)metadata:(NSDictionary *)_metadata;
-(NSArray *)valSearchRectangle;
-(BOOL)searchRectangle:(NSArray *)_searchRectangle;
-(int)valPageSize;
-(BOOL)pageSize:(int)_pageSize;
-(int)valOffset;
-(BOOL)offset:(int)_offset;

-(BOOL)searchRectangle:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast;
-(BOOL)addCategory:(NSString *)category;
-(BOOL)addMetadata:(NSString *)key value:(NSString *)value;
-(NSString *)evaluation;
@end
