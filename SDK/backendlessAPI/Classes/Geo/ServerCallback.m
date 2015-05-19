//
//  ServerCallback.m
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

#import "ServerCallback.h"
#import "DEBUG.h"
#import "Backendless.h"
#import "GeoPoint.h"
#import "GeoFence.h"


@interface ServerCallback ()
@property (strong, nonatomic) GeoPoint *geoPoint;
@end


@implementation ServerCallback

-(id)init {
    if ( (self=[super init]) ) {
        self.responder = [Responder responder:self selResponseHandler:@selector(getResponse:) selErrorHandler:@selector(getError:)];
        _geoPoint = nil;
    }
    return self;
}

-(id)init:(GeoPoint *)geoPoint {
    if ( (self=[super init]) ) {
        self.responder = [Responder responder:self selResponseHandler:@selector(getResponse:) selErrorHandler:@selector(getError:)];
        self.geoPoint = geoPoint;
    }
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC ServerCallback"];
    
    [_responder release];
    [_geoPoint release];
    
    [super dealloc];
}

+(id)callback:(GeoPoint *)geoPoint {
    return [[ServerCallback alloc] init:geoPoint];
}

#pragma mark -
#pragma mark ICallback Methods

#define _ASYNC_INVOKE_ 1

-(void)callOnEnter:(GeoFence *)geoFence location:(CLLocation *)location {
    [DebLog log:@"ServerCallback -> callOnEnter: geoFence = %@\ngeoPoint = %@", geoFence, _geoPoint];
    [self updatePoint:location];
#if _ASYNC_INVOKE_
    [backendless.geoService runOnEnterAction:geoFence.geofenceName geoPoint:_geoPoint responder:_responder];
#else
    @try {
        id response = [backendless.geoService runOnEnterAction:geoFence.geofenceName geoPoint:_geoPoint];
        [DebLog log:@"ServerCallback -> callOnEnter: RESPONSE = %@", response];
    }
    @catch (Fault *fault) {
        [DebLog log:@"ServerCallback -> callOnEnter: FAULT = %@", fault];
    }
#endif
}

-(void)callOnStay:(GeoFence *)geoFence location:(CLLocation *)location {
    [DebLog log:@"ServerCallback -> callOnStay: geoFence = %@\ngeoPoint = %@", geoFence, _geoPoint];
    [self updatePoint:location];
#if _ASYNC_INVOKE_
    [backendless.geoService runOnStayAction:geoFence.geofenceName geoPoint:_geoPoint responder:_responder];
#else
    @try {
        id response = [backendless.geoService runOnStayAction:geoFence.geofenceName geoPoint:_geoPoint];
        [DebLog log:@"ServerCallback -> callOnStay: RESPONSE = %@", response];
    }
    @catch (Fault *fault) {
        [DebLog log:@"ServerCallback -> callOnStay: FAULT = %@", fault];
    }
#endif
}

-(void)callOnExit:(GeoFence *)geoFence location:(CLLocation *)location {
    [DebLog log:@"ServerCallback -> callOnExit: geoFence = %@\ngeoPoint = %@", geoFence, _geoPoint];
    [self updatePoint:location];
#if _ASYNC_INVOKE_
    [backendless.geoService runOnExitAction:geoFence.geofenceName geoPoint:_geoPoint responder:_responder];
#else
    @try {
        id response = [backendless.geoService runOnExitAction:geoFence.geofenceName geoPoint:_geoPoint];
        [DebLog log:@"ServerCallback -> callOnExit: RESPONSE = %@", response];
    }
    @catch (Fault *fault) {
        [DebLog log:@"ServerCallback -> callOnExit: FAULT = %@", fault];
    }
#endif
}

-(BOOL)equalCallbackParameter:(id)object {
    
    if (![object isKindOfClass:GeoPoint.class]) {
        return NO;
    }
    
    GeoPoint *gp = (GeoPoint *)object;
    return [_geoPoint.metadata isEqualToDictionary:gp.metadata] && [_geoPoint.categories isEqualToArray:gp.categories];
}

#pragma mark -
#pragma mark Private Methods

-(void)updatePoint:(CLLocation *)location {
    [_geoPoint latitude:location.coordinate.latitude];
    [_geoPoint longitude:location.coordinate.longitude];
}

#pragma mark -
#pragma mark IResponder Methods

-(id)getResponse:(id)response {
    [DebLog log:@"ServerCallback -> getResponse: %@", response];
    return response;
}

-(id)getError:(Fault *)fault {
    [DebLog log:@"ServerCallback -> getError: (FAULT) %@", fault];
    return fault;
}

@end
