//
//  DeviceRegistration.m
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

#import "DeviceRegistration.h"
#import "DEBUG.h"

@implementation DeviceRegistration
-(id)init {
	
    if (self = [super init]) {
        _id = nil;
        _deviceToken = nil;
        _deviceId = nil;
        _os = nil;
        _osVersion = nil;
        _expiration = nil;
        _channels = nil;
	}
	return self;
}

-(void)dealloc {
	[DebLog logN:@"DEALLOC DeviceRegistration"];
    [_id release];
    [_deviceToken release];
    [_deviceId release];
    [_os release];
    [_osVersion release];
    [_expiration release];
    [_channels release];
	[super dealloc];
}

-(BOOL)addChannel:(NSString *)channel {
    if (!channel) {
        return NO;
    }
    NSMutableArray *array = _channels ? [[NSMutableArray alloc] initWithArray:_channels] : [NSMutableArray new];
    [array addObject:channel];
    self.channels = array;    
    return YES;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<DeviceRegistration> id: %@, deviceToken: %@, deviceId: %@, os: %@, osVersion: %@, expiration: %@\nchannels: %@", _id, _deviceToken, _deviceId, _os, _osVersion, _expiration, _channels];
}

@end
