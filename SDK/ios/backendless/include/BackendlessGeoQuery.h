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

@interface BackendlessGeoQuery : NSObject <NSCopying>

@property (strong, nonatomic) NSNumber *latitude;                       // double
@property (strong, nonatomic) NSNumber *longitude;                      // double
@property (strong, nonatomic) NSNumber *radius;                         // double
@property (strong, nonatomic) NSString *units;
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) NSNumber *includeMeta;                    // BOOL
@property (strong, nonatomic) NSMutableDictionary *metadata;
@property (strong, nonatomic) NSArray *searchRectangle;
@property (strong, nonatomic) NSNumber *pageSize;                       // int
@property (strong, nonatomic) NSNumber *offset;                         // int
@property (strong, nonatomic) NSString *whereClause;
@property (strong, nonatomic) NSDictionary *relativeFindMetadata;
@property (strong, nonatomic) NSNumber *relativeFindPercentThreshold;   // double
@property (strong, nonatomic) NSNumber *dpp;                            // double - degree / pixels
@property (strong, nonatomic) NSNumber *clusterGridSize;                // int

-(id)initWithCategories:(NSArray *)categories;
-(id)initWithPoint:(GEO_POINT)point;
-(id)initWithPoint:(GEO_POINT)point pageSize:(int)pageSize offset:(int)offset;
-(id)initWithPoint:(GEO_POINT)point categories:(NSArray *)categories;
-(id)initWithPoint:(GEO_POINT)point radius:(double)radius units:(UNITS)units;
-(id)initWithPoint:(GEO_POINT)point radius:(double)radius units:(UNITS)units categories:(NSArray *)categories;
-(id)initWithPoint:(GEO_POINT)point radius:(double)radius units:(UNITS)units categories:(NSArray *)categories metadata:(NSDictionary *)metadata;
-(id)initWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast;
-(id)initWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast categories:(NSArray *)categories;

+(id)query;
+(id)queryWithCategories:(NSArray *)categories;
+(id)queryWithPoint:(GEO_POINT)point;
+(id)queryWithPoint:(GEO_POINT)point pageSize:(int)pageSize offset:(int)offset;
+(id)queryWithPoint:(GEO_POINT)point categories:(NSArray *)categories;
+(id)queryWithPoint:(GEO_POINT)point radius:(double)radius units:(UNITS)units;
+(id)queryWithPoint:(GEO_POINT)point radius:(double)radius units:(UNITS)units categories:(NSArray *)categories;
+(id)queryWithPoint:(GEO_POINT)point radius:(double)radius units:(UNITS)units categories:(NSArray *)categories metadata:(NSDictionary *)metadata;
+(id)queryWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast;
+(id)queryWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast categories:(NSArray *)categories;

-(double)valLatitude;
-(void)latitude:(double)latitude;
-(double)valLongitude;
-(void)longitude:(double)longitude;
-(double)valRadius;
-(void)radius:(double)radius;
-(UNITS)valUnits;
-(void)units:(UNITS)units;
-(NSArray *)valCategories;
-(void)categories:(NSArray *)categories;
-(BOOL)valIncludeMeta;
-(void)includeMeta:(BOOL)includeMeta;
-(NSDictionary *)valMetadata;
-(void)metadata:(NSDictionary *)metadata;
-(NSArray *)valSearchRectangle;
-(void)searchRectangle:(NSArray *)searchRectangle;
-(int)valPageSize;
-(void)pageSize:(int)pageSize;
-(int)valOffset;
-(void)offset:(int)offset;
-(double)valRelativeFindPercentThreshold;
-(void)relativeFindPercentThreshold:(double)percent;
-(double)valDpp;
-(void)dpp:(double)_pp;
-(int)valClusterGridSize;
-(void)clusterGridSize:(int)size;
//
-(void)searchRectangle:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast;
-(BOOL)addCategory:(NSString *)category;
-(BOOL)putMetadata:(NSString *)key value:(id)value;
-(BOOL)putRelativeFindMetadata:(NSString *)key value:(id)value;
-(void)setClusteringParams:(double)degreePerPixel clusterGridSize:(int)size;
-(void)setClusteringParams:(double)westLongitude eastLongitude:(double)eastLongitude mapWidth:(int)mapWidth;
-(void)setClusteringParams:(double)westLongitude eastLongitude:(double)eastLongitude mapWidth:(int)mapWidth clusterGridSize:(int)clusterGridSize;
@end
