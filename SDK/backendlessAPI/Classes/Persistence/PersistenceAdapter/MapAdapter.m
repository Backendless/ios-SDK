//
//  MapAdapter.m
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


#import "MapAdapter.h"
#import "IAdaptingType.h"
#import "AnonymousObject.h"
#import "NamedObject.h"
#import "ArrayType.h"
#import "V3Message.h"
#import "ErrMessage.h"
#import "Responder.h"

@implementation MapAdapter

-(id)adapt:(id)type {
    NSMutableDictionary *typeProperties = ((AnonymousObject *)[type getCacheKey]).properties;
    id body = [typeProperties valueForKey:@"body"];
        
        if ([body isKindOfClass:[NamedObject class]]) {
            return [body adapt:[NSDictionary class]];
        }
    
        else if ([body isKindOfClass:[ArrayType class]]) {
            NSMutableArray *result = [NSMutableArray new];
            NSArray *bodyObjects = [body getArray];
            for (NamedObject *namedObject in bodyObjects) {
                [result addObject:[namedObject adapt:[NSDictionary class]]];
            }
            return result;
        }
    
    return nil;
}

@end
