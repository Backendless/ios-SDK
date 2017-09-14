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

-(void)enableOffline:(void (^)(void))responseBlock error:(void (^)(Fault *))errorBlock {
    offlineManager = [OfflineManager new];
    offlineManager.tableName = [dataStore getDataStoreSourceName];
    offlineManager.dataStore = dataStore;
    offlineManager.responseBlock = responseBlock;
    offlineManager.errorBlock = errorBlock;
    backendless.data.offlineEnabled = YES;
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
                [offlineManager insertIntoDB:@[savedObject] withNeedUpload:0 withOperation:CREATE response:nil error:nil];
            }
            else if ([method isEqualToString:METHOD_UPDATE]) {
                [offlineManager updateRecord:savedObject withNeedUpload:0 response:nil error:nil];
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
                [offlineManager insertIntoDB:@[entity] withNeedUpload:1 withOperation:CREATE response:nil error:nil];
            }
            else if ([method isEqualToString:METHOD_UPDATE]) {
                [offlineManager updateRecord:entity withNeedUpload:1 response:nil error:nil];
            }
        }
    }
    else if (!backendless.data.offlineEnabled) {
        savedObject = [dataStore save:entity];
    }
    return savedObject;
}

-(NSNumber *)remove:(id)entity {
    NSNumber *result = nil;
    if (backendless.data.offlineEnabled) {
        if (offlineManager.internetActive) {
            result = [dataStore remove:entity];
            [offlineManager deleteFromTableWithObjectId:[self getObjectId:entity] response:nil error:nil];
        }
        else if (!offlineManager.internetActive) {
            [offlineManager markObjectForDeleteWithObjectId:[self getObjectId:entity] response:nil error:nil];
        }
    }
    else if (!backendless.data.offlineEnabled) {
        result = [dataStore remove:entity];
    }
    return result;
}

-(NSNumber *)removeById:(NSString *)objectId {
    NSNumber *result = nil;
    if (backendless.data.offlineEnabled) {
        if (offlineManager.internetActive) {
            result = [dataStore removeById:objectId];
            [offlineManager deleteFromTableWithObjectId:objectId response:nil error:nil];
        }
        else if (!offlineManager.internetActive) {
            [offlineManager markObjectForDeleteWithObjectId:objectId response:nil error:nil];
        }
    }
    else if (!backendless.data.offlineEnabled) {
        result = [dataStore removeById:objectId];
    }
    return result;
}

-(NSArray *)find {
    NSArray *resultArray = nil;
    if (backendless.data.offlineEnabled) {
        if (offlineManager.internetActive) {
            resultArray = [dataStore find];
            [offlineManager insertIntoDB:resultArray withNeedUpload:0 withOperation:OTHER response:nil error:nil];
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
            [offlineManager insertIntoDB:resultArray withNeedUpload:0 withOperation:OTHER response:nil error:nil];
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

-(id)findById:(id)objectId {
    id result = nil;
    if (backendless.data.offlineEnabled) {
        if (offlineManager.internetActive) {
            result = [dataStore findById:objectId];
            [offlineManager insertIntoDB:@[result] withNeedUpload:0 withOperation:OTHER response:nil error:nil];
        }
        else if (!offlineManager.internetActive) {
            DataQueryBuilder *queryBuilder = [DataQueryBuilder new];
            [queryBuilder setWhereClause:[NSString stringWithFormat:@"objectId = '%@'", objectId]];
            result = [[offlineManager readFromDB:queryBuilder] firstObject];
        }
    }
    else if (!backendless.data.offlineEnabled) {
        result = [dataStore findById:objectId];
    }
    return result;
}

-(NSNumber *)getObjectCount {
    NSNumber *result = nil;
    if (backendless.data.offlineEnabled) {
        if (offlineManager.internetActive) {
            result = [dataStore getObjectCount];
        }
        else if (!offlineManager.internetActive) {
            result = @([[offlineManager readFromDB:nil] count]);
        }
    }
    else if (!backendless.data.offlineEnabled) {
        result = [dataStore getObjectCount];
    }
    return result;
}

-(NSNumber *)getObjectCount:(DataQueryBuilder *)queryBuilder {
    NSNumber *result = nil;
    if (backendless.data.offlineEnabled) {
        if (offlineManager.internetActive) {
            result = [dataStore getObjectCount:queryBuilder];
        }
        else if (!offlineManager.internetActive) {
            result = @([[offlineManager readFromDB:queryBuilder] count]);
        }
    }
    else if (!backendless.data.offlineEnabled) {
        result = [dataStore getObjectCount:queryBuilder];
    }
    return result;
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
                if ([method isEqualToString:METHOD_CREATE]) {
                    [offlineManager insertIntoDB:@[object] withNeedUpload:0 withOperation:CREATE response:nil error:errorBlock];
                }
                else if ([method isEqualToString:METHOD_UPDATE]) {
                    [offlineManager updateRecord:object withNeedUpload:0 response:nil error:errorBlock];
                }
            };
            [dataStore save:entity response:wrappedBlock error:errorBlock];
        }
        else if (!offlineManager.internetActive) {
            if (!isObjectId) {
                [offlineManager insertIntoDB:@[entity] withNeedUpload:1 withOperation:CREATE response:responseBlock error:errorBlock];
            }
            else {
                [offlineManager updateRecord:entity withNeedUpload:1 response:responseBlock error:errorBlock];
            }
        }
    }
    else if (!backendless.data.offlineEnabled) {
        [dataStore save:entity response:responseBlock error:errorBlock];
    }
}

