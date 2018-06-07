//
//  GeoFenceMonitoring.m
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

#import "GeoFenceMonitoring.h"
#import "Backendless.h"
#import "DEBUG.h"
#import "GeoPoint.h"
#import "GeoFence.h"
#import "GeoMath.h"
#import "ICallback.h"

static NSString *GEOFENCE_OR_CALLBACK_IS_NOT_VALUED = @"The geofence %@ or callback %@ is not valued";
static NSString *GEOFENCE_ALREADY_MONITORING = @"The %@ geofence is already being monitored. Monitoring of the geofence must be stopped before you start it again";
static NSString *GEOFENCES_MONITORING = @"Cannot start geofence monitoring for all available geofences. There is another monitoring session in progress on the client-side. Make sure to stop all monitoring sessions before starting it for all available geo fences.";

@interface GeoFenceMonitoring ()

@property (strong, atomic) NSMutableArray *onStaySet;                // Set<GeoFence>
@property (strong, atomic) NSMutableDictionary *fencesToCallback;    // Map<GeoFence, ICallback>
@property (strong, atomic) NSMutableArray *pointFences;              // Set<GeoFence>
@property (strong, nonatomic) CLLocation *location;

@end

@implementation GeoFenceMonitoring

+(instancetype)sharedInstance {
    static GeoFenceMonitoring *sharedGeoFenceMonitoring;
    @synchronized(self) {
        if (!sharedGeoFenceMonitoring) {
            sharedGeoFenceMonitoring = [GeoFenceMonitoring new];
            [DebLog logN:@"CREATE GeoFenceMonitoring: sharedGeoFenceMonitoring = %@", sharedGeoFenceMonitoring];
        }
    }
    return sharedGeoFenceMonitoring;
}

-(id)init {
    if (self = [super init]) {
        self.onStaySet = [NSMutableArray array];
        self.fencesToCallback = [NSMutableDictionary dictionary];
        self.pointFences = [NSMutableArray array];
        _location = nil;
    }
    return self;
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC GeoFenceMonitoring"];
    [self.onStaySet removeAllObjects];
    [self.onStaySet release];
    [self.fencesToCallback removeAllObjects];
    [self.fencesToCallback release];
    [self.pointFences removeAllObjects];
    [self.pointFences release];
    [self.location release];
    [super dealloc];
}

-(void)onLocationChanged:(CLLocation *)location {
    @synchronized(self) {
        [DebLog log:@">>>>>>>>>>>>>>>>>>> GeoFenceMonitoring -> onLocationChanged: START >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"];
        self.location = location;
        GeoPoint *point = [GeoPoint geoPoint:(GEO_POINT){.latitude=location.coordinate.latitude, .longitude=location.coordinate.longitude}];
        NSMutableArray *oldFences = self.pointFences;
        NSArray *geoFences = [self.fencesToCallback allKeys];
        NSMutableArray *currFence = [self findGeoPointsFence:point geoFences:geoFences];
        NSMutableArray *newFences = [NSMutableArray arrayWithArray:currFence];
        [newFences removeObjectsInArray:oldFences];
        [oldFences removeObjectsInArray:currFence];
        [DebLog log:@"GeoFenceMonitoring -> onLocationChanged: %@\nnewFences: %@\noldFences: %@\ncurrFence: %@", location, newFences, oldFences, currFence];
        [self callOnEnter:newFences];
        [self callOnStay:newFences];
        [self callOnExit:oldFences];
        [self cancelOnStay:oldFences];
        self.pointFences = currFence;
        [DebLog log:@"<<<<<<<<<<<<<<<<<<<<<<<< GeoFenceMonitoring -> onLocationChanged: FINISH <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"];
     }
}

-(void)onLocationFailed:(NSError *)error {
    [DebLog logY:@"GeoFenceMonitoring -> onLocationFailed: %@", error];
}

-(NSString *)listenerName {
    return @"GeoFenceMonitoring";
}

