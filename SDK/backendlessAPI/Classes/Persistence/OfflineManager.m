//
//  OfflineManager.m
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

#import "OfflineManager.h"
#import "BEReachability.h"
#import <sqlite3.h>

@interface OfflineManager() {
    sqlite3 *db_instance;
    BEReachability* internetReachable;
    BOOL dbOpened;
}
@end

@implementation OfflineManager

-(id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kBEReachabilityChangedNotification object:nil];
        internetReachable = [BEReachability reachabilityForInternetConnection];
        [internetReachable startNotifier];
        [self checkNetworkStatus:nil];
    }
    return self;
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC OfflineManager"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.internetActive = NO;
    [self.tableName release];
    [internetReachable release];
    [super dealloc];
}

-(void)checkNetworkStatus:(NSNotification *)notice {
    BENetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus) {
        case beNotReachable: {
            [DebLog log:@"NO INTERNET CONNECTION"];
            self.internetActive = NO;
            break;
        }
        case beReachableViaWiFi: {
            [DebLog log:@"WI-FI CONNECTION"];
            self.internetActive = YES;
            [self uploadWaitingObjects:self.responseBlock error:self.errorBlock];
            break;
        }
        case beReachableViaWWAN: {
            [DebLog log:@"WWAN CONNECTION"];
            self.internetActive = YES;
            [self uploadWaitingObjects:self.responseBlock error:self.errorBlock];
            break;
        }
    }
}

-(Fault *)faultWithMessage:(NSString *)message withSQLError:(const char *)sqliteError {
    return [[Fault alloc] initWithMessage:[message stringByAppendingString:[NSString stringWithUTF8String:sqliteError]]];
}

-(void)openDB {
    NSArray *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DBPath = [NSString stringWithFormat:@"%@/%@.sqlite", [directory lastObject], backendless.appID];
    if (sqlite3_open([DBPath UTF8String], &db_instance) == SQLITE_OK) {
        dbOpened = YES;
    }
    else {
        dbOpened = NO;
        [DebLog log:@"SQLite Error: %s", sqlite3_errmsg(db_instance)];
    }
}

-(void)closeDB {
    sqlite3_close(db_instance);
    dbOpened = NO;
}

-(void)dropTable {
    [self openDB];
    char *error;
    NSString *dropTableCmd = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@;", self.tableName];
    sqlite3_exec(db_instance, [dropTableCmd UTF8String], NULL, NULL, &error);
    [DebLog log:@"Table dropped: ", self.tableName];
    self.tableName = nil;
    [self closeDB];
}

-(void)createTableIfNotExists {
    NSString *createTableCmd = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(objectData BLOB, objectId TEXT PRIMARY KEY, needUpload BOOL, operation INTEGER, created TEXT);", self.tableName];
    sqlite3_exec(db_instance, [createTableCmd UTF8String], NULL, NULL, NULL);
}

-(BOOL)objectExistsInBackendless:(NSString *)objectId {
    DataQueryBuilder *queryBuilder = [DataQueryBuilder new];
    [queryBuilder setWhereClause:[NSString stringWithFormat:@"objectId = '%@'", objectId]];
    BOOL exists = NO;
    NSArray *objectsInBackendless = [self.dataStore find:queryBuilder];
    if ([objectsInBackendless count] > 0) {
        exists = YES;
    }
    return exists;
}

