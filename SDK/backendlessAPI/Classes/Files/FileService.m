//
//  FileService.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "FileService.h"
#import "DEBUG.h"
#import "Types.h"
#import "Responder.h"
#import "Backendless.h"
#import "Invoker.h"

#define FAULT_NO_FILE_URL [Fault fault:@"File URL is not set" faultCode:@"6900"]
#define FAULT_NO_FILE_NAME [Fault fault:@"File name is not set" faultCode:@"6901"]
#define FAULT_NO_DIRECTORY_PATH [Fault fault:@"Directory path is not set" faultCode:@"6902"]
#define FAULT_NO_FILE_DATA [Fault fault:@"File data is not set" faultCode:@"6903"]

// SERVICE NAME
static NSString *SERVER_FILE_SERVICE_PATH = @"com.backendless.services.file.FileService";
// METHOD NAMES
static NSString *METHOD_DELETE = @"deleteFileOrDirectory";
static NSString *METHOD_SAVE_FILE = @"saveFile";
static NSString *METHOD_RENAME_FILE = @"renameFile";
static NSString *METHOD_COPY_FILE = @"copyFile";
static NSString *METHOD_MOVE_FILE = @"moveFile";
static NSString *METHOD_LISTING = @"listing";
static NSString *METHOD_EXISTS = @"exists";


#pragma mark -
#pragma mark AsyncResponse Class

@interface AsyncResponse : NSObject {
    NSURLConnection     *connection;
    NSMutableData       *receivedData;
    NSHTTPURLResponse   *responseUrl;
    id <IResponder>     responder;
}
@property (nonatomic, assign) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSHTTPURLResponse *responseUrl;
@property (nonatomic, retain) id <IResponder> responder;
@end

@implementation AsyncResponse
@synthesize connection, receivedData, responseUrl, responder;

-(id)init {
	if ( (self=[super init]) ) {
        connection = nil;
        receivedData = nil;
        responseUrl = nil;
        responder = nil;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC AsyncResponse"];
    
    [receivedData release];
    [responseUrl release];
    [responder release];
	
	[super dealloc];
}

@end


#pragma mark -
#pragma mark FileService Class

@interface FileService () {
    NSMutableArray  *asyncResponses;
}
-(id)saveFileResponse:(id)response;
-(NSURLRequest *)httpUploadRequest:(NSString *)path content:(NSData *)content overwrite:(NSNumber *)overwrite;
-(id)sendUploadRequest:(NSString *)path content:(NSData *)content overwrite:(NSNumber *)overwrite;
-(void)sendUploadRequest:(NSString *)path content:(NSData *)content overwrite:(NSNumber *)overwrite responder:(id <IResponder>)responder;
-(AsyncResponse *)asyncHttpResponse:(NSURLConnection *)connection;
-(void)processAsyncResponse:(NSURLConnection *)connection;
@end

@implementation FileService

-(id)init {
	if ( (self=[super init]) ) {
        
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.BackendlessCollection" mapped:[BackendlessCollection class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.management.files.FileDetailedInfo" mapped:BEFileInfo.class];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.management.files.FileInfo" mapped:BEFileInfo.class];
        
        asyncResponses = [NSMutableArray new];
        _permissions = [FilePermission new];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog log:@"DEALLOC FileService"];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [asyncResponses removeAllObjects];
    [asyncResponses release];
    
    [_permissions release];
    
	[super dealloc];
}


#pragma mark -
#pragma mark Public Methods

// sync methods with fault return (as exception)

-(BackendlessFile *)upload:(NSString *)path content:(NSData *)content {
    return [self sendUploadRequest:path content:content overwrite:nil];
}

-(BackendlessFile *)upload:(NSString *)path content:(NSData *)content overwrite:(BOOL)overwrite {
    return [self sendUploadRequest:path content:content overwrite:@(overwrite)];
}

-(id)remove:(NSString *)fileURL {
    
    if (!fileURL || !fileURL.length)
        return [backendless throwFault:FAULT_NO_FILE_URL];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, fileURL, nil];
    return [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_DELETE args:args];
}

