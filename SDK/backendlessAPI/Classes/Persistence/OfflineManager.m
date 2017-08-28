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
}
@end

@implementation OfflineManager

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kBEReachabilityChangedNotification object:nil];
        internetReachable = [BEReachability reachabilityForInternetConnection];
        [internetReachable startNotifier];
        [self checkNetworkStatus:nil];
    }
    return self;
}

+(OfflineManager *)sharedInstance {
    static OfflineManager *sharedOfflineManager;
    @synchronized(self) {
        if (!sharedOfflineManager)
            sharedOfflineManager = [[OfflineManager alloc] init];
    }
    return sharedOfflineManager;
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

-(void)uploadWaitingObjects {
    [self openDB];
    sqlite3_stmt *statement;
    NSString *selectCmd = [NSString stringWithFormat:@"SELECT * from %@ WHERE needUpload = 1", self.tableName];
    if (sqlite3_prepare_v2 (db_instance, [selectCmd UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            BinaryStream *stream = [[BinaryStream alloc] initWithStream:(char *)sqlite3_column_blob(statement, 0) andSize:sqlite3_column_bytes(statement, 0)];
            id object = [AMFSerializer deserializeFromBytes:stream];
            BackendlessEntity *savedObject = [backendless.data save:object];       
        }
    }
    sqlite3_finalize(statement);
    [self closeDB];
}


-(void)updateRecord:(id)object {
    [self openDB];
    int upd = 0;
    if (!self.internetActive) {
        upd = 1;
    }
    NSString *objectId = ((BackendlessEntity *)object).objectId;
    sqlite3_stmt *statement;
    NSString *updateCmd = [NSString stringWithFormat:@"UPDATE %@ SET objectData = ?, needUpload = %d WHERE objectId = '%@'", self.tableName, upd, objectId];
    if(sqlite3_prepare_v2(db_instance, [updateCmd UTF8String], -1, &statement, NULL) != SQLITE_OK) {
        [DebLog log:@"Error while creating insert statement: %s", sqlite3_errmsg(db_instance)];
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


-(void)openDB {
    NSArray *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DBPath = [NSString stringWithFormat:@"%@/%@.sqlite", [directory lastObject], backendless.appID];
    if (sqlite3_open([DBPath UTF8String], &db_instance) != SQLITE_OK) {
        [DebLog log:@"Failed to open DB"];
    }
}

-(void)closeDB {
    sqlite3_close(db_instance);
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
    NSString *createTableCmd = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(objectData BLOB, objectId TEXT PRIMARY KEY, needUpload BOOL);", self.tableName];
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

-(void)insertIntoDB:(NSArray *)insertObjects {
    [self openDB];
    [self createTableIfNotExists];
    [self deleteFromTable];
    for (BackendlessEntity *object in insertObjects) {
        sqlite3_stmt *statement;
        NSString *insertCmd = [NSString stringWithFormat:@"INSERT INTO %@(objectData, objectId, needUpload) VALUES(?, '%@', 0);", self.tableName, object.objectId];
        if(sqlite3_prepare_v2(db_instance, [insertCmd UTF8String], -1, &statement, NULL) != SQLITE_OK) {
            [DebLog log:@"Error while creating insert statement: %s", sqlite3_errmsg(db_instance)];
        }
        BinaryStream *stream = [AMFSerializer serializeToBytes:object];
        int result = sqlite3_bind_blob(statement, 1, stream.buffer, (int)stream.size, SQLITE_TRANSIENT);
        if((result = sqlite3_step(statement)) != SQLITE_DONE) {
            [DebLog log:@"Error while updating: %s", sqlite3_errmsg(db_instance)];
        }
        else {
            [DebLog log:@"A new object added to DB"];
        }
        sqlite3_finalize(statement);
    }
    [self closeDB];
}

-(void)insertNewObject:(id)object {
    [self openDB];
    [self createTableIfNotExists];
    BackendlessEntity *entity = (BackendlessEntity *)object;
    sqlite3_stmt *statement;
    NSString *tmpObjectId = [[NSUUID UUID] UUIDString];
    NSString *insertCmd = [NSString stringWithFormat:@"INSERT INTO %@(objectData, objectId, needUpload) VALUES(?, '%@', 1);", self.tableName, tmpObjectId];
    if(sqlite3_prepare_v2(db_instance, [insertCmd UTF8String], -1, &statement, NULL) != SQLITE_OK) {
        [DebLog log:@"Error while creating insert statement: %s", sqlite3_errmsg(db_instance)];
    }
    BinaryStream *stream = [AMFSerializer serializeToBytes:object];
    int result = sqlite3_bind_blob(statement, 1, stream.buffer, (int)stream.size, SQLITE_TRANSIENT);
    if((result = sqlite3_step(statement)) != SQLITE_DONE) {
        [DebLog log:@"Error while updating: %s", sqlite3_errmsg(db_instance)];
    }
    else {
        [DebLog log:@"A new object added to DB"];
    }
    sqlite3_finalize(statement);
    [self closeDB];
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

@end
