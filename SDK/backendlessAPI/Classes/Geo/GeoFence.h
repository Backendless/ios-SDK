//
//  GeoFence.h
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
#import <CoreLocation/CoreLocation.h>

typedef enum {
    CIRCLE_FENCE, RECT_FENCE, SHAPE_FENCE
} FenceType;

@class GeoPoint;

@interface GeoFence : NSObject <NSCopying>
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *geofenceName;
@property (strong, nonatomic) NSNumber *onStayDuration; // long
@property (strong, nonatomic) NSString *type;           // FenceType
@property (strong, nonatomic) NSMutableArray *nodes;    // List<GeoPoint>
@property (strong, nonatomic) GeoPoint *nwPoint;
@property (strong, nonatomic) GeoPoint *sePoint;

+(id)geoFence:(NSString *)geofenceName;

-(long)valOnStayDuration;
-(void)onStayDuration:(long)onStayDuration;
-(FenceType)valType;
-(void)type:(FenceType)type;
@end
