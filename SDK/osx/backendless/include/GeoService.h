//
//  GeoService.h
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
#import "GeoCluster.h"
#import "Presence.h"

#define DEFAULT_CATEGORY_NAME @"Default"

typedef struct {
    GEO_POINT nordWest;
    GEO_POINT southEast;
} GEO_RECT;

@class GeoPoint, BackendlessGeoQuery, GeoCategory, Fault;
@protocol IGeofenceCallback;

@interface GeoService : NSObject

@property (strong, nonatomic, readonly) Presence *presence;

// sync methods with fault return (as exception)
-(GeoCategory *)addCategory:(NSString *)categoryName;
-(NSNumber *)deleteCategory:(NSString *)categoryName;
-(GeoPoint *)savePoint:(GeoPoint *)geoPoint;
-(NSArray<GeoCategory *> *)getCategories;
-(NSArray<GeoPoint *> *)getPoints:(BackendlessGeoQuery *)query;
-(NSArray<GeoPoint *> *)getClusterPoints:(GeoCluster *)geoCluster;
-(NSArray<GeoPoint *> *)getFencePoints:(NSString *)geoFenceName;
-(NSArray<GeoPoint *> *)getFencePoints:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query;
-(NSArray *)relativeFind:(BackendlessGeoQuery *)query;
-(id)removePoint:(GeoPoint *)geoPoint;
-(GeoPoint *)loadMetadata:(GeoPoint *)geoPoint;
-(NSNumber *)runOnEnterAction:(NSString *)geoFenceName;
-(NSNumber *)runOnEnterAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint;
-(NSNumber *)runOnStayAction:(NSString *)geoFenceName;
-(NSNumber *)runOnStayAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint;
-(NSNumber *)runOnExitAction:(NSString *)geoFenceName;
-(NSNumber *)runOnExitAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint;
-(NSNumber *)getGeopointCount:(BackendlessGeoQuery *)query;
-(NSNumber *)getGeopointCount:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query;

// async methods with block-based callbacks
-(void)addCategory:(NSString *)categoryName response:(void(^)(GeoCategory *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)deleteCategory:(NSString *)categoryName response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)savePoint:(GeoPoint *)geoPoint response:(void(^)(GeoPoint *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getCategories:(void(^)(NSArray<GeoCategory *> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getPoints:(BackendlessGeoQuery *)query response:(void(^)(NSArray<GeoPoint *> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getClusterPoints:(GeoCluster *)geoCluster response:(void(^)(NSArray<GeoPoint *> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getFencePoints:(NSString *)geoFenceName response:(void(^)(NSArray<GeoPoint *> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getFencePoints:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query response:(void(^)(NSArray<GeoPoint *> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)relativeFind:(BackendlessGeoQuery *)query response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removePoint:(GeoPoint *)geoPoint response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)loadMetadata:(GeoPoint *)geoPoint response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)runOnEnterAction:(NSString *)geoFenceName response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)runOnEnterAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)runOnStayAction:(NSString *)geoFenceName response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)runOnStayAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)runOnExitAction:(NSString *)geoFenceName response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)runOnExitAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getGeopointCount:(BackendlessGeoQuery *)query response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getGeopointCount:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;

// utilites
-(GEO_RECT)geoRectangle:(GEO_POINT)center length:(double)length width:(double)width;

// geo fence monitoring
-(void)startGeofenceMonitoringGeoPoint:(GeoPoint *)geoPoint response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)startGeofenceMonitoring:(id <IGeofenceCallback>)callback response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)startGeofenceMonitoringGeoPoint:(NSString *)geofenceName geoPoint:(GeoPoint *)geoPoint response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)startGeofenceMonitoring:(NSString *)geofenceName callback:(id <IGeofenceCallback>)callback response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock;
-(void)stopGeofenceMonitoring;
-(void)stopGeofenceMonitoring:(NSString *)geofenceName;

@end
