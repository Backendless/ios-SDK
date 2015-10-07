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

@interface BeaconTracker() {
    NSMutableArray *_logMessages;
    int _numOfMessages;
    int _timeFrequency;
}
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
    }
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC BeaconTracker"];
    
    [super dealloc];
}

-(void)startMonitoring:(BOOL)runDiscovery frequency:(int)frequency listener:(id<IPresenceListener>)listener distanceChange:(double)distanceChange responder:(id<IResponder>)responder {
}

-(void)stopMonitoring {
    
}


@end