-(Fault *)addGeoFences:(NSArray *)geoFences callback:(id <ICallback>)callback {
    if (!callback || !geoFences || !geoFences.count) {
        return [backendless throwFault:[Fault fault:[NSString stringWithFormat:GEOFENCE_OR_CALLBACK_IS_NOT_VALUED, geoFences, callback] faultCode:@"0000"]];
    }
    if (self.fencesToCallback.count) {
        return [backendless throwFault:[Fault fault:GEOFENCES_MONITORING faultCode:@"0000"]];
    }
    for (GeoFence *geoFence in geoFences) {
        [self addGeoFence:geoFence callback:callback];
    }
    return nil;
}

-(Fault *)addGeoFence:(GeoFence *)geoFence callback:(id <ICallback>)callback {
    //[DebLog log:@"GeoFenceMonitoring -> addGeoFence:\n%@", geoFence];
    if (!geoFence || !callback) {
        return [backendless throwFault:[Fault fault:[NSString stringWithFormat:GEOFENCE_OR_CALLBACK_IS_NOT_VALUED, geoFence, callback] faultCode:@"0000"]];
    }
    id <ICallback> _callback = [self.fencesToCallback objectForKey:geoFence];
    if (_callback && ![_callback equalCallbackParameter:callback]) {
        return [backendless throwFault:[Fault fault:[NSString stringWithFormat:GEOFENCE_ALREADY_MONITORING, geoFence.geofenceName] faultCode:@"0000"]];
    }
    if (![self isDefiniteRect:geoFence.nwPoint se:geoFence.sePoint]) {
        [self definiteRect:geoFence];
    }
    [self.fencesToCallback setObject:callback forKey:geoFence];
    if (_location && [self isPointInFence:[GeoPoint geoPoint:(GEO_POINT){.latitude=_location.coordinate.latitude, .longitude=_location.coordinate.latitude}] geoFence:geoFence]) {
        [self.pointFences addObject:geoFence];
        [callback callOnEnter:geoFence location:_location];
        [self addOnStay:geoFence];
    }
    return nil;
}

-(void)removeGeoFence:(NSString *)geoFenceName {
    NSArray *geoFences = [self.fencesToCallback allKeys];
    for (GeoFence *geoFence in geoFences) {
        if ([geoFence.geofenceName isEqualToString:geoFenceName ]) {
            [self.fencesToCallback removeObjectForKey:geoFence];
            [self cancelOnStayGeoFence:geoFence];
            [self.pointFences removeObject:geoFence];
        }
    }
}

-(void)removeGeoFences {
    [self.onStaySet removeAllObjects];
    [self.pointFences removeAllObjects];
    [self.fencesToCallback removeAllObjects];
}

-(BOOL)isMonitoring {
    return self.fencesToCallback.count > 0;
}

-(void)callOnEnter:(NSArray *)geoFences {
    for (GeoFence *geoFence in geoFences) {
        [(id <ICallback>)self.fencesToCallback[geoFence] callOnEnter:geoFence location:_location];
    }
}

-(void)callOnStay:(NSArray *)geoFences {
    for (GeoFence *geoFence in geoFences) {
        if ([geoFence valOnStayDuration] > 0)
            [self addOnStay:geoFence];
    }
}

-(void)cancelOnStay:(NSArray *)geoFences {
    for (GeoFence *geoFence in geoFences) {
        [self cancelOnStayGeoFence:geoFence];
    }
}

-(void)callOnExit:(NSArray *)geoFences {
    for (GeoFence *geoFence in geoFences) {
        [(id <ICallback>)self.fencesToCallback[geoFence] callOnExit:geoFence location:_location];
    }
}

-(NSMutableArray *)findGeoPointsFence:(GeoPoint *)geoPoint geoFences:(NSArray *)geoFences {
    NSMutableArray *fencePoints = [NSMutableArray array];
    for (GeoFence *geoFence in geoFences) {
        if ([self isPointInFence:geoPoint geoFence:geoFence]) {
            [fencePoints addObject:geoFence];
        }
    }
    return fencePoints;
}

