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
#import "BackendlessUser.h"
#import "NamedObject.h"
#import "AnonymousObject.h"
#import "ArrayType.h"

@implementation BackendlessUserAdapter

-(id)adapt:(id)type {
    V3Message *v3 = (V3Message *)[type defaultAdapt];
    if (v3.isError) {
        ErrMessage *result = (ErrMessage *)v3;
        return [Fault fault:result.faultString detail:result.faultDetail faultCode:result.faultCode];
    }
    NSMutableDictionary *typeProperties = ((AnonymousObject *)[type getCacheKey]).properties;
    id body = [typeProperties valueForKey:@"body"];
    if ([body isKindOfClass:[NamedObject class]]) {
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
    return nil;
}

-(BackendlessUser *)adaptToBackendlessUser:(NamedObject *)body {
    BackendlessUser *user = [BackendlessUser new];
    NSMutableDictionary *bodyProperties = ((AnonymousObject *)[body getCacheKey]).properties;
    for (NSString *key in [bodyProperties allKeys]) {
        id value = [bodyProperties valueForKey:key];
        if (![value isEqual:[NSNull null]]) {
            [user setProperty:key object:value];
        }
        else {
            [user setProperty:key object:nil];
        }
    }
    return user;
}

@end
