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

@interface BeaconTracker() <CLLocationManagerDelegate> {
    id <IPresenceListener> _listener;
    BOOL _discovery;
    int _frequency;
    double _distanceChange;
}
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) BeaconMonitoring *beaconMonitor;
@property (strong, nonatomic) NSDictionary<BackendlessBeacon*, NSNumber*> *stayedBeacons;
@end

@implementation BeaconTracker

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
            NSUUID *proximityUUID = (NSUUID *)beacon.iBeaconProps[IBEACON_UUID_STR];
            CLBeaconMajorValue major = [(NSNumber *)beacon.iBeaconProps[IBEACON_MAJOR_STR] unsignedShortValue];
            CLBeaconMinorValue minor = [(NSNumber *)beacon.iBeaconProps[IBEACON_MINOR_STR] unsignedShortValue];
            return [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:major minor:minor identifier:beacon.objectId];
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
    CLBeaconRegion *beaconRegion = [self beaconRegion:beacon];
    [self.locationManager startMonitoringForRegion:beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:beaconRegion];
}

- (void)stopMonitoringBeacon:(BackendlessBeacon *)beacon {
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
    NSLog(@"Failed monitoring region: %@", error);
}
    
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed: %@", error);
}

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    /*
    for (CLBeacon *beacon in beacons) {
        for (RWTItem *item in self.items) {
            if ([item isEqualToCLBeacon:beacon]) {
                item.lastSeenBeacon = beacon;
            }
        }
    }
     */
}

#endif
/*
 
 @Override
 public void didRangeBeaconsInRegion( Collection<org.altbeacon.beacon.Beacon> collection, Region region )
 {
 
 Map<BackendlessBeacon, Double> notifiedBeacons = new HashMap<BackendlessBeacon, Double>();
 Map<BackendlessBeacon, Double> currentBeacons = new HashMap<BackendlessBeacon, Double>();
 for( org.altbeacon.beacon.Beacon beacon : collection )
 {
 BeaconType beaconType = BeaconType.ofServiceUUID( beacon.getServiceUuid() );
 BackendlessBeacon backendlessBeacon = new BackendlessBeacon( beaconType, beacon );
 double distance = beacon.getDistance();
 currentBeacons.put( backendlessBeacon, distance );
 
 if( !stayedBeacons.containsKey( backendlessBeacon ) )
 {
 notifiedBeacons.put( backendlessBeacon, beacon.getDistance() );
 }
 else
 {
 double prevDistance = stayedBeacons.get( backendlessBeacon );
 if( Math.abs( prevDistance - distance ) >= distanceChange )
 {
 notifiedBeacons.put( backendlessBeacon, distance );
 }
 }
 }
 stayedBeacons = currentBeacons;
 
 if( !notifiedBeacons.isEmpty() )
 {
 beaconMonitor.onDetectedBeacons( new HashMap<BackendlessBeacon, Double>( notifiedBeacons ) );
 
 if( listener != null )
 listener.onDetectedBeacons( new HashMap<BackendlessBeacon, Double>( notifiedBeacons ) );
 }
 }
 */

@end
