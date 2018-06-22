//
//  LocationTracker.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "LocationTracker.h"
#import "DEBUG.h"
#import "HashMap.h"

@interface LocationTracker () <CLLocationManagerDelegate> {
    CLLocationManager *_locationManager;
    HashMap *_locationListeners;
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
    float iOSVersion;
#endif
}
@end

@implementation LocationTracker

+(instancetype)sharedInstance {
    static LocationTracker *sharedLocationTracker;
    @synchronized(self) {
        if (!sharedLocationTracker) {
            sharedLocationTracker = [LocationTracker new];
            [DebLog log:@"CREATE LocationTracker: sharedLocationTracker = %@", sharedLocationTracker];
        }
    }
    return sharedLocationTracker;
}

-(id)init {
    if (self = [super init]) {
        _locationListeners = [HashMap new];
        _monitoringSignificantLocationChanges = YES;
        _distanceFilter = kCLDistanceFilterNone;
        _desiredAccuracy = kCLLocationAccuracyBest;
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
        _activityType = CLActivityTypeOther;
        _pausesLocationUpdatesAutomatically = YES;
#endif
        [self startLocationManager];
    }
    return self;
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC LocationTracker"];
    [_locationListeners release];
    [_locationManager release];
    [super dealloc];
}

#if (TARGET_OS_IPHONE || TARGET_OS_SIMULATOR) && !TARGET_OS_TV && !TARGET_OS_WATCH
-(void)setActivityType:(CLActivityType)activityType {
    _activityType = activityType;
    _locationManager.activityType = activityType;
}

-(void)setPausesLocationUpdatesAutomatically:(BOOL)pausesLocationUpdatesAutomatically {
    _pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically;
    _locationManager.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically;

}

-(void)setMonitoringSignificantLocationChanges:(BOOL)monitoringSignificantLocationChanges {
    if (_monitoringSignificantLocationChanges == monitoringSignificantLocationChanges)
        return;
    _monitoringSignificantLocationChanges?[_locationManager stopMonitoringSignificantLocationChanges]:[_locationManager stopUpdatingLocation];
    _monitoringSignificantLocationChanges = monitoringSignificantLocationChanges;
    if (iOSVersion >= 8.0) [_locationManager requestAlwaysAuthorization];
    _monitoringSignificantLocationChanges?[_locationManager startMonitoringSignificantLocationChanges]:[_locationManager startUpdatingLocation];
}
#endif

-(void)setDistanceFilter:(CLLocationDistance)distanceFilter {
    _distanceFilter = distanceFilter;
    _locationManager.distanceFilter = distanceFilter;
}

-(void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
    _desiredAccuracy = desiredAccuracy;
    _locationManager.desiredAccuracy = desiredAccuracy;
}

#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
-(BOOL)isSuspendedRefreshAvailable {
    return _monitoringSignificantLocationChanges && (iOSVersion >= 7.1);
}
#endif

-(BOOL)isContainListener:(NSString *)name {
    return [_locationListeners get:name] != nil;
}

-(id <ILocationTrackerListener>)findListener:(NSString *)name {
    return [_locationListeners get:name];
}

-(NSString *)addListener:(id <ILocationTrackerListener>)listener {
    NSString *GUID = [self GUIDString];
    return [self addListener:GUID listener:listener]?GUID:nil;
}

-(BOOL)addListener:(NSString *)name listener:(id <ILocationTrackerListener>)listener {
    return listener? [_locationListeners add:name?name:[self GUIDString] withObject:listener] : NO;
}

-(BOOL)removeListener:(NSString *)name {
    return [_locationListeners del:name];
}

-(void)startLocationManager {
#if !TARGET_OS_TV && !TARGET_OS_WATCH
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = _distanceFilter;
    _locationManager.desiredAccuracy = _desiredAccuracy;
    
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
    _locationManager.activityType = _activityType;
    _locationManager.pausesLocationUpdatesAutomatically = _pausesLocationUpdatesAutomatically;
    if (iOSVersion >= 8.0)
        [_locationManager requestAlwaysAuthorization];
#endif
    _monitoringSignificantLocationChanges?[_locationManager startMonitoringSignificantLocationChanges]:[_locationManager startUpdatingLocation];
#endif
}

-(CLLocation *)getLocation {
    return _locationManager.location;
}

-(void)onLocationChanged:(CLLocation *)location {
    NSArray *listeners = [_locationListeners values];
    for (id <ILocationTrackerListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(onLocationChanged:)]) {
            [listener onLocationChanged:location];
        }
    }
}

-(void)onLocationFailed:(NSError *)error {
    NSArray *listeners = [_locationListeners values];
    for (id <ILocationTrackerListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(onLocationFailed:)]) {
            [listener onLocationFailed:error];
        }
    }
}

-(void)makeForegroundUpdateLocations:(CLLocation *)location {
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self onLocationChanged:location];
    });
}

-(void)makeForegroundLocationFailed:(NSError *)error {
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self onLocationFailed:error];
    });
}

#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
-(void)makeBackgroundUpdateLocations:(CLLocation *)location {
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self onLocationChanged:location];
    });
}

-(void)makeBackgroundLocationFailed:(NSError *)error {
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self onLocationFailed:error];
    });
}
#endif

-(NSString *)GUIDString {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString *)string autorelease];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = [locations lastObject];
    [DebLog log:@"LocationTracker -> locationManager:didUpdateLocations: %@", location];
    [self makeForegroundUpdateLocations:location];
    
}

-(void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error {
    [DebLog log:@"LocationTracker -> locationManager:didFailWithError: %@", error];
    [self makeForegroundLocationFailed:error];
}

@end