// check sync async !!!!!
-(void)uploadWaitingObjects:(void(^)(BOOL))responseBlock error:(void(^)(Fault *))errorBlock {
    [self openDB];
    int recordsCount = 0;
    __block BOOL syncComplete = YES;
    
    sqlite3_stmt *statement;
    NSString *countCmd = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE needUpload = 1", self.tableName];
    if (sqlite3_prepare_v2(db_instance, [countCmd UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW )
            recordsCount  = sqlite3_column_int(statement, 0);
    }
    sqlite3_reset(statement);
    
    NSString *selectCmd = [NSString stringWithFormat:@"SELECT * from %@ WHERE needUpload = 1", self.tableName];
    if (sqlite3_prepare_v2 (db_instance, [selectCmd UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            BinaryStream *stream = [[BinaryStream alloc] initWithStream:(char *)sqlite3_column_blob(statement, 0) andSize:sqlite3_column_bytes(statement, 0)];
            id object = [AMFSerializer deserializeFromBytes:stream];
            NSString *objectId = [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)];
            int operation = sqlite3_column_int(statement, 3);
            
            [self deleteFromTableWithObjectId:objectId
                                     response:^(NSNumber *result) {
                                     }
                                        error:^(Fault *fault) {
                                            if (errorBlock) {
                                                errorBlock([self faultWithMessage:@"SQLite Error: " withSQLError:sqlite3_errmsg(db_instance)]);
                                                syncComplete = NO;
                                            }
                                        }];
            
            if (operation == 2) {
                // change by findByID
                if ([self objectExistsInBackendless:objectId]) {
                    [self.dataStore remove:object
                                  response:^(NSNumber *result) {
                                      [DebLog log:@"Object saved to BKNDLSS"];
                                  }
                                     error:^(Fault *fault) {
                                         if (errorBlock) {
                                             errorBlock(fault);
                                             syncComplete = NO;
                                         }
                                     }];
                }
            }
            
            else {
                if (operation == 0) {
                    if ([object isKindOfClass:[NSDictionary class]]) {
                        NSMutableDictionary *mutableObject = [object mutableCopy];
                        [mutableObject setObject:[NSNull null] forKey:@"objectId"];
                        object = mutableObject;
                    }
                    else {
                        ((BackendlessEntity *)object).objectId = nil;
                    }
                }               
                [self.dataStore save:object
                            response:^(id savedObject) {
                                [DebLog log:@"Object saved to BKNDLSS"];
                                
                                if ([savedObject isKindOfClass:[NSDictionary class]]) {
                                    [self insert:savedObject
                                    withObjectId:[savedObject valueForKey:@"objectId"]
                                  withNeedUpload:0
                                   withOperation:0
                                     withCreated:[savedObject valueForKey:@"created"]
                                        response:^(id saved) {
                                            
                                        }
                                           error:^(Fault *fault) {
                                               if (errorBlock) {
                                                   errorBlock(fault);
                                               }
                                           }];
                                }
                                
                                else {
                                    [self insert:savedObject
                                    withObjectId:((BackendlessEntity *)savedObject).objectId
                                  withNeedUpload:0
                                   withOperation:0
                                     withCreated:((BackendlessEntity *)savedObject).created
                                        response:^(id saved) {
                                            
                                        }
                                           error:^(Fault *fault) {
                                               if (errorBlock) {
                                                   errorBlock(fault);
                                               }
                                           }];

                                }
                            }
                               error:^(Fault *fault) {
                                   if (errorBlock) {
                                       errorBlock(fault);
                                       syncComplete = NO;
                                   }
                               }];
            }
        }
    }
    sqlite3_finalize(statement);
    [self closeDB];
    if (responseBlock && recordsCount > 0) {
        responseBlock(syncComplete);
    }
}

-(BOOL)recordExists:(NSString *)query{
    BOOL recordExists = NO;
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db_instance, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            recordExists = YES;
        }
    }
    sqlite3_finalize(statement);
    return recordExists;
}

// sync SQLite methods

-(NSArray *)insertIntoDB:(NSArray *)insertObjects withNeedUpload:(int)needUpload withOperation:(int)operation {
    if (!dbOpened) {
        [self openDB];
        insertObjects = [self insert:insertObjects withNeedUpload:needUpload withOperation:operation];
        [self closeDB];
    }
    else {
        insertObjects = [self insert:insertObjects withNeedUpload:needUpload withOperation:operation];
    }
    return insertObjects;
}

