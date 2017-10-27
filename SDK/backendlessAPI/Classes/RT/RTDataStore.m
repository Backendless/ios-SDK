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
#import "RTSubscription.h"

#define OBJECTS_CHANGES @"OBJECTS_CHANGES"
#define CREATED @"created"
#define ERROR_TYPE @"ErrorType"

@interface RTDataStore() {
    NSMutableArray *errorCallbacks;
    NSMutableDictionary<NSString *, NSMutableArray<RTSubscription *> *> *subscriptions;
    void (^onError)(RTError *);
    void (^onStop)(NSString *);
    BOOL subscribed;
    NSString *table;
    Class entity;
    int dataStore;
}
@end

@implementation RTDataStore

-(RTDataStore *)initWithTableName:(NSString *)tableName withEntity:(Class)tableEntity dataStoreType:(UInt32)dataStoreType {
    if (self = [super init]) {
        errorCallbacks = [NSMutableArray new];
        subscriptions = [NSMutableDictionary<NSString*, NSMutableArray<RTSubscription *> *> new];
        subscribed = NO;
        table = tableName;
        entity = tableEntity;
        dataStore = dataStoreType;
    }
    return self;
}

-(void)addErrorListener:(void (^)(RTError *))onError {
    [rtClient connectSocket:^{
        [errorCallbacks addObject:[onError copy]];
    }];
}

-(void)addCreateListener:(void(^)(id))onCreate {
    [self subscribeForObjectChanges:nil event:CREATED tableName:table whereClause:nil onData:onCreate];
}

-(void)addCreateListener:(NSString *)whereClause onCreateCallback:(void (^)(id))onCreate {
    [self subscribeForObjectChanges:whereClause event:CREATED tableName:table whereClause:nil onData:onCreate];
}

-(void)subscribeForObjectChanges:(NSString *)subsId event:(NSString *)event tableName:(NSString *)tableName whereClause:(NSString *)whereClause onData:(void(^)(id))onData {
    
    __block NSString *subId = subsId;
    
    [rtClient connectSocket:^{
        if (!subId) {
            subId = [[NSUUID UUID] UUIDString];
        }
        NSDictionary *options = @{@"tableName"  : tableName,
                                  @"event"      : event};
        if (whereClause) {
            options = @{@"tableName"    : tableName,
                        @"event"        : event,
                        @"whereClause"  : whereClause};
            
        }
        NSDictionary *data = @{@"id"        : subId,
                               @"name"      : OBJECTS_CHANGES,
                               @"options"   : options};
        
        __weak NSMutableArray *weakErrorCallbacks = errorCallbacks;
        __weak NSMutableDictionary<NSString *, NSMutableArray<RTSubscription *> *> *weakSubscriptions = subscriptions;
        
        onError = ^(RTError *error) {
            for (int i = 0; i < [errorCallbacks count]; i++) {
                void (^errorBlock)(RTError *) = [weakErrorCallbacks objectAtIndex:i];
                errorBlock(error);
            }
        };
        
        onStop = ^(NSString *subId) {
            [rtClient.socket emit:@"SUB_OFF" with:[NSArray arrayWithObject:subId]];
            [rtClient.subscriptions removeObjectForKey:subId];
            
            for (NSMutableSet *subscriptionsSet in [weakSubscriptions allValues]) {
                for (RTSubscription *subscription in subscriptionsSet) {
                    if ([[subscription.data valueForKey:@"id"] isEqualToString:subId]) {
                        [subscriptionsSet removeObject:subscription];
                    }
                }
            }
        };
        
        RTSubscription *subscription = [RTSubscription new];
        subscription.data = data;
        subscription.onData = onData;
        subscription.onError = onError;
        subscription.onStop = onStop;
        
        NSMutableArray *subscriptionSet = [NSMutableArray arrayWithArray:[subscriptions valueForKey:event]];
        [subscriptionSet addObject:subscription];
        
        [rtClient.subscriptions setObject:subscription forKey:subId];
        
        if (!subscribed) {
            [self onObjectChangesHandler];
        }
        [rtClient.socket emit:@"SUB_ON" with:[NSArray arrayWithObject:data]];
    }];
}

-(void)onObjectChangesHandler {
    subscribed = YES;
    [rtClient.socket on:@"SUB_RES" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSDictionary *resultData = data.firstObject;
        NSString *subId = [resultData valueForKey:@"id"];
        
        if ([resultData valueForKey:@"result"]) {
            NSDictionary *result = [resultData valueForKey:@"result"];
            id callbackResult;
            void (^callback)(id) = ((RTSubscription *)[rtClient.subscriptions valueForKey:subId]).onData;
            if (callback) {
                
                if (dataStore == DATASTOREFACTORY) {
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil];
                    callbackResult = [self objectFromJSON:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
                }                
                
                else if (dataStore == MAPDRIVENDATASTORE) {
                    NSLog(@"MAP DRIVEN DS");
                }
                callback(callbackResult);
            }            
        }
        
        else if ([resultData valueForKey:@"error"]) {
            RTError *error = [RTError new];
            error.code = [[resultData valueForKey:@"error"] valueForKey:@"code"];
            error.message = [[resultData valueForKey:@"error"] valueForKey:@"message"];
            error.details = [[resultData valueForKey:@"details"] valueForKey:@"code"];
            onError(error);
            onStop(subId);
        }
    }];
}

- (id)objectFromJSON:(NSString *)JSONString {
    NSError *error;
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
    id object = [entity new];
    object = [self setObject:object valuesFromDictionary:JSONDictionary];
    return object;
}

- (id)setObject:(id)object valuesFromDictionary:(NSDictionary *) dictionary {
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

@end








