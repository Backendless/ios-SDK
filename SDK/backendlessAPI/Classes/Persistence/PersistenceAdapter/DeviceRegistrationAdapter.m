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
#import "NullType.h"

@implementation DeviceRegistrationAdapter

-(id)adapt:(id)type {
    
    V3Message *v3 = (V3Message *)[type defaultAdapt];
    if (v3.isError) {
        ErrMessage *result = (ErrMessage *)v3;
        return [Fault fault:result.faultString detail:result.faultDetail faultCode:result.faultCode];
    }
    
    [backendless.data mapColumnToProperty:[DeviceRegistration class] columnName:@"objectId" propertyName:@"id"];
    [backendless.data mapColumnToProperty:[DeviceRegistration class] columnName:@"operatingSystemName" propertyName:@"os"];
    [backendless.data mapColumnToProperty:[DeviceRegistration class] columnName:@"operatingSystemVersion" propertyName:@"osVersion"];
    
    NSMutableDictionary *typeProperties = ((AnonymousObject *)[type getCacheKey]).properties;
    for (NSString *key in typeProperties) {
        if ([[typeProperties valueForKey:key] isKindOfClass:[NamedObject class]]) {
            NamedObject *deviceRegistrationNamedObject = [typeProperties valueForKey:key];
            NSMutableDictionary *deviceRegistrationFields = [self mapFieldToProperty:deviceRegistrationNamedObject];
            DeviceRegistration *deviceRegistration = [DeviceRegistration new];
            for (NSString *field in deviceRegistrationFields) {
                id value = [deviceRegistrationFields valueForKey:field];                
                if ([value isKindOfClass:[NSArray class]]) {
                    NSMutableArray *channelsArray = [NSMutableArray new];
                    for (id arrayValue in value) {
                        [channelsArray addObject:[arrayValue defaultAdapt]];
                    }
                    [deviceRegistration setValue:channelsArray forKey:field];
                }
                else {
                    [deviceRegistration setValue:[[deviceRegistrationFields valueForKey:field] defaultAdapt] forKey:field];
                }
            }
            return deviceRegistration;
        }
    }
    return nil;
}

-(NSMutableDictionary *)mapFieldToProperty:(NamedObject *)namedObject {
    NSMutableDictionary *propertiesOfPropValue = ((AnonymousObject *)[namedObject getCacheKey]).properties;
    if ([[Types sharedInstance] getPropertiesMappingForClientClass:([namedObject getMappedType])]) {
        NSDictionary *mappedProperties = [[Types sharedInstance] getPropertiesMappingForClientClass:[namedObject getMappedType]];
        NSMutableDictionary *changedPropertiesOfPropValue = [NSMutableDictionary new];
        for (NSString *key in [propertiesOfPropValue allKeys]) {
            if ([key isEqualToString:@"channelName"]) {
                [changedPropertiesOfPropValue setObject:[NSArray arrayWithObject:[propertiesOfPropValue valueForKey:key]] forKey:@"channels"];
            }
            if ([[mappedProperties allKeys] containsObject:key]) {
                [changedPropertiesOfPropValue setObject:[propertiesOfPropValue valueForKey:key] forKey:[mappedProperties valueForKey:key]];
            }
            else {
                [changedPropertiesOfPropValue setObject:[propertiesOfPropValue valueForKey:key] forKey:key];
            }
        }
        if (changedPropertiesOfPropValue) {
            [changedPropertiesOfPropValue removeObjectForKey:@"___class"];
            [changedPropertiesOfPropValue removeObjectForKey:@"channelName"];
            [changedPropertiesOfPropValue removeObjectForKey:@"created"];
            [changedPropertiesOfPropValue removeObjectForKey:@"ownerId"];
            [changedPropertiesOfPropValue removeObjectForKey:@"updated"];
            return changedPropertiesOfPropValue;
        }
    }
    return propertiesOfPropValue;
}

@end
