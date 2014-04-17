//
//  BEMapView.h
//  backendlessAPI
//
//  Created by Yury Yaschenko on 10/30/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import <MapKit/MapKit.h>

@class BackendlessCollection, Fault, BackendlessGeoQuery, GeoPoint;

@interface BEMapView : MKMapView
@property (nonatomic, strong) NSDictionary *metadata;
@property (nonatomic, copy) NSString *whereClause;

-(BOOL)addCategory:(NSString *)category;
-(BOOL)removeCategory:(NSString *)category;


-(BOOL)addGeopointIfNeed:(GeoPoint *)point;

-(void)update;

//-(void)getPoints:(BackendlessGeoQuery *)query;
//-(void)relativeFind:(BackendlessGeoQuery *)query;
//-(void)getPoints:(BackendlessGeoQuery *)query responder:(id)responder;
//-(void)relativeFind:(BackendlessGeoQuery *)query responder:(id)responder;
//-(void)getPoints:(BackendlessGeoQuery *)query response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
//-(void)relativeFind:(BackendlessGeoQuery *)query response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)setUnits:(int)units;
-(void)removeAllObjects;
-(NSArray *)responseData;

-(void)setSearchWithRadius:(float)radius;
-(void)setSearchInMapBoundaries;
@end
