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

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import "LocationTracker.h"
#import "DEBUG.h"
#import "HashMap.h"

#define IOS80_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IOS71_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.1)
#define IOS70_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

@interface LocationTracker () <CLLocationManagerDelegate> {
    CLLocationManager *_locationManager;
    HashMap *_locationListeners;
    UIBackgroundTaskIdentifier _bgTask;
}
@end

@implementation LocationTracker

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(LocationTracker *)sharedInstance {
    static LocationTracker *sharedLocationTracker;
    @synchronized(self)
    {
        if (!sharedLocationTracker)
            sharedLocationTracker = [LocationTracker new];
    }
    return sharedLocationTracker;
}

-(id)init {
    if ( (self=[super init]) ) {
        
        self.monitoringSignificantLocationChanges = YES;
        self.pausesLocationUpdatesAutomatically = YES;
        self.distanceFilter = kCLDistanceFilterNone;
        self.desiredAccuracy = kCLLocationAccuracyBest;
        self.activityType = CLActivityTypeOther;
        
        _locationManager = nil;
        _locationListeners = [HashMap new];
        _bgTask = UIBackgroundTaskInvalid;
    }
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC LocationTracker"];
    
    [_locationListeners release];    
    [_locationManager release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark setters

-(void)setMonitoringSignificantLocationChanges:(BOOL)monitoringSignificantLocationChanges {
    
    if (_locationManager && (_monitoringSignificantLocationChanges != monitoringSignificantLocationChanges)) {
        _monitoringSignificantLocationChanges?[_locationManager stopMonitoringSignificantLocationChanges]:[_locationManager stopUpdatingLocation];
        self.monitoringSignificantLocationChanges = monitoringSignificantLocationChanges;
        [self startLocationManager];
    }
    else {
        self.monitoringSignificantLocationChanges = monitoringSignificantLocationChanges;
    }
}

-(void)setPausesLocationUpdatesAutomatically:(BOOL)pausesLocationUpdatesAutomatically {
    self.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically;
    [_locationManager setPausesLocationUpdatesAutomatically:pausesLocationUpdatesAutomatically];
}

-(void)setDistanceFilter:(CLLocationDistance)distanceFilter {
    self.distanceFilter = distanceFilter;
    [_locationManager setDistanceFilter:distanceFilter];
}

-(void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
    self.desiredAccuracy = desiredAccuracy;
    [_locationManager setDesiredAccuracy:desiredAccuracy];
}

-(void)setActivityType:(CLActivityType)activityType {
    self.activityType = activityType;
    [_locationManager setActivityType:activityType];
}

#pragma mark -
#pragma mark Public Methods

-(BOOL)isBackgroundRefreshAvailable {
    return IOS70_OR_LATER && ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable);
}

-(BOOL)isSuspendedRefreshAvailable {
    return IOS71_OR_LATER && _monitoringSignificantLocationChanges;
}

-(BOOL)isContainListener:(NSString *)name {
    return [_locationListeners get:name] != nil;
}

-(id <ILocationTrackerListener>)findListener:(NSString *)name {
    return [_locationListeners get:name];
}

-(BOOL)addListener:(NSString *)name listener:(id <ILocationTrackerListener>)listener {
    return [_locationListeners add:name withObject:listener];
}

-(BOOL)removeListener:(NSString *)name {
    return [_locationListeners del:name];
}

#pragma mark -
#pragma mark Private Methods

-(void)startLocationManager {
    
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    _locationManager.pausesLocationUpdatesAutomatically = _pausesLocationUpdatesAutomatically;
    _locationManager.desiredAccuracy = _desiredAccuracy;
    _locationManager.activityType = _activityType;
    
    if (IOS80_OR_LATER) {
        [_locationManager requestAlwaysAuthorization];
    }
    
    _monitoringSignificantLocationChanges?[_locationManager startMonitoringSignificantLocationChanges]:[_locationManager startUpdatingLocation];
}

-(void)makeForegroundTask:(CLLocation *)location {
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *listeners = [_locationListeners values];
        for (id <ILocationTrackerListener> listener in listeners) {
            [listener onLocationChanged:location];
        }
    });
}

-(void)makeBackgroundTask:(CLLocation *)location {
    
    if (![self isBackgroundRefreshAvailable]) {
        return;
    }
    
    if (_bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
    }
    
    _bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        // stopped or ending the task outright.
        [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    }];
    
    if (_bgTask == UIBackgroundTaskInvalid) {
        return;
    }
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *listeners = [_locationListeners values];
        for (id <ILocationTrackerListener> listener in listeners) {
            [listener onLocationChanged:location];
        }
        
        [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    });
}

#pragma mark -
#pragma mark UIApplicationDelegate Methods

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [DebLog log:@"LocationTracker -> application:%@ didFinishLaunchingWithOptions:%@", application, launchOptions];
    
    // When there is a significant changes of the location, the key UIApplicationLaunchOptionsLocationKey will be returned from didFinishLaunchingWithOptions.
    // When the app is receiving the key, it must reinitiate the locationManager and get the latest location updates.
    // UIApplicationLaunchOptionsLocationKey key enables the location update even when the app has been killed/terminated (not in th background) by iOS or the user.
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        
        [DebLog log:@"LocationTracker -> application:%@ didFinishLaunchingWithOptions: UIApplicationLaunchOptionsLocationKey"];
        
        [self startLocationManager];
    }
    
    return YES;
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
    
    [DebLog log:@"LocationTracker -> applicationDidEnterBackground: %@", application];
    
    _monitoringSignificantLocationChanges?[_locationManager stopMonitoringSignificantLocationChanges]:[_locationManager stopUpdatingLocation];
    
    if (IOS80_OR_LATER) {
        [_locationManager requestAlwaysAuthorization];
    }
    _monitoringSignificantLocationChanges?[_locationManager startMonitoringSignificantLocationChanges]:[_locationManager startUpdatingLocation];
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    
    [DebLog log:@"LocationTracker -> applicationDidBecomeActive: %@", application];
    
    _monitoringSignificantLocationChanges?[_locationManager stopMonitoringSignificantLocationChanges]:[_locationManager stopUpdatingLocation];
    [self startLocationManager];
}


-(void)applicationWillTerminate:(UIApplication *)application{
    [DebLog log:@"LocationTracker -> applicationWillTerminate: %@", application];
}

#pragma mark -
#pragma mark UIApplicationDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *location = [locations lastObject];
    
    [DebLog log:@"LocationTracker -> locationManager:didUpdateLocations: %@", location];
    
    ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)?[self makeForegroundTask:location]:[self makeBackgroundTask:location];
}

@end
#endif
