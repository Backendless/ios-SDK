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

#import "LocationTracker.h"
#import "DEBUG.h"
#import "HashMap.h"

@interface LocationTracker () <CLLocationManagerDelegate> {
    CLLocationManager *_locationManager;
    HashMap *_locationListeners;
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    UIBackgroundTaskIdentifier _bgTask;
    float iOSVersion;
#endif
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
        
        _locationListeners = [HashMap new];
        
        _monitoringSignificantLocationChanges = YES;
        _distanceFilter = kCLDistanceFilterNone;
        _desiredAccuracy = kCLLocationAccuracyBest;

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        _activityType = CLActivityTypeOther;
        _pausesLocationUpdatesAutomatically = YES;
        
        _bgTask = UIBackgroundTaskInvalid;
        iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
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

#pragma mark -
#pragma mark setters

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

-(void)setActivityType:(CLActivityType)activityType {
    _activityType = activityType;
    _locationManager.activityType = activityType;
}

-(void)setPausesLocationUpdatesAutomatically:(BOOL)pausesLocationUpdatesAutomatically {
    _pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically;
    _locationManager.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically;
}

#endif

-(void)setMonitoringSignificantLocationChanges:(BOOL)monitoringSignificantLocationChanges {
    
    if (_monitoringSignificantLocationChanges == monitoringSignificantLocationChanges)
        return;
    
    _monitoringSignificantLocationChanges?[_locationManager stopMonitoringSignificantLocationChanges]:[_locationManager stopUpdatingLocation];
    _monitoringSignificantLocationChanges = monitoringSignificantLocationChanges;
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    if (iOSVersion >= 8.0) [_locationManager requestAlwaysAuthorization];
#endif
    _monitoringSignificantLocationChanges?[_locationManager startMonitoringSignificantLocationChanges]:[_locationManager startUpdatingLocation];
}

-(void)setDistanceFilter:(CLLocationDistance)distanceFilter {
    _distanceFilter = distanceFilter;
    _locationManager.distanceFilter = distanceFilter;
}

-(void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
    _desiredAccuracy = desiredAccuracy;
    _locationManager.desiredAccuracy = desiredAccuracy;
}

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

#pragma mark -
#pragma mark UIApplicationDelegate Methods

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // When there is a significant changes of the location, the key UIApplicationLaunchOptionsLocationKey will be returned from didFinishLaunchingWithOptions.
    // When the app is receiving the key, it must reinitiate the locationManager and get the latest location updates.
    // UIApplicationLaunchOptionsLocationKey key enables the location update even when the app has been killed/terminated (not in th background) by iOS or the user.
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        
        [DebLog log:@"LocationTracker -> application:%@ didFinishLaunchingWithOptions: UIApplicationLaunchOptionsLocationKey is - so app woke up from killed/terminated/suspended"];
        
        [self startLocationManager];
    }
    
    return YES;
}
#endif

#pragma mark -
#pragma mark Public Methods

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
-(BOOL)isBackgroundRefreshAvailable {
    return [[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable;
}

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

#pragma mark -
#pragma mark Private Methods

-(void)startLocationManager {
    
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = _distanceFilter;
    _locationManager.desiredAccuracy = _desiredAccuracy;

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    _locationManager.activityType = _activityType;
    _locationManager.pausesLocationUpdatesAutomatically = _pausesLocationUpdatesAutomatically;
    if (iOSVersion >= 8.0)
        [_locationManager requestAlwaysAuthorization];
#endif
    
    _monitoringSignificantLocationChanges?[_locationManager startMonitoringSignificantLocationChanges]:[_locationManager startUpdatingLocation];
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

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
-(void)makeBackgroundUpdateLocations:(CLLocation *)location {
    
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
        
        [self onLocationChanged:location];
        
        [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    });
}

-(void)makeBackgroundLocationFailed:(NSError *)error {
    
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
        
        [self onLocationFailed:error];
        
        [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    });
}

-(void)applicationDidEnterBackground {
    
    [DebLog log:@"LocationTracker -> applicationDidEnterBackground"];
    
    _monitoringSignificantLocationChanges?[_locationManager stopMonitoringSignificantLocationChanges]:[_locationManager stopUpdatingLocation];
    if (iOSVersion >= 8.0)
        [_locationManager requestAlwaysAuthorization];
    _monitoringSignificantLocationChanges?[_locationManager startMonitoringSignificantLocationChanges]:[_locationManager startUpdatingLocation];
}

-(void)applicationDidBecomeActive {
    
    [DebLog log:@"LocationTracker -> applicationDidBecomeActive"];
    
    _monitoringSignificantLocationChanges?[_locationManager stopMonitoringSignificantLocationChanges]:[_locationManager stopUpdatingLocation];
    [self startLocationManager];
}
#endif

-(NSString *)GUIDString {
    
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    
    return [(NSString *)string autorelease];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *location = [locations lastObject];
    [DebLog log:@"LocationTracker -> locationManager:didUpdateLocations: %@", location];
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)?[self makeBackgroundUpdateLocations:location]:[self makeForegroundUpdateLocations:location];
#else
[   self makeForegroundUpdateLocations:location];
#endif
}

-(void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error {
    
    [DebLog log:@"LocationTracker -> locationManager:didFailWithError: %@", error];
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)?[self makeBackgroundLocationFailed:(NSError *)error]:[self makeForegroundLocationFailed:error];
#else
    [self makeForegroundLocationFailed:error];
#endif
}

@end