-(id)removeDirectory:(NSString *)path {
    
    if (!path || !path.length)
        return [backendless throwFault:FAULT_NO_DIRECTORY_PATH];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, path, nil];
    return [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_DELETE args:args];
}

-(BackendlessFile *)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content {
    return [self saveFile:path fileName:fileName content:content overwriteIfExist:NO];
}

-(BackendlessFile *)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content overwriteIfExist:(BOOL)overwrite {
    
    if (!path || !path.length)
        return [backendless throwFault:FAULT_NO_DIRECTORY_PATH];
    
    if (!fileName || !fileName.length)
        return [backendless throwFault:FAULT_NO_FILE_NAME];
    
    if (!content || !content.length)
        return [backendless throwFault:FAULT_NO_FILE_DATA];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, path, fileName, content, @(overwrite)];
    NSString *receiveUrl = [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_SAVE_FILE args:args];
    return [BackendlessFile file:receiveUrl];
}

-(BackendlessFile *)saveFile:(NSString *)filePathName content:(NSData *)content {
    return [self saveFile:filePathName content:content overwriteIfExist:NO];
}

-(BackendlessFile *)saveFile:(NSString *)filePathName content:(NSData *)content overwriteIfExist:(BOOL)overwrite {
    
    if (!filePathName || !filePathName.length)
        return [backendless throwFault:FAULT_NO_FILE_NAME];
    
    if (!content || !content.length)
        return [backendless throwFault:FAULT_NO_FILE_DATA];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, filePathName, content, @(overwrite)];
    NSString *receiveUrl = [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_SAVE_FILE args:args];
    return [BackendlessFile file:receiveUrl];
}

-(NSString *)renameFile:(NSString *)oldPathName newName:(NSString *)newName {
    
    if (!oldPathName || !oldPathName.length)
        return [backendless throwFault:FAULT_NO_DIRECTORY_PATH];
    
    if (!newName || !newName.length)
        return [backendless throwFault:FAULT_NO_FILE_NAME];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, oldPathName, newName];
    return [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_RENAME_FILE args:args];
}

-(NSString *)copyFile:(NSString *)sourcePathName target:(NSString *)targetPathName {
    
    if (!sourcePathName || !sourcePathName.length || !targetPathName || !targetPathName.length)
        return [backendless throwFault:FAULT_NO_DIRECTORY_PATH];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, sourcePathName, targetPathName];
    return [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_COPY_FILE args:args];
}

-(NSString *)moveFile:(NSString *)sourcePathName target:(NSString *)targetPathName {
    
    if (!sourcePathName || !sourcePathName.length || !targetPathName || !targetPathName.length)
        return [backendless throwFault:FAULT_NO_DIRECTORY_PATH];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, sourcePathName, targetPathName];
    return [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_MOVE_FILE args:args];
}

-(BackendlessCollection *)listing:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive {
    return [self listing:path pattern:pattern recursive:recursive pagesize:DEFAULT_PAGE_SIZE offset:DEFAULT_OFFSET];
}

-(BackendlessCollection *)listing:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive pagesize:(int)pagesize offset:(int)offset {
    
    if (!path || !path.length)
        return [backendless throwFault:FAULT_NO_FILE_NAME];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, path, pattern, @(recursive), @(pagesize), @(offset)];
    BackendlessCollection *collection = [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_LISTING args:args];
    collection.query = [BackendlessSimpleQuery query:pagesize offset:offset];
    return collection;
}

-(NSNumber *)exists:(NSString *)path {
    
    if (!path || !path.length)
        return [backendless throwFault:FAULT_NO_DIRECTORY_PATH];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, path];
    return [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_EXISTS args:args];
}

// sync methods with fault option

#if OLD_ASYNC_WITH_FAULT

-(BackendlessFile *)upload:(NSString *)path content:(NSData *)content error:(Fault **)fault {
    
    id result = [self upload:path content:content];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(BOOL)remove:(NSString *)fileURL error:(Fault **)fault {
    
    id result = [self remove:fileURL];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return NO;
        }
        (*fault) = result;
        return NO;
    }
    return YES;
}

