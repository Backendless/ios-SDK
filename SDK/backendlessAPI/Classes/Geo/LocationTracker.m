//
//  LocationTracker.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "LocationTracker.h"
#import "DEBUG.h"
#import "HashMap.h"

@interface LocationTracker () <CLLocationManagerDelegate> {
    HashMap *_locationListeners;
}
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation LocationTracker

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(LocationTracker *)sharedInstance {
    static LocationTracker *sharedLocationTracker;
    @synchronized(self)
    {
        if (!sharedLocationTracker)
            sharedLocationTracker = [LocationTracker new];
    }
    return sharedLocationTracker;
}

-(id)init {
    if ( (self=[super init]) ) {
        
        self.pausesLocationUpdatesAutomatically = YES;
        self.distanceFilter = kCLDistanceFilterNone;
        self.desiredAccuracy = kCLLocationAccuracyBest;
        self.activityType = CLActivityTypeOther;
        
        _locationManager = nil;
        _locationListeners = [HashMap new];
        
    }
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC LocationTracker"];
    
    [_locationListeners release];    
    [_locationManager release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(BOOL)isContainListener:(NSString *)name {
    return [_locationListeners get:name] != nil;
}

-(id <IBackendlessLocationListener>)findListener:(NSString *)name {
    return [_locationListeners get:name];
}

-(BOOL)addListener:(NSString *)name listener:(id <IBackendlessLocationListener>)listener {
    return [_locationListeners add:name withObject:listener];
}

-(BOOL)removeListener:(NSString *)name {
    return [_locationListeners del:name];
}

@end
