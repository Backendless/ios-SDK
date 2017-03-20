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

// Location Tracker invokes the ILocationTrackerListener methods from default global dispatch queue (DISPATCH_QUEUE_PRIORITY_DEFAULT) -
// so if the listener uses UI in its callbckacs, it MUST get the main dispatch queue.
@protocol ILocationTrackerListener <NSObject>
-(void)onLocationChanged:(CLLocation *)location;
-(void)onLocationFailed:(NSError *)error;
@end

@interface LocationTracker : NSObject

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
// location manager options
@property(assign, nonatomic) CLActivityType activityType;
@property(assign, nonatomic) BOOL pausesLocationUpdatesAutomatically;
-(BOOL)isSuspendedRefreshAvailable;
#endif

// location manager options
@property(assign, nonatomic) BOOL monitoringSignificantLocationChanges;
@property(assign, nonatomic) CLLocationDistance distanceFilter;
@property(assign, nonatomic) CLLocationAccuracy desiredAccuracy;

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(LocationTracker *)sharedInstance;

-(BOOL)isContainListener:(NSString *)name;
-(id <ILocationTrackerListener>)findListener:(NSString *)name;
-(NSString *)addListener:(id <ILocationTrackerListener>)listener;
-(BOOL)addListener:(NSString *)name listener:(id <ILocationTrackerListener>)listener;
-(BOOL)removeListener:(NSString *)name;

-(void)startLocationManager;
-(CLLocation *)getLocation;

@end
