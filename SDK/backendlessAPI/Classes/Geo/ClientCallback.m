//
//  ClientCallback.m
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

#import "ClientCallback.h"
#import "DEBUG.h"
#import "GeoFence.h"

@interface ClientCallback ()
@end

@implementation ClientCallback

-(id)init {
    if ( (self=[super init]) ) {
        _geofenceCallback = nil;
    }
    return self;
}

-(id)init:(id <IGeofenceCallback>)geofenceCallback {
    if ( (self=[super init]) ) {
        self.geofenceCallback = geofenceCallback;
    }
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC ClientCallback"];
    
    [_geofenceCallback release];
    
    [super dealloc];
}

+(id)callback:(id <IGeofenceCallback>)geofenceCallback {
    return [[ClientCallback alloc] init:geofenceCallback];
}

#pragma mark -
#pragma mark ICallback Methods

#define _MAIN_THREAD_INVOKE_ 1

-(void)callOnEnter:(GeoFence *)geoFence location:(CLLocation *)location {
    [DebLog logN:@"ClientCallback -> callOnEnter: geoFence = %@\nlocation = %@", geoFence, location];
    if ([_geofenceCallback respondsToSelector:@selector(geoPointEntered:geofenceId:latitude:longitude:)]) {
#if _MAIN_THREAD_INVOKE_
        dispatch_async(dispatch_get_main_queue(), ^{
            [_geofenceCallback geoPointEntered:geoFence.geofenceName geofenceId:geoFence.objectId latitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        });
#else
        [_geofenceCallback geoPointEntered:geoFence.geofenceName geofenceId:geoFence.objectId latitude:location.coordinate.latitude longitude:location.coordinate.longitude];
#endif
    }
}

-(void)callOnStay:(GeoFence *)geoFence location:(CLLocation *)location {
    [DebLog logN:@"ClientCallback -> callOnStay: geoFence = %@\nlocation = %@", geoFence, location];
    if ([_geofenceCallback respondsToSelector:@selector(geoPointStayed:geofenceId:latitude:longitude:)]) {
#if _MAIN_THREAD_INVOKE_
        dispatch_async(dispatch_get_main_queue(), ^{
            [_geofenceCallback geoPointStayed:geoFence.geofenceName geofenceId:geoFence.objectId latitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        });
#else
        [_geofenceCallback geoPointStayed:geoFence.geofenceName geofenceId:geoFence.objectId latitude:location.coordinate.latitude longitude:location.coordinate.longitude];
#endif
    }
}

-(void)callOnExit:(GeoFence *)geoFence location:(CLLocation *)location {
    [DebLog logN:@"ClientCallback -> callOnExit: geoFence = %@\nlocation = %@", geoFence, location];
    if ([_geofenceCallback respondsToSelector:@selector(geoPointExited:geofenceId:latitude:longitude:)]) {
#if _MAIN_THREAD_INVOKE_
        dispatch_async(dispatch_get_main_queue(), ^{
            [_geofenceCallback geoPointExited:geoFence.geofenceName geofenceId:geoFence.objectId latitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        });
#else
        [_geofenceCallback geoPointExited:geoFence.geofenceName geofenceId:geoFence.objectId latitude:location.coordinate.latitude longitude:location.coordinate.longitude];
#endif
    }
}

-(BOOL)equalCallbackParameter:(id)object {
    return [_geofenceCallback isMemberOfClass:[(NSObject *)object class]] && [_geofenceCallback isEqual:object];
}

@end
