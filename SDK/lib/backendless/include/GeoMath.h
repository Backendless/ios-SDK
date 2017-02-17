//
//  GeoMath.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2015 BACKENDLESS.COM. All Rights Reserved.
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

typedef struct {
    double northLat;
    double westLong;
    double southLat;
    double eastLong;
} GEO_RECTANGLE;

@class GeoPoint;

@interface GeoMath : NSObject
+(double)distance:(double)lat1 lon1:(double)lon1 lat2:(double)lat2 lon2:(double)lon2;
+(GEO_RECTANGLE)getOutRectangle:(double)latitude lon:(double)longitude radius:(double)r;
+(GEO_RECTANGLE)getOutRectangle:(GeoPoint *)center bounded:(GeoPoint *)bounded;
+(GEO_RECTANGLE)getOutRectangle:(NSArray *)geoPoints;
+(double)updateDegree:(double)degree;
+(BOOL)isPointInCircle:(GeoPoint *)point center:(GeoPoint *)center radius:(double)radius;
+(BOOL)isPointInRectangular:(GeoPoint *)point nw:(GeoPoint *)nwPoint se:(GeoPoint *)sePoint;
+(BOOL)isPointInShape:(GeoPoint *)point shape:(NSArray *)shape;
@end
