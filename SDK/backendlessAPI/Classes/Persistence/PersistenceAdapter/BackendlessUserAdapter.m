//
//  DeviceRegistrationAdapter.h
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

#import "BackendlessUserAdapter.h"
#import "IAdaptingType.h"
#import "V3Message.h"
#import "ErrMessage.h"
#import "Responder.h"
#import "AnonymousObject.h"
#import "ArrayType.h"

@implementation BackendlessUserAdapter

-(id)adapt:(id)type {
    NSMutableDictionary *typeProperties = ((AnonymousObject *)[type getCacheKey]).properties;
    if ([typeProperties valueForKey:@"faultCode"] ||
        [typeProperties valueForKey:@"faultDetail"] ||
        [typeProperties valueForKey:@"faultString"]) {
        Fault *fault = [[Fault alloc] initWithMessage:[[typeProperties valueForKey:@"faultString"] defaultAdapt]
                                               detail:[[typeProperties valueForKey:@"faultDetail"] defaultAdapt]
                                            faultCode:[[typeProperties valueForKey:@"faultCode"] defaultAdapt]];
        return fault;
    }
    else {
        id body = [typeProperties valueForKey:@"body"];
        if ([body isKindOfClass:[NamedObject class]] ||
            [body isKindOfClass:[AnonymousObject class]]) {
            return [self adaptToBackendlessUser:body];
        }
        else if ([body isKindOfClass:[ArrayType class]]) {
            NSMutableArray *result = [NSMutableArray new];
            NSArray *bodyObjects = [body getArray];
            for (NamedObject *bodyObject in bodyObjects) {
                [result addObject:[self adaptToBackendlessUser:bodyObject]];
            }
            return result;
        }
    }
    return nil;
}

-(BackendlessUser *)adaptToBackendlessUser:(NamedObject *)body {
    BackendlessUser *user = [BackendlessUser new];
    NSMutableDictionary *bodyProperties = ((AnonymousObject *)[body getCacheKey]).properties;
    for (NSString *key in [bodyProperties allKeys]) {
        [user setProperty:key object:[[bodyProperties valueForKey:key] defaultAdapt]];
    }
    return user;
}

@end
