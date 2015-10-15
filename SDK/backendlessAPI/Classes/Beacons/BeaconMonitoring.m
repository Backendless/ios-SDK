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
    BOOL _set;
    BOOL _discovery;
    int _timeFrequency;
}
@property (strong, nonatomic) NSMutableSet<BackendlessBeacon*> *discoveryBeacons;
@property (strong, nonatomic) NSSet<BackendlessBeacon*> *monitoredBeacons;
@end

@implementation BeaconMonitoring

-(id)init {
    
    if ( (self=[super init]) ) {
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
    
    if ( (self=[super init]) ) {
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
    
    if ( (self=[super init]) ) {
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

#pragma mark -
#pragma mark Private Methods

/*
 
 @Override
 protected void calculate()
 {
 if( !discoveryBeacons.isEmpty() )
 {
 sendBeacons( new ArrayList<BackendlessBeacon>( discoveryBeacons ) );
 discoveryBeacons.clear();
 }
 
 receiveBeaconsInfo();
 }
 */

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

#pragma mark -
#pragma mark Public Methods

-(NSSet<BackendlessBeacon*> *)getMonitoredBeacons {
    return _monitoredBeacons;
}

/*
 
 public void sendBeacons( List<BackendlessBeacon> discoveredBeacons )
 {
 Backendless.CustomService.invoke( BeaconConstants.SERVICE_NAME, BeaconConstants.SERVICE_VERSION, "beacons", new Object[] { discoveredBeacons }, (AsyncCallback) null );
 }
 
 public void receiveBeaconsInfo()
 {
 Backendless.CustomService.invoke( BeaconConstants.SERVICE_NAME, BeaconConstants.SERVICE_VERSION, "getenabled", new Object[] { }, BeaconsInfo.class, new AsyncCallback<BeaconsInfo>()
 {
 @Override
 public void handleResponse( BeaconsInfo response )
 {
 writeLock.lock();
 monitoredBeacons = response.getBeacons();
 writeLock.unlock();
 
 discovery = response.isDiscovery();
 }
 
 @Override
 public void handleFault( BackendlessFault fault )
 {
 Backendless.Logging.getLogger( BeaconTracker.class ).error( fault.getCode() + " : " + fault.getMessage() );
 }
 } );
 }
 
 public void sendEntered( BackendlessBeacon beacon, double distance )
 {
 Backendless.CustomService.invoke( BeaconConstants.SERVICE_NAME, BeaconConstants.SERVICE_VERSION, "proximity", new Object[] { beacon.getObjectId(), distance }, (AsyncCallback) null );
 }
 */

-(void)sendBeacons:(NSSet<BackendlessBeacon*> *)discoveredBeacons {
    [backendless.customService invoke:BEACON_SERVICE_NAME serviceVersion:BEACON_SERVICE_VERSION method:@"beacons" args:@[discoveredBeacons] responder:nil];
}

-(void)receiveBeaconsInfo {
    [backendless.customService
     invoke:BEACON_SERVICE_NAME
     serviceVersion:BEACON_SERVICE_VERSION
     method:@"getenabled"
     args:@[]
     response:^(BeaconsInfo *response) {
         self.monitoredBeacons = response.beacons;
         _discovery = response.discovery;
     }
     error:^(Fault *fault) {
         [[backendless.logging getLoggerClass:BeaconTracker.class] error:[fault description]];
     }
     ];
}

-(void)sendEntered:(BackendlessBeacon *)beacon distance:(double)distance  {
    [backendless.customService invoke:BEACON_SERVICE_NAME serviceVersion:BEACON_SERVICE_VERSION method:@"proximity" args:@[beacon.objectId, @(distance)] responder:nil];
}

#pragma mark -
#pragma mark IPresenceListener Methods

/*
 
 @Override
 public void onDetectedBeacons( Map<BackendlessBeacon, Double> beaconToDistances )
 {
 for( BackendlessBeacon beacon : beaconToDistances.keySet() )
 {
 readLock.lock();
 boolean enubledBeacon = monitoredBeacons.contains( beacon );
 readLock.unlock();
 
 if( enubledBeacon )
 {
 sendEntered( beacon, beaconToDistances.get( beacon ) );
 }
 
 if( discovery )
 {
 discoveryBeacons.add( beacon );
 }
 }
 }
 */

-(void)onDetectedBeacons:(NSDictionary<BackendlessBeacon*, NSNumber*> *)beaconToDistances {
    
    NSArray *keys = [beaconToDistances allKeys];
    for (BackendlessBeacon *beacon in keys) {
        
        for (BackendlessBeacon *mB in _monitoredBeacons) {
            if ([beacon isEqual:mB]) {
                NSNumber *distance = beaconToDistances[beacon];
                [self sendEntered:beacon distance:[distance doubleValue]];
                break;
            }
        }
        
        if (_discovery) {
            [_discoveryBeacons addObject:beacon];
        }
    }
}


@end
