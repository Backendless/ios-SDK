//
//  BeaconTracker.m
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

#import "BeaconTracker.h"
#import "Backendless.h"
#import "BeaconMonitoring.h"
#import "BeaconsInfo.h"

#define FAULT_PRESENCE_MONITORING [Fault fault:@"Presence is already monitoring" faultCode:@"4000"]
#define FAULT_INVALID_MONITORING_POLICY [Fault fault:@"Invalid monitoring policy" faultCode:@"4000"]

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

@interface BeaconTracker() <CLLocationManagerDelegate> {
    id <IPresenceListener> _listener;
    BOOL _discovery;
    int _frequency;
    double _distanceChange;
}
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) BeaconMonitoring *beaconMonitor;
@property (strong, nonatomic) NSDictionary<NSString*, NSNumber*> *stayedBeacons;
@end
#endif


@implementation BeaconTracker

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(BeaconTracker *)sharedInstance {
    static BeaconTracker *sharedBeaconTracker;
    @synchronized(self)
    {
        if (!sharedBeaconTracker) {
            sharedBeaconTracker = [BeaconTracker new];
            [DebLog log:@"CREATE BeaconTracker: sharedBeaconTracker = %@", sharedBeaconTracker];
        }
    }
    return sharedBeaconTracker;
}

-(id)init {
    if ( (self=[super init]) ) {
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        // Check for iOS 8
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        
        self.beaconMonitor = nil;
        self.stayedBeacons = [NSDictionary new];
    }
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC BeaconTracker"];
    
    [_locationManager release];
    [_beaconMonitor release];
    [_stayedBeacons release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark Private Methods

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

-(CLBeaconRegion *)beaconRegion:(BackendlessBeacon *)beacon {
    
    switch (beacon.type) {
        case BEACON_IBEACON: {
            NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:beacon.iBeaconProps[IBEACON_UUID_STR]];
            CLBeaconMajorValue major = [(NSString *)beacon.iBeaconProps[IBEACON_MAJOR_STR] intValue];
            CLBeaconMinorValue minor = [(NSString *)beacon.iBeaconProps[IBEACON_MINOR_STR] intValue];
            NSString *identifier = beacon.objectId?beacon.objectId:beacon.key;
            return [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:major minor:minor identifier:identifier];
        }
        case BEACON_EDDYSTONE: {
            return nil;
        }
        default: {
            return nil;
        }
    }
}

- (void)startMonitoringBeacon:(BackendlessBeacon *)beacon {
    NSLog(@"startMonitoringBeacon: %@", beacon);
    CLBeaconRegion *beaconRegion = [self beaconRegion:beacon];
    [self.locationManager startMonitoringForRegion:beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:beaconRegion];
}

- (void)stopMonitoringBeacon:(BackendlessBeacon *)beacon {
    NSLog(@"stopMonitoringBeacon: %@", beacon);
    CLBeaconRegion *beaconRegion = [self beaconRegion:beacon];
    [self.locationManager stopMonitoringForRegion:beaconRegion];
    [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
}
#endif

#pragma mark -
#pragma mark Public Methods

-(void)startMonitoring:(BOOL)runDiscovery frequency:(int)frequency listener:(id<IPresenceListener>)listener distanceChange:(double)distanceChange responder:(id<IResponder>)responder {
    
    if (_beaconMonitor)
        return [responder errorHandler:FAULT_PRESENCE_MONITORING];
    
    if (frequency < 0 || distanceChange < 0)
        return [responder errorHandler:FAULT_INVALID_MONITORING_POLICY];

    _discovery = runDiscovery;
    _frequency = frequency;
    _listener = listener;
    _distanceChange = distanceChange;

#if !BEACON_DEBUGGING
    [backendless.customService
     invoke:BEACON_SERVICE_NAME
     serviceVersion:BEACON_SERVICE_VERSION
     method:@"getenabled"
     args:@[]
     response:^(BeaconsInfo *response) {
         self.beaconMonitor = [BeaconMonitoring beaconMonitoring:_discovery timeFrequency:_frequency monitoredBeacons:response.beacons];
         
         for (BackendlessBeacon *beacon in response.beacons)
             [self startMonitoringBeacon:beacon];

         [responder responseHandler:nil];
     }
     error:^(Fault *fault) {
         [responder errorHandler:fault];
     }
     ];
#else
    BackendlessBeacon *beacon = [BackendlessBeacon new];
    self.beaconMonitor = [BeaconMonitoring beaconMonitoring:_discovery timeFrequency:_frequency monitoredBeacons:[NSSet setWithObject:beacon]];
    [self startMonitoringBeacon:beacon];
    [responder responseHandler:nil];
#endif
}

-(void)stopMonitoring {
    
    if (!_beaconMonitor)
        return;
    
    NSSet *beacons = [_beaconMonitor getMonitoredBeacons];
    for (BackendlessBeacon *beacon in beacons)
        [self stopMonitoringBeacon:beacon];
    
    [_beaconMonitor release];
    _beaconMonitor = nil;
    
}
    
#pragma mark - CLLocationManagerDelegate
    
-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    [DebLog log:@"Failed monitoring region: %@", error];
}
    
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [DebLog log:@"Location manager failed: %@", error];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    NSMutableDictionary<BackendlessBeacon*, NSNumber*> *notifiedBeacons = [NSMutableDictionary new];
    NSMutableDictionary<NSString*, NSNumber*> *currentBeacons = [NSMutableDictionary new];
    
    for (CLBeacon *beacon in beacons) {
        
        BackendlessBeacon *backendlessBeacon = [[BackendlessBeacon alloc] initWithClass:beacon];
        NSString *key = backendlessBeacon.key;
        double distance = beacon.accuracy;
        NSNumber *prevDistance = self.stayedBeacons[key];
        
        NSLog(@">>>> beacon: %@ [%f - %@]", beacon, distance, prevDistance);
        
        if (!prevDistance || fabs(distance - prevDistance.doubleValue) >= _distanceChange) {
            notifiedBeacons[backendlessBeacon] = @(distance);
            currentBeacons[key] = @(distance);
        }
        else {
            currentBeacons[key] = prevDistance;
        }
    }
    
    self.stayedBeacons = currentBeacons;
    
    if (notifiedBeacons.count) {
        [_beaconMonitor onDetectedBeacons:notifiedBeacons];
        [_listener onDetectedBeacons:notifiedBeacons];
    }
}

#endif

@end
