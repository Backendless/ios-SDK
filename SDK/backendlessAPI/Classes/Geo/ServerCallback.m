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
#import "Invoker.h"
#import "GeoPoint.h"
#import "GeoFence.h"
#import "GeoService.h"


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
/*
 public class ServerCallback implements ICallback
 {
 private GeoPoint geoPoint;
 
 public ServerCallback( GeoPoint geoPoint )
 {
 this.geoPoint = geoPoint;
 }
 
 @Override
 public void callOnEnter( GeoFence geoFence, Location location )
 {
 updatePoint( location );
 onGeofenceServerCallback( "onEnterGeofence", geoFence.getObjectId(), geoPoint );
 }
 
 @Override
 public void callOnStay( GeoFence geoFence, Location location )
 {
 updatePoint( location );
 onGeofenceServerCallback( "onStayGeofence", geoFence.getObjectId(), geoPoint );
 }
 
 @Override
 public void callOnExit( GeoFence geoFence, Location location )
 {
 updatePoint( location );
 onGeofenceServerCallback( "onExitGeofence", geoFence.getObjectId(), geoPoint );
 }
 
 @Override
 public boolean equalCallbackParameter( Object object )
 {
 if(object.getClass() != GeoPoint.class)
 return false;
 return this.geoPoint.getMetadata().equals( ((GeoPoint)object).getMetadata() ) && this.geoPoint.getCategories().equals( ((GeoPoint)object).getCategories() );
 }
 */

#pragma mark -
#pragma mark ICallback Methods

-(void)callOnEnter:(GeoFence *)geoFence location:(CLLocation *)location {
    [self updatePoint:location];
    [self onGeofenceServerCallback:@"onEnterGeofence" geofenceId:geoFence.objectId geoPoint:_geoPoint];
}

-(void)callOnStay:(GeoFence *)geoFence location:(CLLocation *)location {
    [self updatePoint:location];
    [self onGeofenceServerCallback:@"onStayGeofence" geofenceId:geoFence.objectId geoPoint:_geoPoint];
}

-(void)callOnExit:(GeoFence *)geoFence location:(CLLocation *)location {
    [self updatePoint:location];
    [self onGeofenceServerCallback:@"onExitGeofence" geofenceId:geoFence.objectId geoPoint:_geoPoint];
}

-(BOOL)equalCallbackParameter:(id)object {
    
    if (![object isKindOfClass:GeoPoint.class]) {
        return NO;
    }
    
    GeoPoint *gp = (GeoPoint *)object;
    return [_geoPoint.metadata isEqualToDictionary:gp.metadata] && [_geoPoint.categories isEqualToArray:gp.categories];
}

/*
 
 private void updatePoint( Location location )
 {
 geoPoint.setLatitude( location.getLatitude() );
 geoPoint.setLongitude( location.getLongitude() );
 }
 
 private void onGeofenceServerCallback( String method, String geofenceId, GeoPoint geoPoint )
 {
 Invoker.invokeAsync( Geo.GEO_MANAGER_SERVER_ALIAS, method, new Object[] { Backendless.getApplicationId(), Backendless.getVersion(), geofenceId, geoPoint }, new AsyncCallback<Void>()
 {
 @Override
 public void handleResponse( Void v )
 {
 }
 
 @Override
 public void handleFault( BackendlessFault fault )
 {
 }
 } );
 }
 }
 */

#pragma mark -
#pragma mark Private Methods

-(void)updatePoint:(CLLocation *)location {
    [_geoPoint latitude:location.coordinate.latitude];
    [_geoPoint longitude:location.coordinate.longitude];
}

-(void)onGeofenceServerCallback:(NSString *)method geofenceId:(NSString *)geofenceId geoPoint:(GeoPoint *)geoPoint {
    NSArray *args = @[backendless.appID, backendless.versionNum, geofenceId, geoPoint];
    [invoker invokeAsync:[GeoService servicePath] method:method args:args responder:_responder];
}

#pragma mark -
#pragma mark Responder Methods

-(id)getResponse:(id)response {
    [DebLog log:@"ServerCallback -> getResponse: %@", response];
    return response;
}

-(id)getError:(id)error {
    [DebLog log:@"ServerCallback -> getError: %@", error];
    return error;
}

@end
