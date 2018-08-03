
//
//  EventHandler.m
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

#import "Backendless.h"
#import "EventHandler.h"
#import "RTClient.h"
#import "RTListener.h"
#import "RTSubscription.h"
#import "JSONHelper.h"

#define CREATED @"created"
#define UPDATED @"updated"
#define DELETED @"deleted"
#define BULK_CREATED @"bulk-created"
#define BULK_UPDATED @"bulk-updated"
#define BULK_DELETED @"bulk-deleted"

@interface EventHandler() {
    NSString *table;
    Class entity;
    int dataStore;
}
@end

@implementation EventHandler

-(instancetype)initWithTableName:(NSString *)tableName withEntity:(Class)tableEntity dataStoreType:(UInt32)dataStoreType {
    if (self = [super init]) {
        table = tableName;
        entity = tableEntity;
        dataStore = dataStoreType;
    }
    return self;
}

-(Class)getTableEntity {
    return entity;
}

-(UInt32)getType {
    return dataStore;
}

-(void)addCreateListener:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self subscribeForObjectChanges:CREATED tableName:table whereClause:nil response:responseBlock error:errorBlock];
}

-(void)addCreateListener:(NSString *)whereClause response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self subscribeForObjectChanges:CREATED tableName:table whereClause:whereClause response:responseBlock error:errorBlock];
}

-(void)removeCreateListeners:(NSString *)whereClause {
    [super stopSubscription:CREATED whereClause:whereClause];
}

-(void)removeCreateListeners {
    [super stopSubscription:CREATED whereClause:nil];
}

-(void)addUpdateListener:(void (^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self subscribeForObjectChanges:UPDATED tableName:table whereClause:nil response:responseBlock error:errorBlock];
}

-(void)addUpdateListener:(NSString *)whereClause response:(void(^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self subscribeForObjectChanges:UPDATED tableName:table whereClause:whereClause response:responseBlock error:errorBlock];
}

-(void)removeUpdateListeners:(NSString *)whereClause {
    [super stopSubscription:UPDATED whereClause:whereClause];
}

-(void)removeUpdateListeners {
    [super stopSubscription:UPDATED whereClause:nil];
}

-(void)addDeleteListener:(void(^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self subscribeForObjectChanges:DELETED tableName:table whereClause:nil response:responseBlock error:errorBlock];
}

-(void)addDeleteListener:(NSString *)whereClause response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self subscribeForObjectChanges:DELETED tableName:table whereClause:whereClause response:responseBlock error:errorBlock];
}

-(void)removeDeleteListeners:(NSString *)whereClause {
    [super stopSubscription:DELETED whereClause:whereClause];
}

-(void)removeDeleteListeners {
    [super stopSubscription:DELETED whereClause:nil];
}

-(void)addBulkCreateListener:(void(^)(NSArray<NSString *> *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self subscribeForObjectChanges:BULK_CREATED tableName:table whereClause:nil response:responseBlock error:errorBlock];
}

-(void)removeBulkCreateListeners {
    [super stopSubscription:BULK_CREATED whereClause:nil];
}

-(void)addBulkUpdateListener:(void(^)(BulkEvent *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self subscribeForObjectChanges:BULK_UPDATED tableName:table whereClause:nil response:responseBlock error:errorBlock];
}

-(void)addBulkUpdateListener:(NSString *)whereClause response:(void(^)(BulkEvent *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self subscribeForObjectChanges:BULK_UPDATED tableName:table whereClause:whereClause response:responseBlock error:errorBlock];
}

-(void)removeBulkUpdateListeners:(NSString *)whereClause {
    [super stopSubscription:BULK_UPDATED whereClause:whereClause];
}

-(void)removeBulkUpdateListeners {
    [super stopSubscription:BULK_UPDATED whereClause:nil];
}

-(void)addBulkDeleteListener:(void(^)(BulkEvent *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self subscribeForObjectChanges:BULK_DELETED tableName:table whereClause:nil response:responseBlock error:errorBlock];
}

-(void)addBulkDeleteListener:(NSString *)whereClause response:(void(^)(BulkEvent *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self subscribeForObjectChanges:BULK_DELETED tableName:table whereClause:whereClause response:responseBlock error:errorBlock];
}

-(void)removeBulkDeleteListeners:(NSString *)whereClause {
    [super stopSubscription:BULK_DELETED whereClause:whereClause];
}

-(void)removeBulkDeleteListeners {
   [super stopSubscription:BULK_DELETED whereClause:nil];
}

-(void)removeAllListeners {
    [self removeCreateListeners];
    [self removeUpdateListeners];
    [self removeDeleteListeners];
    [self removeBulkUpdateListeners];
    [self removeBulkDeleteListeners];
}

-(void)subscribeForObjectChanges:(NSString *)event tableName:(NSString *)tableName whereClause:(NSString *)whereClause response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    NSDictionary *options = @{@"tableName"  : tableName,
                              @"event"      : event};
    if (whereClause) {
        options = @{@"tableName"    : tableName,
                    @"event"        : event,
                    @"whereClause"  : whereClause};
    }
    
    if ([event isEqualToString:CREATED] || [event isEqualToString:UPDATED] || [event isEqualToString:DELETED]) {
        [super addSubscription:OBJECTS_CHANGES options:options onResult:responseBlock onError:errorBlock handleResultSelector:@selector(handleData:) fromClass:self];
    }
    else if ([event isEqualToString:BULK_CREATED]) {
        [super addSubscription:OBJECTS_CHANGES options:options onResult:responseBlock onError:errorBlock handleResultSelector:@selector(handleStringArray:) fromClass:self];
    }
    else if ([event isEqualToString:BULK_UPDATED]) {
        [super addSubscription:OBJECTS_CHANGES options:options onResult:responseBlock onError:errorBlock handleResultSelector:@selector(handleBulkEvent:) fromClass:self];
    }
    else if ([event isEqualToString:BULK_DELETED]) {
        [super addSubscription:OBJECTS_CHANGES options:options onResult:responseBlock onError:errorBlock handleResultSelector:@selector(handleBulkEvent:) fromClass:self];
    }
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

-(NSArray<NSString *> *)handleStringArray:(NSDictionary *)jsonResult {
    NSLog(@"Json result = %@", jsonResult);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *stringArrayEventDictionary = [jsonHelper dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    NSLog(@"%@", stringArrayEventDictionary);
    return @[@"aaa"];
}

-(BulkEvent *)handleBulkEvent:(NSDictionary *)jsonResult {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *bulkEventDictionary = [jsonHelper dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    BulkEvent *bulkEvent = [BulkEvent new];
    bulkEvent.whereClause = [bulkEventDictionary valueForKey:@"whereClause"];
    bulkEvent.count = [bulkEventDictionary valueForKey:@"count"];
    return bulkEvent;
}

@end
