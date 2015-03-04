//
//  BEMapView.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2014 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import <MapKit/MapKit.h>

@class BackendlessCollection, Fault, BackendlessGeoQuery, GeoPoint, BEMapView;

@protocol BEMapViewDelegate <NSObject>
-(void)mapView:(BEMapView *)mapView didFinishLoadData:(NSArray *)data;
-(void)mapView:(BEMapView *)mapView didFinishWithFault:(Fault *)fault;
@end


@interface BEMapView : MKMapView
@property (nonatomic, strong) NSDictionary *metadata;
@property (nonatomic, copy) NSString *whereClause;
@property (nonatomic) BOOL includeMetadata;

-(BOOL)addCategory:(NSString *)category;
-(BOOL)removeCategory:(NSString *)category;
-(BOOL)addGeopointIfNeed:(GeoPoint *)point;
-(void)update;
-(void)setUnits:(int)units;
-(void)removeAllObjects;
-(void)removeGeoPointAnnotation:(NSString *)geopointId;
-(NSArray *)responseData;
-(void)setSearchWithRadius:(float)radius;
-(void)setSearchInMapBoundaries;
@end
