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

-(void)callOnEnter:(GeoFence *)geoFence location:(CLLocation *)location {
    [self updatePoint:location];
    [backendless.geoService runOnEnterAction:geoFence.geofenceName geoPoint:_geoPoint responder:_responder];
}

-(void)callOnStay:(GeoFence *)geoFence location:(CLLocation *)location {
    [self updatePoint:location];
    [backendless.geoService runOnStayAction:geoFence.geofenceName geoPoint:_geoPoint responder:_responder];
}

-(void)callOnExit:(GeoFence *)geoFence location:(CLLocation *)location {
    [self updatePoint:location];
    [backendless.geoService runOnExitAction:geoFence.geofenceName geoPoint:_geoPoint responder:_responder];
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

-(id)getError:(id)error {
    [DebLog log:@"ServerCallback -> getError: %@", error];
    return error;
}

@end
