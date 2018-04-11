//
//  GeoMath.m
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

#import "GeoMath.h"
#import "GeoPoint.h"

typedef enum {
    ON_LINE, INTERSECT,
    NO_INTERSECT
} PointPosition;


@implementation GeoMath

static const double EARTH_RADIUS = 6378100.0; // meters

+(double)distance:(double)lat1 lon1:(double)lon1 lat2:(double)lat2 lon2:(double)lon2 {
    double deltaLon = lon1 - lon2;
    deltaLon = (deltaLon * M_PI) / 180;
    lat1 = (lat1 * M_PI) / 180;
    lat2 = (lat2 * M_PI) / 180;
    return EARTH_RADIUS * acos( sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(deltaLon) );
}

// for circle
+(GEO_RECTANGLE)getOutRectangle:(double)latitude lon:(double)longitude radius:(double)r {
    double boundLat = latitude + (180 * r) / (M_PI * EARTH_RADIUS) * (latitude > 0 ? 1 : -1);
    double littleRadius = [GeoMath countLittleRadius:boundLat];
    double westLong, eastLong, northLat, southLat;
    if (littleRadius > r) {
        westLong = longitude -(180 * r) / littleRadius;
        eastLong = 2 * longitude - westLong;
        westLong = [GeoMath updateDegree:westLong];
        eastLong = fmod(eastLong, 360) == 180 ? 180 : [GeoMath updateDegree:eastLong];
    }
    else {
        westLong = -180;
        eastLong = 180;
    }
    if(latitude > 0) {
        northLat = boundLat;
        southLat = 2 * latitude - boundLat;
    }
    else {
        southLat = boundLat;
        northLat = 2 * latitude - boundLat;
    }
    return  (GEO_RECTANGLE){.northLat=fmin( northLat, 90 ), .westLong=westLong, .southLat=fmax( southLat, -90 ), .eastLong=eastLong };
}

+(GEO_RECTANGLE)getOutRectangle:(GeoPoint *)center bounded:(GeoPoint *)bounded {
    return [GeoMath getOutRectangle:[center valLatitude] lon:[center valLongitude] radius:[GeoMath distance:[center valLatitude] lon1:[center valLongitude] lat2:[bounded valLatitude] lon2:[bounded valLongitude]]];
}

// for shape
+(GEO_RECTANGLE)getOutRectangle:(NSArray *)geoPoints {
    double nwLat = [(GeoPoint *)geoPoints[0] valLatitude];
    double nwLon = [(GeoPoint *)geoPoints[0] valLongitude];
    double seLat = [(GeoPoint *)geoPoints[0] valLatitude];
    double seLon = [(GeoPoint *)geoPoints[0] valLongitude];
    double minLon = 0, maxLon = 0, lon = 0;
    for (int i = 1; i < geoPoints.count; i++) {
        if ([(GeoPoint *)geoPoints[i] valLatitude] > nwLat) {
            nwLat = [(GeoPoint *)geoPoints[i] valLatitude];
        }
        if ([(GeoPoint *)geoPoints[i] valLatitude] < seLat) {
            seLat = [(GeoPoint *)geoPoints[i] valLatitude];
        }
        double deltaLon = [(GeoPoint *)geoPoints[i] valLongitude] - [(GeoPoint *)geoPoints[i - 1] valLongitude];
        if ((deltaLon < 0 && deltaLon > -180) || deltaLon > 270) {
            if (deltaLon > 270)
                deltaLon -= 360;
            lon += deltaLon;
            if (lon < minLon)
                minLon = lon;
        }
        else if ((deltaLon > 0 && deltaLon <= 180) || deltaLon <= -270) {
            if (deltaLon <= -270)
                deltaLon += 360;
            lon += deltaLon;
            if (lon > maxLon)
                maxLon = lon;
        }
    }
    nwLon += minLon;
    seLon += maxLon;
    if(seLon - nwLon >= 360) {
        seLon = 180;
        nwLon = -180;
    }
    else {
        seLon = [GeoMath updateDegree:seLon];
        nwLon = [GeoMath updateDegree:nwLon];
    }
    return  (GEO_RECTANGLE){.northLat=nwLat, .westLong=nwLon, .southLat=seLat, .eastLong=seLon };
}

+(double)updateDegree:(double)degree {
    degree += 180;
    while ( degree < 0 ) {
        degree += 360;
    }
    return degree == 0 ? 180 : fmod(degree, 360) - 180;
}

+(BOOL)isPointInCircle:(GeoPoint *)point center:(GeoPoint *)center radius:(double)radius {
    return [GeoMath distance:[point valLatitude] lon1:[point valLongitude] lat2:[center valLatitude] lon2:[center valLongitude]] <= radius;
}

+(BOOL)isPointInRectangular:(GeoPoint *)point nw:(GeoPoint *)nwPoint se:(GeoPoint *)sePoint {
    if ([point valLatitude] > [nwPoint valLatitude] || [point valLatitude] < [sePoint valLatitude]) {
        return NO;
    }
    if ([nwPoint valLongitude] > [sePoint valLongitude]) {
        return [point valLongitude] >= [nwPoint valLongitude] || [point valLongitude] <= [sePoint valLongitude];
    }
    else {
        return ([point valLongitude] >= [nwPoint valLongitude]) && ([point valLongitude] <= [sePoint valLongitude]);
    }
}

+(BOOL)isPointInShape:(GeoPoint *)point shape:(NSArray *)shape {
    long count = 0;
    for (long i = 0; i < shape.count; i++) {
        if ([GeoMath getPointPosition:point first:shape[i] second:shape[(i + 1) % shape.count]] == INTERSECT) {
            count++;
        }
    }
    return count % 2 == 1;
}

+(double)countLittleRadius:(double)latitude  {
    double h = fabs(latitude) / 180 * EARTH_RADIUS;
    double diametre = 2 * EARTH_RADIUS;
    double l_2 = (pow(diametre, 2) - diametre * sqrt( pow(diametre, 2) - 4 * pow(h, 2) )) / 2;
    return diametre / 2 - sqrt(l_2 - pow( h, 2 ));
}

+(PointPosition)getPointPosition:(GeoPoint *)point first:(GeoPoint *)first second:(GeoPoint *)second {
    double delta = [second valLongitude] - [first valLongitude];
    if ((delta < 0 && delta > -180) || delta > 180) {
        GeoPoint *tmp = first;
        first = second;
        second = tmp;
    }
    if (([point valLatitude] < [first valLatitude]) == ([point valLatitude] < [second valLatitude])) {
        return NO_INTERSECT;
    }
    double x = [point valLongitude] - [first valLongitude];
    if ((x < 0 && x > -180) || x > 180) {
        x = fmod(x - 360, 360);
    }
    double x2 = fmod([second valLongitude] - [first valLongitude] + 360, 360);
    double result = x2 * ([point valLatitude] - [first valLatitude]) / ([second valLatitude] - [first valLatitude]) - x;    
    return result > 0? INTERSECT : NO_INTERSECT;
}

@end
