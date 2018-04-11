//
//  Presence.m
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

#import "Presence.h"
#import "Backendless.h"
#import "BeaconTracker.h"

@implementation Presence

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

// sync methods

-(void)stopMonitoring  {
    [[BeaconTracker sharedInstance] stopMonitoring];
}

// async methods with block-based callbacks

-(void)startMonitoring:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [[BeaconTracker sharedInstance] startMonitoring:BEACON_DEFAULT_DISCOVERY frequency:BEACON_DEFAULT_FREQUENCY listener:nil distanceChange:BEACON_DEFAUTL_DISTANCE_CHANGE responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)startMonitoring:(BOOL)runDiscovery response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [[BeaconTracker sharedInstance] startMonitoring:runDiscovery frequency:BEACON_DEFAULT_FREQUENCY listener:nil distanceChange:BEACON_DEFAUTL_DISTANCE_CHANGE responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)startMonitoring:(BOOL)runDiscovery frequency:(int)frequency response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
        [[BeaconTracker sharedInstance] startMonitoring:runDiscovery frequency:frequency listener:nil distanceChange:BEACON_DEFAUTL_DISTANCE_CHANGE responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)startMonitoring:(BOOL)runDiscovery frequency:(int)frequency listener:(id<IPresenceListener>)listener response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
        [[BeaconTracker sharedInstance] startMonitoring:runDiscovery frequency:frequency listener:listener distanceChange:BEACON_DEFAUTL_DISTANCE_CHANGE responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)startMonitoring:(BOOL)runDiscovery frequency:(int)frequency listener:(id<IPresenceListener>)listener distanceChange:(double)distanceChange response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [[BeaconTracker sharedInstance] startMonitoring:runDiscovery frequency:frequency listener:listener distanceChange:distanceChange responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}
#endif

@end
