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
    OfflineManager *offlineManager;
}
@end


@implementation OfflineDataStore

-(void)enableOffline {
    backendless.data.offlineEnabled = YES;
    offlineManager = [OfflineManager new];
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

-(void)prepareObjectForSaving:(id)object {
    [__types classInstance:[object class]];
    [[object class] resolveProperty:@"objectId"];
}

-(NSDictionary *)prepareDictionaryForSaving:(NSDictionary *)dictionary {
    if (![[dictionary allKeys] containsObject:@"objectId"]) {
        NSMutableDictionary *mutableDictionary = [dictionary mutableCopy];
        [mutableDictionary setObject:[NSNull null] forKey:@"objectId"];
        dictionary = mutableDictionary;
    }
    return dictionary;
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
        id objectId = [self getObjectId:entity];
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
                if ([entity isKindOfClass:[NSDictionary class]]) {
                    entity = [self prepareDictionaryForSaving:entity];
                }
                else {
                    [self prepareObjectForSaving:entity];
                }
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

// async methods with block-based callbacks

-(void)save:(id)entity response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    if (backendless.data.offlineEnabled) {
        
        id objectId = [self getObjectId:entity];
        BOOL isObjectId = objectId && [objectId isKindOfClass:NSString.class];
        NSString *method = METHOD_CREATE;
        if (isObjectId) {
            method = METHOD_UPDATE;
        }
        if ([method isEqualToString:METHOD_CREATE]) {
            if ([entity isKindOfClass:[NSDictionary class]]) {
                entity = [self prepareDictionaryForSaving:entity];
            }
            else {
                [self prepareObjectForSaving:entity];
            }
        }
        if (offlineManager.internetActive) {
            void (^wrappedBlock)(id) = ^(id object) {
                responseBlock(object);
                if (!isObjectId) {
                    [offlineManager insertIntoDB:@[object] withTableClear:NO withNeedUpload:0 withOperation:0];
                }
            };
            [dataStore save:entity response:wrappedBlock error:errorBlock];
        }
        else if (!offlineManager.internetActive) {
            if (!isObjectId) {
                [offlineManager insertIntoDB:@[entity] withTableClear:NO withNeedUpload:1 withOperation:0];
            }
        }
    }
    else if (!backendless.data.offlineEnabled) {
        [dataStore save:entity response:responseBlock error:errorBlock];
    }
}

-(void)find:(void (^)(NSArray *))responseBlock error:(void (^)(Fault *))errorBlock {
    if (backendless.data.offlineEnabled) {
        if (offlineManager.internetActive) {            
            void (^wrappedBlock)(NSArray *) = ^(NSArray *resultArray) {
                responseBlock(resultArray);
                [offlineManager insertIntoDB:resultArray withTableClear:YES withNeedUpload:0 withOperation:2];
            };
            [dataStore find:wrappedBlock error:errorBlock];
        }
        else if (!offlineManager.internetActive) {
            NSArray *resultArray = [offlineManager readFromDB:nil];
            responseBlock(resultArray);
        }
    }
    else if (!backendless.data.offlineEnabled) {
        [dataStore find:responseBlock error:errorBlock];
    }
}




@end
