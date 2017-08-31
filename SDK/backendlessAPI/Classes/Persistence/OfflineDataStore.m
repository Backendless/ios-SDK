//
//  OfflineDataStore.m
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


#import "OfflineDataStore.h"
#import "Backendless.h"
#import "OfflineManager.h"
#import "ObjectProperty.h"
#import "Types.h"

// METHOD NAMES
static NSString *METHOD_CREATE = @"create";
static NSString *METHOD_UPDATE = @"update";

@interface OfflineDataStore () {
    id<IDataStore> dataStore;
}
@end


@implementation OfflineDataStore

-(void)enableOffline {
    backendless.data.offlineEnabled = YES;
    offlineManager.tableName = [dataStore getDataStoreSourceName];
    offlineManager.dataStore = dataStore;
}

-(void)disableOffline {
    backendless.data.offlineEnabled = NO;
    [offlineManager dropTable];
}

-(id <IDataStore>)initWithDataStore:(id <IDataStore>)iDataStore {
    if (self = [super init]) {
        dataStore = iDataStore;
        [[Types sharedInstance] addClientClassMapping:@"Users" mapped:[BackendlessUser class]];
    }
    return self;
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC OfflineDataStore"];
    [super dealloc];
}

-(id)prepareObjectForSaving:(id)object {
    if ([object isKindOfClass:[NSDictionary class]]) {
        if (![[object allKeys] containsObject:@"objectId"]) {
            NSMutableDictionary *mutableObject = [object mutableCopy];
            [mutableObject setObject:[NSNull null] forKey:@"objectId"];
            object = mutableObject;
        }
    }
    else {
        object = [__types classInstance:[object class]];
        [object resolveProperty:@"objectId"];
    }
    return object;
}

-(NSString *)getObjectId:(id)object {
    NSString *objectId;
    if ([object isKindOfClass:[NSDictionary class]]) {
        objectId = [object valueForKey:@"objectId"];
    }
    else {
        objectId = [backendless.data getObjectId:object];
    }
    return objectId;
}

#pragma mark IDataStore Methods

// sync methods with fault return (as exception)

-(id)save:(id)entity {
    id savedObject = nil;
    if (backendless.data.offlineEnabled) {
        
        id objectId;
        
        if ([entity isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Entity is dictionary");
            objectId = [entity valueForKey:@"objectId"];
            NSLog(@"OBJECT ID 1 = %@", objectId);
        }
        else {
            NSLog(@"Entity is object");
            objectId = [self getObjectId:entity];
            NSLog(@"OBJECT ID 2 = %@", objectId);
        }
        
        BOOL isObjectId = objectId && [objectId isKindOfClass:NSString.class];
        
        NSString *method = METHOD_CREATE;
        if (isObjectId) {
            method = METHOD_UPDATE;
        }
        if (offlineManager.internetActive) {
            savedObject = [dataStore save:entity];
            if ([method isEqualToString:METHOD_CREATE]) {
                [offlineManager insertIntoDB:@[savedObject] withTableClear:NO withNeedUpload:0 withOperation:0];
            }
            else if ([method isEqualToString:METHOD_UPDATE]) {
                [offlineManager updateRecord:savedObject withNeedUpload:0];
            }
        }
        else if (!offlineManager.internetActive) {
            if ([method isEqualToString:METHOD_CREATE]) {
                entity = [self prepareObjectForSaving:entity];
                [offlineManager insertIntoDB:@[entity] withTableClear:NO withNeedUpload:1 withOperation:0];
            }
            else if ([method isEqualToString:METHOD_UPDATE]) {
                [offlineManager updateRecord:entity withNeedUpload:1];
            }
        }
    }
    else if (!backendless.data.offlineEnabled) {
        savedObject = [dataStore save:entity];
    }
    return savedObject;
}

-(NSArray *)find {
    NSArray *resultArray = nil;
    if (backendless.data.offlineEnabled) {
        if (offlineManager.internetActive) {
            resultArray = [dataStore find];
            [offlineManager insertIntoDB:resultArray withTableClear:YES withNeedUpload:0 withOperation:2];
        }
        else if (!offlineManager.internetActive) {
            resultArray = [offlineManager readFromDB:nil];
        }
    }
    else if (!backendless.data.offlineEnabled) {
        resultArray = [dataStore find];
    }
    return resultArray;
}

-(NSArray *)find:(DataQueryBuilder *)queryBuilder {
    NSArray *resultArray = nil;
    if (backendless.data.offlineEnabled) {
        if (offlineManager.internetActive) {
            resultArray = [dataStore find:queryBuilder];
            [offlineManager insertIntoDB:resultArray withTableClear:YES withNeedUpload:0 withOperation:2];
        }
        else if (!offlineManager.internetActive) {
            resultArray = [offlineManager readFromDB:queryBuilder];
        }
    }
    else if (!backendless.data.offlineEnabled) {
        resultArray = [dataStore find:queryBuilder];
    }
    return resultArray;
}

@end
