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
            [self uploadWaitingObjects];
            break;
        }
        case beReachableViaWWAN: {
            [DebLog log:@"WWAN CONNECTION"];
            self.internetActive = YES;
            [self uploadWaitingObjects];
            break;
        }
    }
}

-(void)openDB {
    NSArray *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DBPath = [NSString stringWithFormat:@"%@/%@.sqlite", [directory lastObject], backendless.appID];
    if (sqlite3_open([DBPath UTF8String], &db_instance) == SQLITE_OK) {
        dbOpened = YES;
    }
    else {
        dbOpened = NO;
        [DebLog log:@"Failed to open DB"];
    }
}

-(void)closeDB {
    sqlite3_close(db_instance);
    dbOpened = NO;
}

// operation (for save method)
// 0 - create
// 1 - update
// 2 - other methods (find etc.)
-(void)createTableIfNotExists {
    NSString *createTableCmd = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(objectData BLOB, objectId TEXT PRIMARY KEY, needUpload BOOL, operation BOOL);", self.tableName];
    sqlite3_exec(db_instance, [createTableCmd UTF8String], NULL, NULL, NULL);
}

-(void)deleteFromTable {
    sqlite3_stmt *statement;
    NSString *clearTableCmd = [NSString stringWithFormat:@"DELETE FROM %@", self.tableName];
    if(sqlite3_prepare_v2(db_instance, [clearTableCmd UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if(sqlite3_step(statement) != SQLITE_DONE) {
            [DebLog log:@"Failed to delete records from '%@'", self.tableName];
        }
    }
    sqlite3_finalize(statement);
}

-(void)deleteFromTableWithObjectId:(NSString *)objectId {
    sqlite3_stmt *statement;
    NSString *clearTableCmd = [NSString stringWithFormat:@"DELETE FROM %@ WHERE objectId = '%@'", self.tableName, objectId];
    if(sqlite3_prepare_v2(db_instance, [clearTableCmd UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if(sqlite3_step(statement) != SQLITE_DONE) {
            [DebLog log:@"Failed to delete record from '%@'", self.tableName];
        }
    }
    sqlite3_finalize(statement);
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

-(void)uploadWaitingObjects {
    [self openDB];
    sqlite3_stmt *statement;
    NSString *selectCmd = [NSString stringWithFormat:@"SELECT * from %@ WHERE needUpload = 1", self.tableName];
    if (sqlite3_prepare_v2 (db_instance, [selectCmd UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            BinaryStream *stream = [[BinaryStream alloc] initWithStream:(char *)sqlite3_column_blob(statement, 0) andSize:sqlite3_column_bytes(statement, 0)];
            id object = [AMFSerializer deserializeFromBytes:stream];
            NSString *objectId = [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)];
            int operation = sqlite3_column_int(statement, 3);
            
            if ([object isKindOfClass:[NSDictionary class]]) {
                if (operation == 0) {
                    NSMutableDictionary *mutableObject = [object mutableCopy];
                    [mutableObject setObject:[NSNull null] forKey:@"objectId"];
                    object = mutableObject;
                }
                NSDictionary *savedObject = [self.dataStore save:object];
                if (![[savedObject valueForKey:@"objectId"] isEqualToString:objectId]) {
                    [self deleteFromTableWithObjectId:objectId];
                }
            }
            else {
                if (operation == 0) {
                    ((BackendlessEntity *)object).objectId = nil;
                }
                BackendlessEntity *savedObject = [self.dataStore save:object];
                if (![savedObject.objectId isEqualToString:objectId]) {
                    [self deleteFromTableWithObjectId:objectId];
                }
            }
        }
    }
    sqlite3_finalize(statement);
    [self closeDB];
}

-(void)insertIntoDB:(NSArray *)insertObjects withTableClear:(BOOL)clear withNeedUpload:(int)needUpload withOperation:(int)operation {
    if (!dbOpened) {
        [self openDB];
        [self insert:insertObjects withTableClear:clear withNeedUpload:needUpload withOperation:operation];
        [self closeDB];
    }
    else {
        [self insert:insertObjects withTableClear:clear withNeedUpload:needUpload withOperation:operation];
    }
}

-(void)insert:(NSArray *)insertObjects withTableClear:(BOOL)clear withNeedUpload:(int)needUpload withOperation:(int)operation {
    [self createTableIfNotExists];
    if (clear) {
        [self deleteFromTable];
    }
    for (id insertObject in insertObjects) {
        if ([insertObject isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *object = [insertObject mutableCopy];
            NSString *objectId = [object valueForKey:@"objectId"];
            if ([objectId isKindOfClass:[NSNull class]]) {
                objectId = [[NSUUID UUID] UUIDString];
                [object setObject:objectId forKey:@"objectId"];
            }
            [self insert:object withObjectId:objectId withNeedUpload:needUpload withOperation:operation];
        }
        else {
            BackendlessEntity *object = (BackendlessEntity *)insertObject;
            id objectId = [backendless.data getObjectId:object];
            objectId = [backendless.data getObjectId:object];
            BOOL isObjectId = objectId && [objectId isKindOfClass:NSString.class];
            if (!isObjectId) {
                objectId = [[NSUUID UUID] UUIDString];
                object.objectId = objectId;
            }
            [self insert:object withObjectId:objectId withNeedUpload:needUpload withOperation:operation];
        }
    }
}

-(void)insert:(id)object withObjectId:(NSString *)objectId withNeedUpload:(int)needUpload withOperation:(int)operation {
    sqlite3_stmt *statement;
    NSString *insertCmd = [NSString stringWithFormat:@"INSERT INTO %@(objectData, objectId, needUpload, operation) VALUES(?, '%@', %d, %d);", self.tableName, objectId, needUpload, operation];
    if(sqlite3_prepare_v2(db_instance, [insertCmd UTF8String], -1, &statement, NULL) != SQLITE_OK) {
        [DebLog log:@"Error while creating insert statement: %s", sqlite3_errmsg(db_instance)];
    }
    BinaryStream *stream = [AMFSerializer serializeToBytes:object];
    int result = sqlite3_bind_blob(statement, 1, stream.buffer, (int)stream.size, SQLITE_TRANSIENT);
    if((result = sqlite3_step(statement)) != SQLITE_DONE) {
        [DebLog log:@"Error while inserting: %s", sqlite3_errmsg(db_instance)];
    }
    sqlite3_finalize(statement);
}

-(NSArray *)readFromDB:(DataQueryBuilder *)queryBuilder {
    [self openDB];
    [self createTableIfNotExists];
    NSMutableArray *retrievedObjects = [NSMutableArray new];
    NSString *selectCmd = [NSString stringWithFormat:@"SELECT objectData from %@", self.tableName];
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

-(void)updateRecord:(id)object withNeedUpload:(int)needUpload {
    [self openDB];
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
        [DebLog log:@"Error while creating update statement: %s", sqlite3_errmsg(db_instance)];
    }
    BinaryStream *stream = [AMFSerializer serializeToBytes:object];
    if (sqlite3_bind_blob(statement, 1, stream.buffer, (int)stream.size, SQLITE_TRANSIENT) == SQLITE_OK) {
        if (sqlite3_step(statement) != SQLITE_DONE) {
            [DebLog log:@"Error while updating: %s", sqlite3_errmsg(db_instance)];
        }
    }
    sqlite3_finalize(statement);
    [self closeDB];
}

@end
