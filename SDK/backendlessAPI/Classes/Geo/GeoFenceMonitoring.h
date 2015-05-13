//
//  GeoFenceMonitoring.h
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
#import "LocationTracker.h"

@protocol ICallback;
@class Fault, GeoFence;

@interface GeoFenceMonitoring : NSObject <ILocationTrackerListener>
// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(GeoFenceMonitoring *)sharedInstance;

-(NSString *)listenerName;
-(Fault *)addGeoFences:(NSArray *)geoFences callback:(id <ICallback>)callback;
-(Fault *)addGeoFence:(GeoFence *)geoFence callback:(id <ICallback>)callback;
-(void)removeGeoFence:(NSString *)geoFenceName;
-(void)removeGeoFences;
-(BOOL)isMonitoring;

@end
