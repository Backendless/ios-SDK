//
//  BeaconsInfo.m
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

#import "BeaconsInfo.h"
#import "Backendless.h"

@implementation BeaconsInfo

-(id)init:(BOOL)discovery beacons:(NSSet<BackendlessBeacon*> *)beacons {
    
    if ( (self=[super init]) ) {
        _discovery = discovery;
        _beacons = [beacons retain];
    }
    return self;
}

+(BeaconsInfo *)beaconsInfo:(BOOL)discovery beacons:(NSSet<BackendlessBeacon*> *)beacons {
    return [[BeaconsInfo alloc] init:discovery beacons:beacons];
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC BeaconsInfo"];
    
    [_beacons release];
    
    [super dealloc];
}

@end