-(void)remove:(id)entity response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    if (backendless.data.offlineEnabled) {
        if (offlineManager.internetActive) {
            void (^wrappedBlock)(NSNumber *) = ^(NSNumber *result) {
                [offlineManager deleteFromTableWithObjectId:[self getObjectId:entity] response:responseBlock error:errorBlock];
            };
            [dataStore remove:entity response:wrappedBlock error:errorBlock];
        }
        else if (!offlineManager.internetActive) {
            [offlineManager markObjectForDeleteWithObjectId:[self getObjectId:entity] response:responseBlock error:errorBlock];
        }
    }
    else if (!backendless.data.offlineEnabled) {
        [dataStore remove:entity response:responseBlock error:errorBlock];
    }
}

-(void)removeById:(NSString *)objectId response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    if (backendless.data.offlineEnabled) {
        if (offlineManager.internetActive) {
            void (^wrappedBlock)(NSNumber *) = ^(NSNumber *result) {
                [offlineManager deleteFromTableWithObjectId:objectId response:responseBlock error:errorBlock];
            };
            [dataStore removeById:objectId response:wrappedBlock error:errorBlock];
        }
        else if (!offlineManager.internetActive) {
            [offlineManager markObjectForDeleteWithObjectId:objectId response:responseBlock error:errorBlock];
        }
    }
    else if (!backendless.data.offlineEnabled) {
        [dataStore removeById:objectId response:responseBlock error:errorBlock];
    }
}

-(void)find:(void (^)(NSArray *))responseBlock error:(void (^)(Fault *))errorBlock {
    if (backendless.data.offlineEnabled) {
        if (offlineManager.internetActive) {
            void (^wrappedBlock)(NSArray *) = ^(NSArray *resultArray) {
                [offlineManager insertIntoDB:resultArray withNeedUpload:0 withOperation:OTHER response:responseBlock error:errorBlock];
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

-(void)find:(DataQueryBuilder *)queryBuilder response:(void (^)(NSArray *))responseBlock error:(void (^)(Fault *))errorBlock {
    if (backendless.data.offlineEnabled) {
        if (offlineManager.internetActive) {
            void (^wrappedBlock)(NSArray *) = ^(NSArray *resultArray) {
                [offlineManager insertIntoDB:resultArray withNeedUpload:0 withOperation:OTHER response:responseBlock error:errorBlock];
            };
            [dataStore find:queryBuilder response:wrappedBlock error:errorBlock];
        }
        else if (!offlineManager.internetActive) {
            NSArray *resultArray = [offlineManager readFromDB:queryBuilder];
            responseBlock(resultArray);
        }
    }
    else if (!backendless.data.offlineEnabled) {
        [dataStore find:queryBuilder response:responseBlock error:errorBlock];
    }
}

-(void)findById:(id)objectId response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    if (backendless.data.offlineEnabled) {
        if (offlineManager.internetActive) {
            void (^wrappedBlock)(id) = ^(id result) {
                [offlineManager insertIntoDB:@[result] withNeedUpload:0 withOperation:OTHER response:nil error:nil];
            };
            [dataStore findById:objectId response:wrappedBlock error:errorBlock];
        }
        else if (!offlineManager.internetActive) {
            DataQueryBuilder *queryBuilder = [DataQueryBuilder new];
            [queryBuilder setWhereClause:[NSString stringWithFormat:@"objectId = '%@'", objectId]];
            responseBlock([[offlineManager readFromDB:queryBuilder] firstObject]);
        }
    }
    else if (!backendless.data.offlineEnabled) {
        [dataStore findById:objectId response:responseBlock error:errorBlock];
    }
}

-(void)getObjectCount:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    if (backendless.data.offlineEnabled) {
        if (offlineManager.internetActive) {
            [dataStore getObjectCount:responseBlock error:errorBlock];
        }
        else if (!offlineManager.internetActive) {
            responseBlock(@([[offlineManager readFromDB:nil] count]));
        }
    }
    else if (!backendless.data.offlineEnabled) {
        [dataStore getObjectCount:responseBlock error:errorBlock];
    }
}

-(void)getObjectCount:(DataQueryBuilder *)queryBuilder response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    if (backendless.data.offlineEnabled) {
        if (offlineManager.internetActive) {
            [dataStore getObjectCount:queryBuilder response:responseBlock error:errorBlock];
        }
        else if (!offlineManager.internetActive) {
            responseBlock(@([[offlineManager readFromDB:queryBuilder] count]));
        }
    }
    else if (!backendless.data.offlineEnabled) {
        [dataStore getObjectCount:queryBuilder response:responseBlock error:errorBlock];
    }
}

@end
