//
//  GeoPoint.h
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
#import "BackendlessEntity.h"

typedef struct {
    double latitude;
    double longitude;
} GEO_POINT;

@interface GeoPoint : NSObject

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic, readonly) NSNumber *latitude;
@property (strong, nonatomic, readonly) NSNumber *longitude;
@property (strong, nonatomic, readonly) NSNumber *distance;
@property (strong, nonatomic, readonly) NSMutableArray *categories;
@property (strong, nonatomic, readonly) NSMutableDictionary *metadata;

-(id)initWithPoint:(GEO_POINT)point;
-(id)initWithPoint:(GEO_POINT)point categories:(NSArray *)categories;
-(id)initWithPoint:(GEO_POINT)point categories:(NSArray *)categories metadata:(NSDictionary *)metadata;

+(id)geoPoint;
+(id)geoPoint:(GEO_POINT)point;
+(id)geoPoint:(GEO_POINT)point categories:(NSArray *)categories;
+(id)geoPoint:(GEO_POINT)point categories:(NSArray *)categories metadata:(NSDictionary *)metadata;

-(double)valLatitude;
-(void)latitude:(double)latitude;
-(double)valLongitude;
-(void)longitude:(double)longitude;
-(double)valDistance;
-(void)distance:(double)distance;
-(NSArray *)valCategories;
-(void)categories:(NSArray *)categories;
-(NSDictionary *)valMetadata;
-(void)metadata:(NSDictionary *)metadata;
//
-(BOOL)addCategory:(NSString *)category;
-(BOOL)addMetadata:(NSString *)key value:(id)value;
@end

@interface SearchMatchesResult : NSObject
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) GeoPoint *geoPoint;
@property (nonatomic, strong) NSNumber *matches;
@end
