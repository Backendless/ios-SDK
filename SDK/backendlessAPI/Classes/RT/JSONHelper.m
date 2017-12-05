//
//  JSONHelper.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2017 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "JSONHelper.h"
#import "Backendless.h"
#import <objc/runtime.h>

@implementation JSONHelper

+(instancetype)sharedInstance {
    static JSONHelper *sharedJsonHelper;
    @synchronized(self) {
        if (!sharedJsonHelper)
            sharedJsonHelper = [[JSONHelper alloc] init];
    }
    return sharedJsonHelper;
}

-(id)objectFromJSON:(NSString *)JSONString ofType:(Class)objectType {
    NSError *error;
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
    id object = [objectType new];
    object = [self setObject:object valuesFromDictionary:JSONDictionary];
    return object;
}

-(id)setObject:(id)object valuesFromDictionary:(NSDictionary *)dictionary {
    [self prepareClass:[object class]];
    for (NSString *fieldName in dictionary) {
        if (![fieldName isEqualToString:@"___jsonclass"] && ![fieldName isEqualToString:@"__meta"] && ![fieldName isEqualToString:@"___class"]) {
            [object setValue:[dictionary objectForKey:fieldName] forKey:fieldName];
        }
    }
    return object;
}

-(void)prepareClass:(Class)class {
    [__types classInstance:class];
    [class resolveProperty:@"objectId"];
    [class resolveProperty:@"ownerId"];
    [class resolveProperty:@"created"];
    [class resolveProperty:@"updated"];
}

-(NSDictionary *)dictionaryFromJson:(NSString *)JSONString {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    NSError *error;
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
    for (NSString *fieldName in JSONDictionary) {
        if (![fieldName isEqualToString:@"___jsonclass"] && ![fieldName isEqualToString:@"__meta"]) {
            [dictionary setValue:[JSONDictionary valueForKey:fieldName] forKey:fieldName];
        }
    }
    return dictionary;
}

-(NSDictionary *)dictionaryWithPropertiesOfObject:(id)object {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([object class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        Class classObject = NSClassFromString([key capitalizedString]);
        if (classObject) {
            id subObject = [self dictionaryWithPropertiesOfObject:[object valueForKey:key]];
            [dictionary setObject:subObject forKey:key];
        }
        else {
            [dictionary setObject:NSStringFromClass([object class]) forKey:@"class"];
            id value = [object valueForKey:key];
            if (value) {
                [dictionary setObject:value forKey:key];
            }
            else {
                [dictionary setObject:[NSNull null] forKey:key];
            }
        }
    }
    free(properties);
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

-(id)parseObjectForJSON:(id)objectToParse {
    id resultObject = objectToParse;
    
    if (![objectToParse isKindOfClass:[NSString class]] && ![objectToParse isKindOfClass:[NSNumber class]] &&
        ![objectToParse isKindOfClass:[NSNull class]]) {
        
        if ([objectToParse isKindOfClass:[NSArray class]]) {
            NSMutableArray *resultArray = [NSMutableArray new];
            for (id object in objectToParse) {
                [resultArray addObject:[self parseObjectForJSON:object]];
            }
            resultObject = resultArray;
        }
        
        else if ([objectToParse isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *resultDictionary = [NSMutableDictionary new];
            for (NSString *key in [objectToParse allKeys]) {
                id value = [objectToParse valueForKey:key];
                
                if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                    [resultDictionary setObject:value forKey:key];
                }
                else {
                    [resultDictionary setObject:[self parseObjectForJSON:[objectToParse valueForKey:key]] forKey:key];
                }
            }
            resultObject = resultDictionary;
        }
        
        else {
            resultObject = [self dictionaryWithPropertiesOfObject:objectToParse];
        }
    }
    return resultObject;
}

-(id)parseBackObjectForJSON:(id)objectToParse {
    id resultObject = objectToParse;
    
    if ([objectToParse isKindOfClass:[NSArray class]]) {
        NSMutableArray *resultArray = [NSMutableArray new];
        for (id object in objectToParse) {
            [resultArray addObject:[self parseBackObjectForJSON:object]];
        }
        resultObject = resultArray;
    }
    
    else if ([objectToParse isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *resultDictionary = [NSMutableDictionary new];
        
        if ([[objectToParse allKeys] containsObject:@"class"]) {
            resultObject = [self objectFromDictionary:objectToParse];
        }
        else {
            for (NSString *key in [objectToParse allKeys]) {
                id value = [objectToParse valueForKey:key];
                if ([value isKindOfClass:[NSDictionary class]]) {
                    [resultDictionary setObject:[self parseBackObjectForJSON:value] forKey:key];
                }
                else {
                    [resultDictionary setObject:value forKey:key];
                }
                resultObject = resultDictionary;
            }
        }
    }
    
    else {
        resultObject = [self objectFromDictionary:objectToParse];
    }
    return resultObject;
}

-(id)objectFromDictionary:(NSDictionary *)dictionary {
    id object = dictionary;
    NSString *className = [dictionary valueForKey:@"class"];
    if (className) {
        object = [NSClassFromString(className) new];
        for (NSString *fieldName in dictionary) {
            if (![fieldName isEqualToString:@"class"]) {
                [object setValue:[dictionary objectForKey:fieldName] forKey:fieldName];
            }
        }
    }
    return object;
}

@end
