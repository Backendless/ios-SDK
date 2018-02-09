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
    
    [backendless.data mapColumnToProperty:[DeviceRegistration class] columnName:@"objectId" propertyName:@"id"];
    [backendless.data mapColumnToProperty:[DeviceRegistration class] columnName:@"operatingSystemName" propertyName:@"os"];
    [backendless.data mapColumnToProperty:[DeviceRegistration class] columnName:@"operatingSystemVersion" propertyName:@"osVersion"];
    
    NSMutableDictionary *typeProperties = ((AnonymousObject *)[type getCacheKey]).properties;
    NamedObject *body = [typeProperties valueForKey:@"body"];
    NSMutableDictionary *bodyProperties = ((AnonymousObject *)[body getCacheKey]).properties;
    NSString *channelName = [[bodyProperties valueForKey:@"channelName"] defaultAdapt];
    
    V3Message *v3 = (V3Message *)[type defaultAdapt];
    if (v3.isError) {
        ErrMessage *result = (ErrMessage *)v3;
        return [Fault fault:result.faultString detail:result.faultDetail faultCode:result.faultCode];
    }
    
    DeviceRegistration *deviceRegistration = v3.body.body;
    deviceRegistration.channels = [NSArray arrayWithObject:channelName];
    if ([deviceRegistration.expiration isKindOfClass:[NSNull class]]) {
        deviceRegistration.expiration = nil;
    }    
    return deviceRegistration;
}

@end