-(BOOL)removeDirectory:(NSString *)path error:(Fault **)fault {
    
    id result = [self removeDirectory:path];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return NO;
        }
        (*fault) = result;
        return NO;
    }
    return YES;
    
}

-(BackendlessFile *)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content error:(Fault **)fault {
    
    id result = [self saveFile:path fileName:fileName content:content];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(BackendlessFile *)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content overwriteIfExist:(BOOL)overwrite error:(Fault **)fault {
    
    id result = [self saveFile:path fileName:fileName content:content overwriteIfExist:overwrite];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(BackendlessFile *)saveFile:(NSString *)filePathName content:(NSData *)content error:(Fault **)fault {
    
    id result = [self saveFile:filePathName content:content];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(BackendlessFile *)saveFile:(NSString *)filePathName content:(NSData *)content overwriteIfExist:(BOOL)overwrite error:(Fault **)fault {
    
    id result = [self saveFile:filePathName content:content overwriteIfExist:overwrite];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
#else

#if 0 // wrapper for work without exception

id result = nil;
@try {
}
@catch (Fault *fault) {
    result = fault;
}
@finally {
    if ([result isKindOfClass:Fault.class]) {
        if (fault)(*fault) = result;
        return nil;
    }
    return result;
}

#endif

-(BackendlessFile *)upload:(NSString *)path content:(NSData *)content error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self upload:path content:content];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BackendlessFile *)upload:(NSString *)path content:(NSData *)content overwrite:(BOOL)overwrite error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self upload:path content:content overwrite:overwrite];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BOOL)remove:(NSString *)fileURL error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self remove:fileURL];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

-(BOOL)removeDirectory:(NSString *)path error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self removeDirectory:path];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

-(BackendlessFile *)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self saveFile:path fileName:fileName content:content];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BackendlessFile *)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content overwriteIfExist:(BOOL)overwrite error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self saveFile:path fileName:fileName content:content overwriteIfExist:overwrite];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}


-(BackendlessFile *)saveFile:(NSString *)filePathName content:(NSData *)content error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self saveFile:filePathName content:content];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BackendlessFile *)saveFile:(NSString *)filePathName content:(NSData *)content overwriteIfExist:(BOOL)overwrite error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self saveFile:filePathName content:content overwriteIfExist:overwrite];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSString *)renameFile:(NSString *)oldPathName newName:(NSString *)newName error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self renameFile:oldPathName newName:newName];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSString *)copyFile:(NSString *)sourcePathName target:(NSString *)targetPathName error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self copyFile:sourcePathName target:targetPathName];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSString *)moveFile:(NSString *)sourcePathName target:(NSString *)targetPathName error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self moveFile:sourcePathName target:targetPathName];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BackendlessCollection *)listing:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self listing:path pattern:pattern recursive:recursive];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BackendlessCollection *)listing:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive pagesize:(int)pagesize offset:(int)offset error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self listing:path pattern:pattern recursive:recursive pagesize:pagesize offset:offset];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSNumber *)exists:(NSString *)path error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self exists:path];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

#endif

// async methods with responder

-(void)upload:(NSString *)path content:(NSData *)content responder:(id <IResponder>)responder {
    [self sendUploadRequest:path content:content overwrite:nil responder:responder];
}

-(void)upload:(NSString *)path content:(NSData *)content overwrite:(BOOL)overwrite responder:(id <IResponder>)responder {
    [self sendUploadRequest:path content:content overwrite:@(overwrite) responder:responder];
}

-(void)remove:(NSString *)fileURL responder:(id <IResponder>)responder {
    
    if (!fileURL || !fileURL.length)
        return [responder errorHandler:FAULT_NO_FILE_URL];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, fileURL, nil];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_DELETE args:args responder:responder];
}

-(void)removeDirectory:(NSString *)path responder:(id <IResponder>)responder {
    
    if (!path || !path.length)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, path, nil];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_DELETE args:args responder:responder];
}

-(void)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content responder:(id <IResponder>)responder {
    [self saveFile:path fileName:fileName content:content overwriteIfExist:NO responder:responder];
}

