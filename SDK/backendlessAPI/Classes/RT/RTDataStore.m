//
//  RTDataStore.h
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

#import "RTDataStore.h"
#import "RTClient.h"

#define OBJECTS_CHANGES @"OBJECTS_CHANGES"
#define ERROR_TYPE @"Error"

@implementation RTDataStore

-(RTDataStore *)init {
    if (self = [super init]) {
        self.simpleListener = [NSMutableDictionary<NSString *, NSMutableArray *> new];
        self.subscriptions = [NSMutableDictionary new];
    }
    return self;
}

-(void)addErrorListener:(void (^)(NSDictionary *))onError {
    NSMutableArray *errors = [self.simpleListener valueForKey:ERROR_TYPE];
    [errors addObject:onError];
}

-(void)addCreateListener:(void(^)(id))onCreate {
    
}

-(void)subscribeForObjectChanges:(NSString *)subId event:(NSString *)event tableName:(NSString *)tableName dataStore:(id<IDataStore>)dataStore onData:(void(^)(id))onData {
    
    if (!subId) {
        subId = [[NSUUID UUID] UUIDString];
    }
    
    NSDictionary *options = @{@"tableName"  : tableName,
                              @"event"      : event,
                              @"whereClause" : @"name = 'Ann'"};
    
    NSDictionary *data = @{@"id"        : subId,
                           @"name"      : OBJECTS_CHANGES,
                           @"options"   : options};
    
    NSDictionary *dict = @{@"data"      : data,
                           @"dataStore" : dataStore,
                           @"onData"    : onData,
                           @"onError"   : [self.simpleListener valueForKey:ERROR_TYPE]};
    [self.subscriptions setObject:dict forKey:subId];
    
    [rtClient subscribe:data onError:[self.simpleListener valueForKey:ERROR_TYPE]];
}

@end

