//
//  BeaconMonitoring.m
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

#import "BeaconMonitoring.h"
#import "Backendless.h"

/*
 
 private Set<BackendlessBeacon> monitoredBeacons = new HashSet<BackendlessBeacon>();
 private volatile boolean discovery = false;
 private Set<BackendlessBeacon> discoveryBeacons = Collections.synchronizedSet( new HashSet<BackendlessBeacon>() );
 
 public BeaconMonitoring( boolean runDiscovery, int timeFrequency )
 {
 this(runDiscovery, timeFrequency, null );
 }
 
 public BeaconMonitoring( boolean runDiscovery, int timeFrequency, Set<BackendlessBeacon> monitoredBeacons )
 {
 if(monitoredBeacons == null)
 receiveBeaconsInfo();
 
 this.discovery = runDiscovery;
 super.setTimeFrequency( timeFrequency );
 }
 */

@interface BeaconMonitoring() <IPresenceListener> {
    NSMutableSet<BackendlessBeacon*> *_discoveryBeacons;
    NSSet<BackendlessBeacon*> *_monitoredBeacons;
    BOOL _runDiscovery;
    int _timeFrequency;
}
@end

@implementation BeaconMonitoring

-(id)init {
    
    if ( (self=[super init]) ) {
        _runDiscovery = BEACON_DEFAULT_DISCOVERY;
        _timeFrequency = BEACON_DEFAULT_FREQUENCY;
        _discoveryBeacons = nil;
        _monitoredBeacons = nil;
        [self receiveBeaconsInfo];
    }
    return self;
}

-(id)init:(BOOL)runDiscovery timeFrequency:(int)timeFrequency {
    
    if ( (self=[super init]) ) {
        _runDiscovery = runDiscovery;
        _timeFrequency = timeFrequency;
        _discoveryBeacons = nil;
        _monitoredBeacons = nil;
        [self receiveBeaconsInfo];
    }
    return self;
}

-(id)init:(BOOL)runDiscovery timeFrequency:(int)timeFrequency monitoredBeacons:(NSSet<BackendlessBeacon*> *)monitoredBeacons {
    
    if ( (self=[super init]) ) {
        _runDiscovery = runDiscovery;
        _timeFrequency = timeFrequency;
        _discoveryBeacons = nil;
        if (!(_monitoredBeacons = monitoredBeacons)) {
            [self receiveBeaconsInfo];
        }
    }
    return self;
}

+(BeaconMonitoring *)beaconMonitoring:(BOOL)runDiscovery timeFrequency:(int)timeFrequency {
    return [[BeaconMonitoring alloc] init:runDiscovery timeFrequency:timeFrequency];
}

+(BeaconMonitoring *)beaconMonitoring:(BOOL)runDiscovery timeFrequency:(int)timeFrequency monitoredBeacons:(NSSet<BackendlessBeacon*> *)monitoredBeacons {
    return [[BeaconMonitoring alloc] init:runDiscovery timeFrequency:timeFrequency monitoredBeacons:monitoredBeacons];
}

-(void)receiveBeaconsInfo {
    
}

-(void)onDetectedBeacons:(NSDictionary<BackendlessBeacon*, NSNumber*> *)beaconToDistances {
    
}


@end
