//
//  CustomServiceAdapter.m
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

#import "CustomServiceAdapter.h"
#import "AnonymousObject.h"
#import "NamedObject.h"
#import "Responder.h"
#import "ArrayType.h"
#import "AdapterFactory.h"
#import "DefaultAdapter.h"
#import "Backendless.h"

@implementation CustomServiceAdapter

-(id)adapt:(id)type {
    NSMutableDictionary *typeProperties = ((AnonymousObject *)[type getCacheKey]).properties;
    if ([typeProperties valueForKey:@"faultCode"] ||
        [typeProperties valueForKey:@"faultDetail"] ||
        [typeProperties valueForKey:@"faultString"]) {
        Fault *fault = [[Fault alloc] initWithMessage:[[typeProperties valueForKey:@"faultString"] defaultAdapt]
                                               detail:[[typeProperties valueForKey:@"faultDetail"] defaultAdapt]
                                            faultCode:[[typeProperties valueForKey:@"faultCode"] defaultAdapt]];
        return [backendless throwFault:fault];
    }
    else {
        id body = [typeProperties valueForKey:@"body"];
        if ([body isKindOfClass:[NamedObject class]]) {
            id<IResponseAdapter>adapter = [self adapterForBody:body];
            return [adapter adapt:body];
        }
        else if ([body isKindOfClass:[ArrayType class]]) {
            NSMutableArray *result = [NSMutableArray new];
            NSArray *bodyObjects = [body getArray];
            for (id bodyObject in bodyObjects) {
                id<IResponseAdapter>adapter = [self adapterForBody:bodyObject];
                [result addObject:[adapter adapt:bodyObject]];
            }
            return result;
        }
        else {
            id<IResponseAdapter>adapter = [self adapterForBody:body];
            return [adapter adapt:body];
        }
    }
    return nil;
}

-(id<IResponseAdapter>)adapterForBody:(id)body {
    if ([body isKindOfClass:[NamedObject class]]) {
        NSMutableDictionary *bodyProperties = ((AnonymousObject *)[body getCacheKey]).properties;
        NSString *class = [[bodyProperties valueForKey:@"___class"] defaultAdapt];
        return [[AdapterFactory new] adapterForClassName:class];
    }
    return [DefaultAdapter new];
}

@end
