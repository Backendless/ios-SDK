//
//  RTDataStore.m
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

#import "Backendless.h"
#import "RTDataStore.h"
#import "RTClient.h"
#import "RTListener+RTListenerMethods.h"
#import "RTSubscription.h"
#import "RTError.h"

#define CREATED @"created"
#define UPDATED @"updated"
#define DELETED @"deleted"

@interface RTDataStore() {
    NSString *table;
    Class entity;
    int dataStore;
}
@end

@implementation RTDataStore

-(RTDataStore *)initWithTableName:(NSString *)tableName withEntity:(Class)tableEntity dataStoreType:(UInt32)dataStoreType {
    if (self = [super init]) {
        table = tableName;
        entity = tableEntity;
        dataStore = dataStoreType;
    }
    return self;
}

-(void)addErrorListener:(void(^)(RTError *))onError {
    [super addSimpleListener:ERROR_TYPE callBack:onError];
}

-(void)removeErrorListener:(void(^)(RTError *))onError {
    [super removeSimpleListener:ERROR_TYPE callBack:[onError copy]];
}

-(void)removeErrorListener {
    [super removeSimpleListener:ERROR_TYPE];
}

-(void)addCreateListener:(void(^)(id))onCreate {
    [self subscribeForObjectChanges:CREATED tableName:table whereClause:nil onData:onCreate];
}

-(void)addCreateListener:(NSString *)whereClause onCreate:(void(^)(id))onCreate {
    [self subscribeForObjectChanges:CREATED tableName:table whereClause:whereClause onData:onCreate];
}

-(void)removeCreateListener:(NSString *)whereClause onCreate:(void(^)(id))onCreate {    
    [super stopSubscription:CREATED whereClause:whereClause onResult: onCreate];
}

-(void)removeCreateListenerWithCallback:(void(^)(id))onCreate {
    [super stopSubscription:CREATED whereClause:nil onResult:onCreate];
}

-(void)removeCreateListenerWithWhereClause:(NSString *)whereClause {
    [super stopSubscription:CREATED whereClause:whereClause onResult:nil];
}

-(void)removeCreateListener {
    [super stopSubscription:CREATED whereClause:nil onResult:nil];
}

-(void)addUpdateListener:(void(^)(id))onUpdate {
    [self subscribeForObjectChanges:UPDATED tableName:table whereClause:nil onData:onUpdate];
}

-(void)addUpdateListener:(NSString *)whereClause onUpdate:(void(^)(id))onUpdate {
    [self subscribeForObjectChanges:UPDATED tableName:table whereClause:whereClause onData:onUpdate];
}

-(void)removeUpdateListener:(NSString *)whereClause onUpdate:(void(^)(id))onUpdate {
    [super stopSubscription:UPDATED whereClause:whereClause onResult: onUpdate];
}

-(void)removeUpdateListenerWithCallback:(void(^)(id))onUpdate {
    [super stopSubscription:UPDATED whereClause:nil onResult:onUpdate];
}

-(void)removeUpdateListenerWithWhereClause:(NSString *)whereClause {
    [super stopSubscription:UPDATED whereClause:whereClause onResult:nil];
}

-(void)removeUpdateListener {
    [super stopSubscription:UPDATED whereClause:nil onResult:nil];
}

-(void)addDeleteListener:(void(^)(id))onDelete {
        [self subscribeForObjectChanges:DELETED tableName:table whereClause:nil onData:onDelete];
}

-(void)addDeleteListener:(NSString *)whereClause onDelete:(void(^)(id))onDelete {
    [self subscribeForObjectChanges:DELETED tableName:table whereClause:whereClause onData:onDelete];
}

-(void)removeDeleteListener:(NSString *)whereClause onDelete:(void(^)(id))onDelete {
    [super stopSubscription:DELETED whereClause:whereClause onResult: onDelete];
}

-(void)removeDeleteListenerWithCallback:(void(^)(id))onDelete {
    [super stopSubscription:DELETED whereClause:nil onResult:onDelete];
}

-(void)removeDeleteListenerWithWhereClause:(NSString *)whereClause {
    [super stopSubscription:DELETED whereClause:whereClause onResult:nil];
}

-(void)removeDeleteListener {
    [super stopSubscription:DELETED whereClause:nil onResult:nil];
}

-(void)removeAllListeners {
    [super stopSubscription:nil whereClause:nil onResult:nil];
}

// *********************************************

-(void)subscribeForObjectChanges:(NSString *)event tableName:(NSString *)tableName whereClause:(NSString *)whereClause onData:(void(^)(id))onChange {
    
    NSDictionary *options = @{@"tableName"  : tableName,
                              @"event"      : event};
    if (whereClause) {
        options = @{@"tableName"    : tableName,
                    @"event"        : event,
                    @"whereClause"  : whereClause};
    }
    
    //        void(^wrappedOnChanges)(NSDictionary *) = ^(NSDictionary *result) {
    //            if (dataStore == DATASTOREFACTORY) {
    //                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil];
    //                id resultObject = [self objectFromJSON:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    //                onChange(resultObject);
    //            }
    //            else if (dataStore == MAPDRIVENDATASTORE) {
    //                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil];
    //                NSDictionary *resultDictionary = [self dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    //                onChange(resultDictionary);
    //            }
    //        };
    
    [super addSubscription:OBJECTS_CHANGES_TYPE options:options onResult:onChange handleResultSelector:@selector(handleData:) fromClass:self];
};

-(id)handleData:(NSDictionary *)jsonResult {
    id result;
    if (dataStore == DATASTOREFACTORY) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
        result = [self objectFromJSON:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    }
    else if (dataStore == MAPDRIVENDATASTORE) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
        result = [self dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    }
    return result;
}

// *************************************************

-(id)objectFromJSON:(NSString *)JSONString {
    NSError *error;
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
    id object = [entity new];
    object = [self setObject:object valuesFromDictionary:JSONDictionary];
    return object;
}

-(id)setObject:(id)object valuesFromDictionary:(NSDictionary *) dictionary {
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
        if (![fieldName isEqualToString:@"___jsonclass"] && ![fieldName isEqualToString:@"__meta"] && ![fieldName isEqualToString:@"___class"]) {
            [dictionary setValue:[JSONDictionary valueForKey:fieldName] forKey:fieldName];
        }
    }
    return dictionary;
}

@end








