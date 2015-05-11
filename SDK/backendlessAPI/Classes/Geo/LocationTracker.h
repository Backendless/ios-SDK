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

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol ILocationTrackerListener <NSObject>
-(void)onLocationChanged:(CLLocation *)location;
@end

@interface LocationTracker : NSObject <UIApplicationDelegate>
// location manager options
@property(assign, nonatomic) BOOL monitoringSignificantLocationChanges;
@property(assign, nonatomic) BOOL pausesLocationUpdatesAutomatically;
@property(assign, nonatomic) CLLocationDistance distanceFilter;
@property(assign, nonatomic) CLLocationAccuracy desiredAccuracy;
@property(assign, nonatomic) CLActivityType activityType;

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(LocationTracker *)sharedInstance;

-(BOOL)isBackgroundRefreshAvailable;
-(BOOL)isSuspendedRefreshAvailable;
-(BOOL)isContainListener:(NSString *)name;
-(id <ILocationTrackerListener>)findListener:(NSString *)name;
-(NSString *)addListener:(id <ILocationTrackerListener>)listener;
-(BOOL)addListener:(NSString *)name listener:(id <ILocationTrackerListener>)listener;
-(BOOL)removeListener:(NSString *)name;

@end
#endif
