//
//  RTFactory.m
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

#import "RTFactory.h"
#import "Backendless.h"

@interface RTFactory() {
    NSMutableDictionary<NSString *, RTDataStore *> *dataStores;
    NSMutableDictionary<NSString *, Channel *> *channels;
    NSMutableDictionary<NSString *, SharedObject *> *sharedObjects;
}
@end

@implementation RTFactory

+(instancetype)sharedInstance {
    static RTFactory *_sharedObjectFactory;
    @synchronized(self) {
        if (!_sharedObjectFactory)
            _sharedObjectFactory = [RTFactory new];
    }
    return _sharedObjectFactory;
}

-(instancetype)init {
    if (self = [super init]) {
        dataStores = [NSMutableDictionary new];
        channels = [NSMutableDictionary new];
        sharedObjects = [NSMutableDictionary new];
    }
    return self;
}

-(RTDataStore *)getDataStore:(NSString *)tableName withEntity:(Class)tableEntity dataStoreType:(UInt32)dataStoreType {
    RTDataStore *dataStore;
    
    if ([[dataStores allKeys] containsObject:tableName] &&
        [[dataStore valueForKey:tableName] getTableEntity] == tableEntity &&
        [[dataStore valueForKey:tableName] getType] == dataStoreType) {
        dataStore = [dataStore valueForKey:tableName];
    }
    else {
        dataStore = [[RTDataStore alloc] initWithTableName:tableName withEntity:tableEntity dataStoreType:dataStoreType];
        [dataStores setObject:dataStore forKey:tableName];
    }
    return dataStore;
}

-(Channel *)getChannel:(NSString *)channelName {
    Channel *channel;
    if ([[channels allKeys] containsObject:channelName]) {
        channel = [channels valueForKey:channelName];
    }
    else {
        channel = [[Channel alloc] initWithChannelName:channelName];
        [channels setObject:channel forKey:channelName];
    }
    return channel;
}

-(SharedObject *)getSharedObject:(NSString *)sharedObjectName {
    SharedObject *sharedObject;
    if ([[sharedObjects allKeys] containsObject:sharedObjectName]) {
        sharedObject = [sharedObjects valueForKey:sharedObjectName];
    }
    else {
        sharedObject = [[SharedObject alloc] initWithName:sharedObjectName];
        [sharedObjects setObject:sharedObject forKey:sharedObjectName];
    }
    return sharedObject;
}

@end
