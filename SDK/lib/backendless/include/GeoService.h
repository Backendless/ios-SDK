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

#define DEFAULT_CATEGORY_NAME @"Default"

typedef struct {
    GEO_POINT nordWest;
    GEO_POINT southEast;
} GEO_RECT;

@class GeoPoint, BackendlessCollection, BackendlessGeoQuery, GeoCategory, Fault;
@protocol IResponder;

@interface GeoService : NSObject

// sync methods
//deprecated
-(GeoCategory *)addCategory:(NSString *)categoryName;
-(id)deleteCategory:(NSString *)categoryName;
-(GeoPoint *)savePoint:(GeoPoint *)geoPoint;
-(NSArray *)getCategories;
-(BackendlessCollection *)getPoints:(BackendlessGeoQuery *)query;
-(BackendlessCollection *)relativeFind:(BackendlessGeoQuery *)query;
//new

-(GeoCategory *)addCategory:(NSString *)categoryName error:(Fault **)fault;
-(BOOL)deleteCategory:(NSString *)categoryName error:(Fault **)fault;
-(GeoPoint *)savePoint:(GeoPoint *)geoPoint error:(Fault **)fault;
-(NSArray *)getCategoriesError:(Fault **)fault;
-(BackendlessCollection *)getPoints:(BackendlessGeoQuery *)query error:(Fault **)fault;
-(BackendlessCollection *)relativeFind:(BackendlessGeoQuery *)query error:(Fault **)fault;

// async methods with responder
-(void)addCategory:(NSString *)categoryName responder:(id <IResponder>)responder;
-(void)deleteCategory:(NSString *)categoryName responder:(id <IResponder>)responder;
-(void)savePoint:(GeoPoint *)geoPoint responder:(id <IResponder>)responder;
-(void)getCategories:(id <IResponder>)responder;
-(void)getPoints:(BackendlessGeoQuery *)query responder:(id <IResponder>)responder;
-(void)relativeFind:(BackendlessGeoQuery *)query responder:(id<IResponder>)responder;

// async methods with block-base callbacks
-(void)addCategory:(NSString *)categoryName response:(void(^)(GeoCategory *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)deleteCategory:(NSString *)categoryName response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)savePoint:(GeoPoint *)geoPoint response:(void(^)(GeoPoint *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getCategories:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getPoints:(BackendlessGeoQuery *)query response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)relativeFind:(BackendlessGeoQuery *)query response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;

// utilites
-(GEO_RECT)geoRectangle:(GEO_POINT)center length:(double)length widht:(double)widht;

@end
