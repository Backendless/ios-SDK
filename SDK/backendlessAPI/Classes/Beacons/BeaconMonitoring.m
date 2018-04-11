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
#import "BeaconsInfo.h"
#import "BeaconTracker.h"

@interface BeaconMonitoring() {
    BOOL _set;
    BOOL _discovery;
    int _timeFrequency;
}
@property (strong, nonatomic) NSMutableSet<BackendlessBeacon*> *discoveryBeacons;
@property (strong, nonatomic) NSSet<BackendlessBeacon*> *monitoredBeacons;
@end

@implementation BeaconMonitoring

-(id)init {
    if (self = [super init]) {
        _set = NO;
        _discovery = BEACON_DEFAULT_DISCOVERY;
        _timeFrequency = BEACON_DEFAULT_FREQUENCY;
        self.discoveryBeacons = [NSMutableSet new];
        self.monitoredBeacons = [NSSet new];
        [self flushBeacons];
    }
    return self;
}

-(id)init:(BOOL)runDiscovery timeFrequency:(int)timeFrequency {
    if (self = [super init]) {
        _set = NO;
        _discovery = runDiscovery;
        _timeFrequency = timeFrequency;
        self.discoveryBeacons = [NSMutableSet new];
        self.monitoredBeacons = [NSSet new];
        [self flushBeacons];
    }
    return self;
}

-(id)init:(BOOL)runDiscovery timeFrequency:(int)timeFrequency monitoredBeacons:(NSSet<BackendlessBeacon*> *)monitoredBeacons {
    if (self = [super init]) {
        _set = (BOOL)monitoredBeacons;
        _discovery = runDiscovery;
        _timeFrequency = timeFrequency;
        self.discoveryBeacons = [NSMutableSet new];
        self.monitoredBeacons = monitoredBeacons;
        [self flushBeacons];
    }
    return self;
}

+(BeaconMonitoring *)beaconMonitoring:(BOOL)runDiscovery timeFrequency:(int)timeFrequency {
    return [[BeaconMonitoring alloc] init:runDiscovery timeFrequency:timeFrequency];
}

+(BeaconMonitoring *)beaconMonitoring:(BOOL)runDiscovery timeFrequency:(int)timeFrequency monitoredBeacons:(NSSet<BackendlessBeacon*> *)monitoredBeacons {
    return [[BeaconMonitoring alloc] init:runDiscovery timeFrequency:timeFrequency monitoredBeacons:monitoredBeacons];
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC BeaconMonitoring"];
    [_discoveryBeacons release];
    [_monitoredBeacons release];
    [super dealloc];
}

-(void)flush {
    if (_discoveryBeacons.count) {
        [self sendBeacons:_discoveryBeacons];
        [_discoveryBeacons removeAllObjects];
    }
    if (!_set) {
        [self receiveBeaconsInfo];
    }
}

-(void)flushBeacons {
    [self flush];
    if (_timeFrequency <= 0)
        return;
    dispatch_time_t interval = dispatch_time(DISPATCH_TIME_NOW, 1ull*NSEC_PER_SEC*_timeFrequency);
    dispatch_after(interval, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self flushBeacons];
    });
}

-(NSSet<BackendlessBeacon*> *)getMonitoredBeacons {
    return _monitoredBeacons;
}

-(void)sendBeacons:(NSSet<BackendlessBeacon*> *)discoveredBeacons {
    [backendless.customService invoke:BEACON_SERVICE_NAME method:@"beacons" args:@[discoveredBeacons] responder:nil];
}

-(void)receiveBeaconsInfo {
    [backendless.customService
     invoke:BEACON_SERVICE_NAME
     method:@"getenabled"
     args:@[]
     response:^(BeaconsInfo *response) {
         self.monitoredBeacons = [NSSet setWithSet:response.beacons];
         _discovery = response.discovery;
     }
     error:^(Fault *fault) {
         [[backendless.logging getLoggerClass:BeaconTracker.class] error:[fault description]];
     }];
}

-(void)sendEntered:(BackendlessBeacon *)beacon distance:(double)distance  {
    NSArray *args = @[beacon.objectId?beacon.objectId:[NSNull null], @(distance)];
    [backendless.customService invoke:BEACON_SERVICE_NAME method:@"proximity" args:args responder:nil];
}

-(void)onDetectedBeacons:(NSDictionary<BackendlessBeacon*, NSNumber*> *)beaconToDistances {
    NSLog(@"onDetectedBeacons: %@ [%@]", beaconToDistances, _discovery?@"YES":@"NO");
    NSArray *keys = [beaconToDistances allKeys];
    for (BackendlessBeacon *beacon in keys) {
        if ([_monitoredBeacons member:beacon]) {
            NSLog(@"onDetectedBeacons: beacon.objectId = %@, distance = %@", beacon.objectId, beaconToDistances[beacon]);
            [self sendEntered:beacon distance:beaconToDistances[beacon].doubleValue];
        }        
        if (_discovery) {
            [_discoveryBeacons addObject:beacon];
        }
    }
}


@end
