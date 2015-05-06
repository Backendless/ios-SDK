//
//  LocationTracker.h
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
#import <CoreLocation/CoreLocation.h>

@protocol IBackendlessLocationListener <NSObject>
-(void)onLocationChanged:(CLLocation *)location;
@end

@interface LocationTracker : NSObject
@property(assign, nonatomic) BOOL pausesLocationUpdatesAutomatically;
@property(assign, nonatomic) CLLocationDistance distanceFilter;
@property(assign, nonatomic) CLLocationAccuracy desiredAccuracy;
@property(assign, nonatomic) CLActivityType activityType;

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(LocationTracker *)sharedInstance;

-(BOOL)isContainListener:(NSString *)name;
-(id <IBackendlessLocationListener>)findListener:(NSString *)name;
-(BOOL)addListener:(NSString *)name listener:(id <IBackendlessLocationListener>)listener;
-(BOOL)removeListener:(NSString *)name;

@end
