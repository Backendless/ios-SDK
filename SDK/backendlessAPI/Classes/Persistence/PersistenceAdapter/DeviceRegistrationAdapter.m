//
//  DeviceRegistrationAdapter.m
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

#import "DeviceRegistrationAdapter.h"
#import "Backendless.h"
#import "IAdaptingType.h"
#import "AnonymousObject.h"
#import "NamedObject.h"
#import "V3Message.h"
#import "ErrMessage.h"
#import "Responder.h"
#import "DeviceRegistration.h"
#import "ArrayType.h"

@implementation DeviceRegistrationAdapter

-(id)adapt:(id)type {
    V3Message *v3 = (V3Message *)[type defaultAdapt];
    if (v3.isError) {
        ErrMessage *result = (ErrMessage *)v3;
        return [Fault fault:result.faultString detail:result.faultDetail faultCode:result.faultCode];
    }
    NSMutableDictionary *typeProperties = ((AnonymousObject *)[type getCacheKey]).properties;
    id body = [typeProperties valueForKey:@"body"];    
    if ([body isKindOfClass:[NamedObject class]]) {
        return [self adaptToDeviceRegistration:body];
    }
    else if ([body isKindOfClass:[ArrayType class]]) {
        NSMutableArray *result = [NSMutableArray new];
        NSArray *bodyObjects = [body getArray];
        for (NamedObject *bodyObject in bodyObjects) {
            [result addObject:[self adaptToDeviceRegistration:bodyObject]];
        }
        return result;
    }
    return nil;
}

-(DeviceRegistration *)adaptToDeviceRegistration:(NamedObject *)body {
    DeviceRegistration *deviceRegistration = [DeviceRegistration new];
    NSMutableDictionary *bodyProperties = ((AnonymousObject *)[body getCacheKey]).properties;
    
    [bodyProperties removeObjectForKey:@"___class"];
    [bodyProperties removeObjectForKey:@"created"];
    [bodyProperties removeObjectForKey:@"ownerId"];
    [bodyProperties removeObjectForKey:@"updated"];
    
    for (NSString *property in [bodyProperties allKeys]) {
        if (![property isEqualToString:@"channelName"]) {
            [deviceRegistration setValue:[[bodyProperties valueForKey:property] defaultAdapt] forKey:property];
        }
    }
    NSString *channelName = [[bodyProperties valueForKey:@"channelName"] defaultAdapt];
    deviceRegistration.channels = [NSArray arrayWithObject:channelName];
    if ([deviceRegistration.expiration isKindOfClass:[NSNull class]]) {
        deviceRegistration.expiration = nil;
    }
    return deviceRegistration;
}

@end
