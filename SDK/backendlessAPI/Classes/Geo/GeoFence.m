//
//  GeoFence.m
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

#import "GeoFence.h"
#import "DEBUG.h"

@implementation GeoFence

static const char * const backendless_geo_fence_types[] = { "CIRCLE", "RECT", "SHAPE" };

+(id)geoFence:(NSString *)geofenceName {
    GeoFence *instance = [GeoFence new];
    instance.geofenceName = geofenceName;
    return instance;
}

-(long)valOnStayDuration {
    return [_onStayDuration longValue];
}

-(void)onStayDuration:(long)onStayDuration {
    self.onStayDuration = @(onStayDuration);
}

-(FenceType)valType {
    
    for (int i = 0; i < 3; i++) {
        if ([_type isEqualToString:[NSString stringWithUTF8String:backendless_geo_fence_types[i]]])
            return (FenceType)i;
    }
    return CIRCLE_FENCE;
}

-(void)type:(FenceType)type {
    self.type = [NSString stringWithUTF8String:backendless_geo_fence_types[(int)type]];
}

#pragma mark -
#pragma mark overwrided NSObject Methods

-(BOOL)isEqual:(id)object {
    
    [DebLog log:@"############# GeoFence -> isEqual: %@", object];
    
    if (!object || ![object isKindOfClass:self.class])
        return NO;
    
    return [_geofenceName isEqualToString:[(GeoFence *)object geofenceName]];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<GeoFence> geofenceName:%@, onStayDuration:%@, type:%@\nnwPoint:%@\nsePoint:%@", _geofenceName, _onStayDuration, _type, _nwPoint, _sePoint];
}

#pragma mark -
#pragma mark NSCopying Methods

-(id)copyWithZone:(NSZone *)zone {
    [DebLog log:@"############ GeoFence -> copyWithZone:", zone];
    return [self retain]; // TODO !!!
}

@end