-(void)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content overwriteIfExist:(BOOL)overwrite responder:(id <IResponder>)responder {
    
    if (!path || !path.length)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];
    
    if (!fileName || !fileName.length)
        return [responder errorHandler:FAULT_NO_FILE_NAME];
    
    if (!content|| !content.length)
        return [responder errorHandler:FAULT_NO_FILE_DATA];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, path, fileName, content, @(overwrite)];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(saveFileResponse:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_SAVE_FILE args:args responder:_responder];
}

-(void)saveFile:(NSString *)filePathName content:(NSData *)content responder:(id <IResponder>)responder {
    [self saveFile:filePathName content:content overwriteIfExist:NO responder:responder];
}

-(void)saveFile:(NSString *)filePathName content:(NSData *)content overwriteIfExist:(BOOL)overwrite responder:(id <IResponder>)responder {
    
    if (!filePathName || !filePathName.length)
        return [responder errorHandler:FAULT_NO_FILE_NAME];
    
    if (!content|| !content.length)
        return [responder errorHandler:FAULT_NO_FILE_DATA];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, filePathName, content, @(overwrite)];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(saveFileResponse:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_SAVE_FILE args:args responder:_responder];
}

-(void)renameFile:(NSString *)oldPathName newName:(NSString *)newName responder:(id <IResponder>)responder {
    
    if (!oldPathName || !oldPathName.length)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];
    
    if (!newName || !newName.length)
        return [responder errorHandler:FAULT_NO_FILE_NAME];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, oldPathName, newName];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_RENAME_FILE args:args responder:responder];
}

-(void)copyFile:(NSString *)sourcePathName target:(NSString *)targetPathName responder:(id <IResponder>)responder {
    
    if (!sourcePathName || !sourcePathName.length || !targetPathName || !targetPathName.length)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, sourcePathName, targetPathName];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_COPY_FILE args:args responder:responder];
}

-(void)moveFile:(NSString *)sourcePathName target:(NSString *)targetPathName responder:(id <IResponder>)responder {
    
    if (!sourcePathName || !sourcePathName.length || !targetPathName || !targetPathName.length)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, sourcePathName, targetPathName];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_MOVE_FILE args:args responder:responder];
}

-(void)listing:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive responder:(id <IResponder>)responder {
    [self listing:path pattern:pattern recursive:recursive pagesize:DEFAULT_PAGE_SIZE offset:DEFAULT_OFFSET responder:responder];
}

-(void)listing:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive pagesize:(int)pagesize offset:(int)offset responder:(id <IResponder>)responder {
    
    if (!path || !path.length)
        return [responder errorHandler:FAULT_NO_FILE_NAME];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, path, pattern, @(recursive), @(pagesize), @(offset)];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getListing:) selErrorHandler:nil];
    _responder.chained = responder;
    _responder.context = [BackendlessSimpleQuery query:pagesize offset:offset];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_LISTING args:args responder:_responder];
}

-(void)exists:(NSString *)path responder:(id <IResponder>)responder {
    
    if (!path || !path.length)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, path];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_EXISTS args:args responder:responder];
}

// async methods with block-base callbacks

-(void)upload:(NSString *)path content:(NSData *)content response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self upload:path content:content responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)upload:(NSString *)path content:(NSData *)content overwrite:(BOOL)overwrite response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self upload:path content:content overwrite:overwrite responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)remove:(NSString *)fileURL response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self remove:fileURL responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)removeDirectory:(NSString *)path response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self removeDirectory:path responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self saveFile:path fileName:fileName content:content responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content overwriteIfExist:(BOOL)overwrite response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self saveFile:path fileName:fileName content:content overwriteIfExist:overwrite responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)saveFile:(NSString *)filePathName content:(NSData *)content response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self saveFile:filePathName content:content responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)saveFile:(NSString *)filePathName content:(NSData *)content overwriteIfExist:(BOOL)overwrite response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self saveFile:filePathName content:content overwriteIfExist:overwrite responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)renameFile:(NSString *)oldPathName newName:(NSString *)newName response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self renameFile:oldPathName newName:newName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)copyFile:(NSString *)sourcePathName target:(NSString *)targetPathName response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self copyFile:sourcePathName target:targetPathName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)moveFile:(NSString *)sourcePathName target:(NSString *)targetPathName response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self moveFile:sourcePathName target:targetPathName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)listing:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self listing:path pattern:pattern recursive:recursive responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)listing:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive pagesize:(int)pagesize offset:(int)offset response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self listing:path pattern:pattern recursive:recursive pagesize:pagesize offset:offset responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)exists:(NSString *)path response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self exists:path responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