-(NSArray *)insert:(NSArray *)insertObjects withNeedUpload:(int)needUpload withOperation:(int)operation {
    NSMutableArray *inserted = [NSMutableArray new];
    [self createTableIfNotExists];
    for (id insertObject in insertObjects) {
        if ([insertObject isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *object = [insertObject mutableCopy];
            NSString *objectId = [object valueForKey:@"objectId"];
            if ([objectId isKindOfClass:[NSNull class]]) {
                objectId = [[NSUUID UUID] UUIDString];
                [object setObject:objectId forKey:@"objectId"];
            }
            NSDate *created = [object valueForKey:@"created"];
            if ([created isKindOfClass:[NSNull class]]) {
                [object setObject:[NSDate date] forKey:@"created"];
            }
            insertObject = [self insert:object withObjectId:objectId withNeedUpload:needUpload withOperation:operation withCreated:created];
            [inserted addObject:insertObject];
        }
        else {
            BackendlessEntity *object = (BackendlessEntity *)insertObject;
            id objectId = object.objectId;
            BOOL isObjectId = objectId && [objectId isKindOfClass:NSString.class];
            if (!isObjectId) {
                objectId = [[NSUUID UUID] UUIDString];
                object.objectId = objectId;
            }
            if (!object.created) {
                object.created = [NSDate date];
            }
            insertObject = [self insert:object withObjectId:objectId withNeedUpload:needUpload withOperation:operation withCreated:object.created];
            [inserted addObject:insertObject];
        }
    }
    return inserted;
}

-(id)insert:(id)object withObjectId:(NSString *)objectId withNeedUpload:(int)needUpload withOperation:(int)operation withCreated:(NSDate *)created {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSString *createdString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:created]];
    
    if ([self recordExists:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE objectId = '%@'", self.tableName, objectId]]) {
        object = [self updateRecord:object withNeedUpload:needUpload];
    }
    else {
        sqlite3_stmt *statement;
        NSString *insertCmd = [NSString stringWithFormat:@"INSERT INTO %@(objectData, objectId, needUpload, operation, created) VALUES(?, '%@', %d, %d, '%@');", self.tableName, objectId, needUpload, operation, createdString];
        if(sqlite3_prepare_v2(db_instance, [insertCmd UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            BinaryStream *stream = [AMFSerializer serializeToBytes:object];
            int blobResult = sqlite3_bind_blob(statement, 1, stream.buffer, (int)stream.size, SQLITE_TRANSIENT);
            if((blobResult = sqlite3_step(statement)) == SQLITE_DONE) {
                sqlite3_finalize(statement);
            }
        }
    }
    return object;
}

-(id)updateRecord:(id)object withNeedUpload:(int)needUpload {
    if (!dbOpened) {
        [self openDB];
        object = [self update:object withNeedUpload:needUpload];
        [self closeDB];
    }
    else {
        object = [self update:object withNeedUpload:needUpload];
    }
    return object;
}

-(id)update:(id)object withNeedUpload:(int)needUpload {
    id result = object;
    NSString *objectId;
    if ([object isKindOfClass:[NSDictionary class]]) {
        objectId = [object valueForKey:@"objectId"];
    }
    else {
        objectId = ((BackendlessEntity *)object).objectId;
    }
    sqlite3_stmt *statement;
    NSString *updateCmd = [NSString stringWithFormat:@"UPDATE %@ SET objectData = ?, needUpload = %d WHERE objectId = '%@'", self.tableName, needUpload, objectId];
    if(sqlite3_prepare_v2(db_instance, [updateCmd UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        BinaryStream *stream = [AMFSerializer serializeToBytes:object];
        if (sqlite3_bind_blob(statement, 1, stream.buffer, (int)stream.size, SQLITE_TRANSIENT) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_DONE) {
                sqlite3_finalize(statement);
            }
        }
    }
    return object;
}

-(NSArray *)readFromDB:(DataQueryBuilder *)queryBuilder {
    [self openDB];
    [self createTableIfNotExists];
    NSMutableArray *retrievedObjects = [NSMutableArray new];
    NSString *selectCmd = [NSString stringWithFormat:@"SELECT objectData from %@ WHERE operation != 2", self.tableName];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2 (db_instance, [selectCmd UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            BinaryStream *stream = [[BinaryStream alloc] initWithStream:(char *)sqlite3_column_blob(statement, 0) andSize:sqlite3_column_bytes(statement, 0)];
            id object = [AMFSerializer deserializeFromBytes:stream];
            [retrievedObjects addObject:object];
        }
    }
    if (queryBuilder) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[queryBuilder getWhereClause]];
        retrievedObjects = (NSMutableArray *)[retrievedObjects filteredArrayUsingPredicate:predicate];
        
    }
    sqlite3_finalize(statement);
    [self closeDB];
    return (NSArray *)retrievedObjects;
}

-(void)deleteFromTable {
    sqlite3_stmt *statement;
    NSString *clearTableCmd = [NSString stringWithFormat:@"DELETE FROM %@", self.tableName];
    if(sqlite3_prepare_v2(db_instance, [clearTableCmd UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if(sqlite3_step(statement) != SQLITE_DONE) {
            [DebLog log:@"SQLite Error: %s", sqlite3_errmsg(db_instance)];
        }
    }
    sqlite3_finalize(statement);
}

-(NSNumber *)markObjectForDeleteWithObjectId:(NSString *)objectId {
    NSNumber *result = @0;
    [self openDB];
    sqlite3_stmt *statement;
    NSString *countCmd = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE objectId = '%@'", self.tableName, objectId];
    if (sqlite3_prepare_v2(db_instance, [countCmd UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW )
            result = @(sqlite3_column_int(statement, 0));
    }
    sqlite3_reset(statement);
    NSString *updateCmd = [NSString stringWithFormat:@"Update %@ SET needUpload = 1, operation = 2 WHERE objectId = '%@'", self.tableName, objectId];
    sqlite3_prepare_v2(db_instance, [updateCmd UTF8String], -1, &statement, NULL);
    if (sqlite3_step(statement) == SQLITE_DONE) {
        sqlite3_finalize(statement);
    }
    [self closeDB];
    return result;
}

-(NSNumber *)deleteFromTableWithObjectId:(NSString *)objectId {
    NSNumber *result  = @0;
    sqlite3_stmt *statement;
    NSString *countCmd = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE objectId = '%@'", self.tableName, objectId];
    if (sqlite3_prepare_v2(db_instance, [countCmd UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW )
            result = @(sqlite3_column_int(statement, 0));
    }
    sqlite3_reset(statement);
    NSString *clearTableCmd = [NSString stringWithFormat:@"DELETE FROM %@ WHERE objectId = '%@'", self.tableName, objectId];
    if(sqlite3_prepare_v2(db_instance, [clearTableCmd UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if(sqlite3_step(statement) == SQLITE_DONE) {
            sqlite3_finalize(statement);
        }
    }
    return result;
}

// async SQLite methods

-(void)insertIntoDB:(NSArray *)insertObjects withNeedUpload:(int)needUpload withOperation:(int)operation response:(void (^)(NSArray *))responseBlock error:(void (^)(Fault *))errorBlock {
    if (!dbOpened) {
        [self openDB];
        [self insert:insertObjects withNeedUpload:needUpload withOperation:operation response:responseBlock error:errorBlock];
        [self closeDB];
    }
    else {
        [self insert:insertObjects withNeedUpload:needUpload withOperation:operation response:responseBlock error:errorBlock];
    }
}

-(void)insert:(NSArray *)insertObjects withNeedUpload:(int)needUpload withOperation:(int)operation response:(void (^)(NSArray *))responseBlock error:(void (^)(Fault *))errorBlock {
    NSMutableArray *inserted = [NSMutableArray new];
    [self createTableIfNotExists];
    for (id insertObject in insertObjects) {
        if ([insertObject isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *object = [insertObject mutableCopy];
            NSString *objectId = [object valueForKey:@"objectId"];
            if ([objectId isKindOfClass:[NSNull class]]) {
                objectId = [[NSUUID UUID] UUIDString];
                [object setObject:objectId forKey:@"objectId"];
            }
            NSDate *created = [object valueForKey:@"created"];
            if ([created isKindOfClass:[NSNull class]]) {
                [object setObject:[NSDate date] forKey:@"created"];
            }
            void (^wrappedBlock)(id) = ^(id insertedObject) {
                [inserted addObject:insertedObject];
            };
            [self insert:object withObjectId:objectId withNeedUpload:needUpload withOperation:operation withCreated:created response:wrappedBlock error:errorBlock];
        }
        else {
            BackendlessEntity *object = (BackendlessEntity *)insertObject;
            id objectId = object.objectId;
            BOOL isObjectId = objectId && [objectId isKindOfClass:NSString.class];
            if (!isObjectId) {
                objectId = [[NSUUID UUID] UUIDString];
                object.objectId = objectId;
            }
            if (!object.created) {
                object.created = [NSDate date];
            }
            void (^wrappedBlock)(id) = ^(id insertedObject) {
                [inserted addObject:insertedObject];
            };
            [self insert:object withObjectId:objectId withNeedUpload:needUpload withOperation:operation withCreated:object.created response:wrappedBlock error:errorBlock];
        }
    }
    if (responseBlock) {
        responseBlock(inserted);
    }
}

-(void)insert:(id)object withObjectId:(NSString *)objectId withNeedUpload:(int)needUpload withOperation:(int)operation withCreated:(NSDate *)created response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSString *createdString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:created]];
    
    if ([self recordExists:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE objectId = '%@'", self.tableName, objectId]]) {
        [self updateRecord:object withNeedUpload:needUpload response:responseBlock error:errorBlock];
    }
    else {
        sqlite3_stmt *statement;
        NSString *insertCmd = [NSString stringWithFormat:@"INSERT INTO %@(objectData, objectId, needUpload, operation, created) VALUES(?, '%@', %d, %d, '%@');", self.tableName, objectId, needUpload, operation, createdString];
        if(sqlite3_prepare_v2(db_instance, [insertCmd UTF8String], -1, &statement, NULL) != SQLITE_OK) {
            if (errorBlock) {
                errorBlock([self faultWithMessage:@"SQLite Error: " withSQLError:sqlite3_errmsg(db_instance)]);
            }
        }
        BinaryStream *stream = [AMFSerializer serializeToBytes:object];
        int result = sqlite3_bind_blob(statement, 1, stream.buffer, (int)stream.size, SQLITE_TRANSIENT);
        if((result = sqlite3_step(statement)) != SQLITE_DONE) {
            if (errorBlock) {
                errorBlock([self faultWithMessage:@"SQLite Error: " withSQLError:sqlite3_errmsg(db_instance)]);
            }
        }
        sqlite3_finalize(statement);
        if (responseBlock) {
            responseBlock(object);
        }
    }
}

-(void)updateRecord:(id)object withNeedUpload:(int)needUpload response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    if (!dbOpened) {
        [self openDB];
        [self update:object withNeedUpload:needUpload response:responseBlock error:errorBlock];
        [self closeDB];
    }
    else {
        [self update:object withNeedUpload:needUpload response:responseBlock error:errorBlock];
    }
}

-(void)update:(id)object withNeedUpload:(int)needUpload response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    NSString *objectId;
    if ([object isKindOfClass:[NSDictionary class]]) {
        objectId = [object valueForKey:@"objectId"];
    }
    else {
        objectId = ((BackendlessEntity *)object).objectId;
    }
    sqlite3_stmt *statement;
    NSString *updateCmd = [NSString stringWithFormat:@"UPDATE %@ SET objectData = ?, needUpload = %d WHERE objectId = '%@'", self.tableName, needUpload, objectId];
    if(sqlite3_prepare_v2(db_instance, [updateCmd UTF8String], -1, &statement, NULL) != SQLITE_OK) {
        if (errorBlock) {
            errorBlock([self faultWithMessage:@"SQLite Error: " withSQLError:sqlite3_errmsg(db_instance)]);
        }
    }
    BinaryStream *stream = [AMFSerializer serializeToBytes:object];
    if (sqlite3_bind_blob(statement, 1, stream.buffer, (int)stream.size, SQLITE_TRANSIENT) == SQLITE_OK) {
        if (sqlite3_step(statement) != SQLITE_DONE) {
            if (errorBlock) {
                errorBlock([self faultWithMessage:@"SQLite Error: " withSQLError:sqlite3_errmsg(db_instance)]);
            }
        }
    }
    sqlite3_finalize(statement);
    if (responseBlock) {
        responseBlock(object);
    }
}

-(void)markObjectForDeleteWithObjectId:(NSString *)objectId response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self openDB];
    NSNumber *result = @0;
    sqlite3_stmt *statement;
    NSString *countCmd = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE objectId = '%@'", self.tableName, objectId];
    if (sqlite3_prepare_v2(db_instance, [countCmd UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW )
            result = @(sqlite3_column_int(statement, 0));
    }
    sqlite3_reset(statement);
    NSString *updateCmd = [NSString stringWithFormat:@"Update %@ SET needUpload = 1, operation = 2 WHERE objectId = '%@'", self.tableName, objectId];
    sqlite3_prepare_v2(db_instance, [updateCmd UTF8String], -1, &statement, NULL);
    if (sqlite3_step(statement) != SQLITE_DONE) {
        if (errorBlock) {
            errorBlock([self faultWithMessage:@"SQLite Error: " withSQLError:sqlite3_errmsg(db_instance)]);
        }
    }
    sqlite3_finalize(statement);
    [self closeDB];
    if (responseBlock) {
        responseBlock(result);
    }
}

-(void)deleteFromTableWithObjectId:(NSString *)objectId response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    NSNumber *result  = @0;
    sqlite3_stmt *statement;
    NSString *countCmd = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE objectId = '%@'", self.tableName, objectId];
    if (sqlite3_prepare_v2(db_instance, [countCmd UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW )
            result = @(sqlite3_column_int(statement, 0));
    }
    sqlite3_reset(statement);
    NSString *clearTableCmd = [NSString stringWithFormat:@"DELETE FROM %@ WHERE objectId = '%@'", self.tableName, objectId];
    if(sqlite3_prepare_v2(db_instance, [clearTableCmd UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if(sqlite3_step(statement) != SQLITE_DONE) {
            if (errorBlock) {
                errorBlock([self faultWithMessage:@"SQLite Error: " withSQLError:sqlite3_errmsg(db_instance)]);
            }
        }
    }
    sqlite3_finalize(statement);
    if (responseBlock) {
        responseBlock(result);
    }
}

-(void)readFromDB:(DataQueryBuilder *)queryBuilder response:(void (^)(NSArray *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self openDB];
    [self createTableIfNotExists];
    NSMutableArray *retrievedObjects = [NSMutableArray new];
    NSString *selectCmd = [NSString stringWithFormat:@"SELECT objectData from %@ WHERE operation != 2", self.tableName];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2 (db_instance, [selectCmd UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            BinaryStream *stream = [[BinaryStream alloc] initWithStream:(char *)sqlite3_column_blob(statement, 0) andSize:sqlite3_column_bytes(statement, 0)];
            id object = [AMFSerializer deserializeFromBytes:stream];
            [retrievedObjects addObject:object];
        }
    }
    else {
        if (errorBlock) {
            errorBlock([self faultWithMessage:@"SQLite Error: " withSQLError:sqlite3_errmsg(db_instance)]);
        }
    }
    if (queryBuilder) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[queryBuilder getWhereClause]];
        retrievedObjects = (NSMutableArray *)[retrievedObjects filteredArrayUsingPredicate:predicate];
        
    }
    sqlite3_finalize(statement);
    [self closeDB];
    if (responseBlock) {
        responseBlock(retrievedObjects);
    }
}

@end
