//
//  OfflineModeManager.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2014 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "OfflineModeManager.h"
#import "ISDatabase.h"
#import "Types.h"
#import "AMFSerializer.h"
//#import "BackendlessEntity.h"
//#import "Responder.h"
#import "Backendless.h"
#import "BinaryCodec.h"

static NSString *SQLITE_CHECK_IF_TABLE_IS_EXIST = @"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'";
static NSString *OFFLINE_TABLE_NAME = @"offlineData";
static NSString *SQLITE_CREATE_TABLE_FOR_OFFLINE_DATA = @"CREATE TABLE IF NOT EXISTS %@ (object_id TEXT, data TEXT)";
static NSString *DEFAULT_DATABASE_NAME = @"OfflineModeDatabase";
@interface OfflineModeManager ()<IResponder>
{
    Responder *uploadResponder;
    NSMutableArray *objectsId;
}
-(void)saveData:(NSString *)data forKey:(NSString *)key;
-(void)updateData:(NSString *)data forKey:(NSString *)key;
@end

@implementation OfflineModeManager

+(OfflineModeManager *)sharedInstance
{
	static OfflineModeManager *sharedOfflineModeManager;
	@synchronized(self)
	{
		if (!sharedOfflineModeManager)
			sharedOfflineModeManager = [[OfflineModeManager alloc] initWithDefaultDataBaseName];
	}
	return sharedOfflineModeManager;
}
-(void)dealloc
{
    [_dataBase release];
    [objectsId release];
    [uploadResponder release];
    [super dealloc];
}
-(id)initWithDataBaseName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.dataBase = [[ISDatabase alloc] initWithFileName:name];
        [self.dataBase executeSql:[NSString stringWithFormat:SQLITE_CREATE_TABLE_FOR_OFFLINE_DATA, OFFLINE_TABLE_NAME]];
    }
    return self;
}
-(id)initWithDefaultDataBaseName
{
    self = [super init];
    if (self) {
        self.dataBase = [[ISDatabase alloc] initWithFileName:DEFAULT_DATABASE_NAME];
        [self.dataBase executeSql:[NSString stringWithFormat:SQLITE_CREATE_TABLE_FOR_OFFLINE_DATA, OFFLINE_TABLE_NAME]];
    }
    return self;
}
-(NSString*)GUIDString {
    
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    NSString *result = [NSString stringWithFormat:@"OM-%@", string];
    CFRelease(string);
    return result;
}
-(id)saveObject:(id)object
{
    BinaryStream *binary = [AMFSerializer serializeToBytes:object];
    NSString *data = [Base64 encode:(const uint8_t *)binary.buffer length:binary.size];
    BackendlessEntity *response = [AMFSerializer deserializeFromBytes:binary];
    if (response.objectId.length == 0) {
        response.objectId = [self GUIDString];
    }
    id obj = [self getObjectForId:response.objectId];
    if (!obj) {
        [self saveData:data forKey:response.objectId];
    }
    else
    {
        [self updateData:data forKey:response.objectId];
    }
    return response;
}
-(void)saveData:(NSString *)data forKey:(NSString *)key
{
    [_dataBase executeSql:[NSString stringWithFormat:@"INSERT INTO %@ (object_id, data) VALUES (\"%@\", \"%@\")", OFFLINE_TABLE_NAME, key, data]];
}
-(void)updateData:(NSString *)data forKey:(NSString *)key
{
    [_dataBase executeSql:[NSString stringWithFormat:@"UPDATE %@ SET data = \"%@\" WHERE object_id = \"%@\"", OFFLINE_TABLE_NAME, data, key]];
}
-(id)getObjectForId:(NSString *)objectId
{
    NSArray *objectData = [_dataBase executeSql:[NSString stringWithFormat:@"SELECT data FROM %@ WHERE object_id = \'%@\'", OFFLINE_TABLE_NAME, objectId]];
    if (objectData.count == 0) {
        return nil;
    }
    NSString *str = objectData[0][@"data"];
    NSData *data = [Base64 decode:str];
    BinaryStream *binary = [BinaryStream streamWithStream:(char *)data.bytes andSize:data.length];
    return [AMFSerializer deserializeFromBytes:binary];
}
-(void)startUploadData
{
    if (!uploadResponder) {
        uploadResponder = [[Responder responder:self selResponseHandler:@selector(responseHandler:) selErrorHandler:@selector(errorHandler:)] retain];
    }
    if (!objectsId || (objectsId.count == 0)) {
        [objectsId release];
        objectsId = [[NSMutableArray arrayWithArray:[_dataBase executeSql:[NSString stringWithFormat:@"SELECT object_id FROM %@", OFFLINE_TABLE_NAME]]] retain];
    }
    [self uploadObject];
}
-(void)uploadObject
{
    if (objectsId.count == 0) {
        return;
    }
    BackendlessEntity *object = [self getObjectForId:[objectsId lastObject][@"object_id"]];
    if ([[[object valueForKey:@"objectId"] substringToIndex:2] isEqualToString:@"OM"]) {
        [object setValue:nil forKey:@"objectId"];
    }
    [backendless.persistenceService save:object responder:uploadResponder];
}
-(id)responseHandler:(id)response
{
    [self removeObjectWithObjectId:[objectsId lastObject][@"object_id"]];
    [objectsId removeLastObject];
    if (objectsId.count > 0)
        [self uploadObject];
    return response;
}
-(void)errorHandler:(Fault *)fault
{
//    NSLog(@"%@", fault.detail);
}
-(void)removeObjectWithObjectId:(NSString *)objectId
{
    [_dataBase executeSql:[NSString stringWithFormat:@"DELETE FROM %@ WHERE object_id = \'%@\'", OFFLINE_TABLE_NAME, objectId]];
}
@end