#pragma mark -
#pragma mark Private Methods

// callbacks

-(id)saveFileResponse:(id)response {
    return [BackendlessFile file:(NSString *)response];
}

-(id)getListing:(ResponseContext *)response {
    
    BackendlessCollection *collection = (BackendlessCollection *)response.response;
    collection.query = response.context;
    return collection;
}

//
-(NSURLRequest *)httpUploadRequest:(NSString *)path content:(NSData *)content overwrite:(NSNumber *)overwrite {
    
    NSString *boundary = [backendless GUIDString];
    NSString *fileName = [path lastPathComponent];
    
    // create the request body
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    if (content && [content length]) {
        [body appendData:content];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // create the request
    NSString *url = [NSString stringWithFormat:@"%@/%@/files/%@?overwrite=%@", backendless.hostURL, backendless.versionNum, path, [overwrite boolValue]?@"true":@"false"];
    NSMutableURLRequest *webReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    if (backendless.headers) {
        NSArray *headers = [backendless.headers allKeys];
        for (NSString *header in headers) {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
            [webReq addValue:[backendless.headers valueForKey:header] forHTTPHeaderField:[header stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
#else
            [webReq addValue:[backendless.headers valueForKey:header] forHTTPHeaderField:[header stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]]];
#endif
        }
    }
    
    [webReq addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    [webReq addValue:[NSString stringWithFormat:@"%ld", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    [webReq setHTTPMethod:@"POST"];
    [webReq setHTTPBody:body];
    
    [DebLog log:@"FileService -> httpUploadRequest: path: '%@', boundary: '%@'\nURL: %@\nheaders: %@", fileName, boundary, url, [webReq allHTTPHeaderFields]];
    
    return webReq;
}

// sync request

-(id)sendUploadRequest:(NSString *)path content:(NSData *)content overwrite:(NSNumber *)overwrite {
    
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    
    NSURLRequest *webReq = [self httpUploadRequest:path content:content overwrite:overwrite];
    
    NSHTTPURLResponse *responseUrl;
    NSError *error;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:webReq returningResponse:&responseUrl error:&error];
    
    NSInteger statusCode = [responseUrl statusCode];
    
    [DebLog log:@"FileService -> sendUploadRequest: HTTP status code: %@", @(statusCode)];
    
    if (statusCode == 200 && receivedData)
    {
        NSString *receiveUrl = [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease];
        receiveUrl = [receiveUrl stringByReplacingOccurrencesOfString:@"{\"fileURL\":\"" withString:@""];
        receiveUrl = [receiveUrl stringByReplacingOccurrencesOfString:@"\"}" withString:@""];
        return [BackendlessFile file:receiveUrl];
    }
    Fault *fault = [Fault fault:[NSString stringWithFormat:@"HTTP %@", @(statusCode)] detail:[NSHTTPURLResponse localizedStringForStatusCode:statusCode] faultCode:[NSString stringWithFormat:@"%@", @(statusCode)]];
    return [backendless throwFault:fault];
#else
    return [self saveFile:path content:content overwriteIfExist:(overwrite!=nil)&&overwrite.boolValue];
#endif
}

// async request

-(void)sendUploadRequest:(NSString *)path content:(NSData *)content overwrite:(NSNumber *)overwrite responder:(id <IResponder>)responder {

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    
    // create the connection with the request and start the data exchananging
    NSURLRequest *webReq = [self httpUploadRequest:path content:content overwrite:overwrite];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:webReq delegate:self];
    if (connection) {
        
        [DebLog log:@"FileService -> sendUploadRequest: (SUCSESS) the connection with path: '%@' is created", path];
        
        AsyncResponse *async = [AsyncResponse new];
        // save the connection
        async.connection = connection;
        // create the NSMutableData to hold the received data
        async.receivedData = [NSMutableData new];
        // save the request responder
        async.responder = responder;
        
        [asyncResponses addObject:async];
        
        return;
    }
    
    [DebLog log:@"FileService -> sendUploadRequest: (ERROR) the connection with path: '%@' didn't create", path];
#else
    [self saveFile:path content:content overwriteIfExist:(overwrite!=nil)&&overwrite.boolValue responder:responder];
#endif
}

-(AsyncResponse *)asyncHttpResponse:(NSURLConnection *)connection {
    
    for (AsyncResponse *async in asyncResponses)
        if (async.connection == connection)
            return async;
    
    return nil;
}

-(void)processAsyncResponse:(NSURLConnection *)connection {
    
    AsyncResponse *async = [self asyncHttpResponse:connection];
    
    // all done, release connection, we are ready to rock and roll
    [connection release];
    connection = nil;
    
    if (!async)
        return;
    
    if (async.responder) {
        
        NSInteger statusCode = [async.responseUrl statusCode];
        
        [DebLog log:@"FileService -> processAsyncResponse: HTTP status code: %@", @(statusCode)];
        
        if ((statusCode == 200) && async.receivedData && [async.receivedData length]) {
            
            NSString *path = [[[NSString alloc] initWithData:async.receivedData encoding:NSUTF8StringEncoding] autorelease];
            path = [path stringByReplacingOccurrencesOfString:@"{\"fileURL\":\"" withString:@""];
            path = [path stringByReplacingOccurrencesOfString:@"\"}" withString:@""];
            [async.responder responseHandler:[BackendlessFile file:path]];
        }
        else {
            
            Fault *fault = [Fault fault:[NSString stringWithFormat:@"HTTP %@", @(statusCode)] detail:[NSHTTPURLResponse localizedStringForStatusCode:statusCode] faultCode:[NSString stringWithFormat:@"%@", @(statusCode)]];
            [async.responder errorHandler:fault];
        }
    }
    
    // clean up received data
    [asyncResponses removeObject:async];
    [async release];
}


#pragma mark -
#pragma mark NSURLConnection Delegate Methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse *responseUrl = [(NSHTTPURLResponse *)response copy];
    NSInteger statusCode = [responseUrl  statusCode];
    [DebLog logN:@"FileService -> connection didReceiveResponse: statusCode=%@ ('%@')\nheaders:\n%@", @(statusCode) ,
     [NSHTTPURLResponse localizedStringForStatusCode:statusCode], [responseUrl  allHeaderFields]];
    
    AsyncResponse *async = [self asyncHttpResponse:connection];
    if (!async)
        return;
    
    // connection is starting, clear buffer
    [async.receivedData setLength:0];
    // save response url
    async.responseUrl = responseUrl;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [DebLog logN:@"FileService -> connection didReceiveData: length = %@", @([data length])];
    
    AsyncResponse *async = [self asyncHttpResponse:connection];
    if (!async)
        return;
    
    // data is arriving, add it to the buffer
    [async.receivedData appendData:data];
}

-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError *)error {
    
    [DebLog logN:@"FileService -> connection didFailWithError: '%@'", error];
    
    AsyncResponse *async = [self asyncHttpResponse:connection];
    
    // something went wrong, release connection
    [connection release];
    connection = nil;
    
    if (!async)
        return;
    
    Fault *fault = [Fault fault:[error domain] detail:[error localizedDescription]];
    [async.responder errorHandler:fault];
    
    // clean up received data
    [asyncResponses removeObject:async];
    [async release];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [DebLog logN:@"FileService -> connectionDidFinishLoading"];
    
    // receivedData processing
    [self performSelector:@selector(processAsyncResponse:) withObject:connection afterDelay:0.0f];
}

@end


