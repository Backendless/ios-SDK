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
#import "RTListener.h"
#import "RTSubscription.h"
#import "JSONHelper.h"

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

-(instancetype)initWithTableName:(NSString *)tableName withEntity:(Class)tableEntity dataStoreType:(UInt32)dataStoreType {
    if (self = [super init]) {
        table = tableName;
        entity = tableEntity;
        dataStore = dataStoreType;
    }
    return self;
}

-(void)addErrorListener:(void(^)(Fault *))onError {
    [super addSimpleListener:ERROR callBack:onError];
}

-(void)removeErrorListener:(void(^)(Fault *))onError {
    [super removeSimpleListener:ERROR callBack:onError];
}

-(void)removeErrorListener {
    [super removeSimpleListener:ERROR];
}

-(void)addCreateListener:(void(^)(id))onCreate {
    [self subscribeForObjectChanges:CREATED tableName:table whereClause:nil onData:onCreate];
}

-(void)addCreateListener:(NSString *)whereClause onCreate:(void(^)(id))onCreate {
    [self subscribeForObjectChanges:CREATED tableName:table whereClause:whereClause onData:onCreate];
}

-(void)removeCreateListener:(NSString *)whereClause onCreate:(void(^)(id))onCreate {
    [super stopSubscription:CREATED whereClause:whereClause onResult:onCreate];
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
    [super stopSubscription:UPDATED whereClause:whereClause onResult:onUpdate];
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
    [super stopSubscription:DELETED whereClause:whereClause onResult:onDelete];
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
    [self removeCreateListener];
    [self removeUpdateListener];
    [self removeDeleteListener];
    [self removeErrorListener];
}

-(void)subscribeForObjectChanges:(NSString *)event tableName:(NSString *)tableName whereClause:(NSString *)whereClause onData:(void(^)(id))onChange {
    NSDictionary *options = @{@"tableName"  : tableName,
                              @"event"      : event};
    if (whereClause) {
        options = @{@"tableName"    : tableName,
                    @"event"        : event,
                    @"whereClause"  : whereClause};
    }
    [super addSubscription:OBJECTS_CHANGES options:options onResult:onChange handleResultSelector:@selector(handleData:) fromClass:self];
};

-(id)handleData:(NSDictionary *)jsonResult {
    id result;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    if (dataStore == DATASTOREFACTORY) {
        result = [jsonHelper objectFromJSON:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] ofType:entity];
    }
    else if (dataStore == MAPDRIVENDATASTORE) {
        result = [jsonHelper dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    }
    return result;
}

@end