-(BOOL)isPointInFence:(GeoPoint *)geoPoint geoFence:(GeoFence *)geoFence {
    if (![self isDefiniteRect:geoFence.nwPoint se:geoFence.sePoint]) {
        [self definiteRect:geoFence];
    }    
    [DebLog log:@"GeoFenceMonitoring -> isPointInFence: %@\n%@", geoPoint, geoFence];
    
    if ( ![GeoMath isPointInRectangular:geoPoint nw:geoFence.nwPoint se:geoFence.sePoint] ) {
        [DebLog log:@"isPointInRectangular = NO"];
        return NO;
    }
    switch (geoFence.valType) {
        case CIRCLE_FENCE: {
            GeoPoint *gp0 = geoFence.nodes[0];
            GeoPoint *gp1 = geoFence.nodes[1];
            double distance = [GeoMath distance:[gp0 valLatitude] lon1:[gp0 valLongitude] lat2:[gp1 valLatitude] lon2:[gp1 valLongitude]];
            BOOL result = [GeoMath isPointInCircle:geoPoint center:gp0 radius:distance];
            [DebLog log:@"isPointInCircle = %@", result?@"YES":@"NO"];
            return result;
        }
        case SHAPE_FENCE: {
            BOOL result = [GeoMath isPointInShape:geoPoint shape:geoFence.nodes];
            [DebLog log:@"isPointInShape = %@", result?@"YES":@"NO"];
            return result;
        }
        default: {
            [DebLog log:@"isPointInRectangular = YES"];
            return YES;
        }
    }
}

-(BOOL)isDefiniteRect:(GeoPoint *)nwPoint se:(GeoPoint *)sePoint {
    return (nwPoint != nil) && (sePoint != nil);
}

-(void)definiteRect:(GeoFence *)geoFence {
    switch ([geoFence valType]) {
        case RECT_FENCE:
        {
            GeoPoint *nwPoint = geoFence.nodes[0];
            GeoPoint *sePoint = geoFence.nodes[1];
            geoFence.nwPoint = nwPoint;
            geoFence.sePoint = sePoint;
            break;
        }
        case CIRCLE_FENCE:
        {
            GEO_RECTANGLE outRect = [GeoMath getOutRectangle:geoFence.nodes[0] bounded:geoFence.nodes[1]];
            geoFence.nwPoint = [GeoPoint geoPoint:(GEO_POINT){.latitude=outRect.northLat, .longitude=outRect.westLong}];
            geoFence.sePoint = [GeoPoint geoPoint:(GEO_POINT){.latitude=outRect.southLat, .longitude=outRect.eastLong}];
            break;
        }
        case SHAPE_FENCE:
        {
            GEO_RECTANGLE outRect = [GeoMath getOutRectangle:geoFence.nodes];
            geoFence.nwPoint = [GeoPoint geoPoint:(GEO_POINT){.latitude=outRect.northLat, .longitude=outRect.westLong}];
            geoFence.sePoint = [GeoPoint geoPoint:(GEO_POINT){.latitude=outRect.southLat, .longitude=outRect.eastLong}];
            break;
        }
        default:
            break;
    }
}

-(void)checkOnStay:(GeoFence *)geoFence {
    @synchronized(self) {
        [DebLog log:@"GeoFenceMonitoring -> checkOnStay:"];
        if ([self.onStaySet containsObject:geoFence]) {
            [(id <ICallback>)self.fencesToCallback[geoFence] callOnStay:geoFence location:_location];
            [self cancelOnStayGeoFence:geoFence];
        }
    }
}

-(void)addOnStay:(GeoFence *)geoFence {
    [self.onStaySet addObject:geoFence];
    [DebLog log:@"GeoFenceMonitoring -> addOnStay: geofence = %@, onStayDuration = %dsec", geoFence.geofenceName, geoFence.valOnStayDuration];
    dispatch_time_t interval = dispatch_time(DISPATCH_TIME_NOW, 1ull*NSEC_PER_SEC*geoFence.valOnStayDuration);
    dispatch_after(interval, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkOnStay:geoFence];
    });
}

-(void)cancelOnStayGeoFence:(GeoFence *)geoFence {
    [self.onStaySet removeObject:geoFence];
}

@end
