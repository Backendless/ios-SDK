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

@implementation RTFactory

+(instancetype)sharedInstance {
    static RTFactory *_sharedObjectFactory;
    @synchronized(self) {
        if (!_sharedObjectFactory)
            _sharedObjectFactory = [RTFactory new];
    }
    return _sharedObjectFactory;
}

-(EventHandler *)createDataStore:(NSString *)tableName withEntity:(Class)tableEntity dataStoreType:(UInt32)dataStoreType {
    return [[EventHandler alloc] initWithTableName:tableName withEntity:tableEntity dataStoreType:dataStoreType];
}

-(Channel *)createChannel:(NSString *)channelName {
    return [[Channel alloc] initWithChannelName:channelName];
}

-(SharedObject *)createSharedObject:(NSString *)sharedObjectName {
    return [[SharedObject alloc] initWithName:sharedObjectName];
}

@end
