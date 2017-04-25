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

#define FAULT_NO_FILE_URL [Fault fault:@"File URL is not set" detail:@"File URL is not set" faultCode:@"6900"]
#define FAULT_NO_FILE_NAME [Fault fault:@"File name is not set" detail:@"File name is not set" faultCode:@"6901"]
#define FAULT_NO_DIRECTORY_PATH [Fault fault:@"Directory path is not set" detail:@"Directory path is not set" faultCode:@"6902"]
#define FAULT_NO_FILE_DATA [Fault fault:@"File data is not set" detail:@"File data is not set" faultCode:@"6903"]
#define FAULT_NO_PATTERN [Fault fault:@"Pattern is not set" detail:@"Pattern is not set" faultCode:@"6904"]

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
static NSString *METHOD_COUNT = @"count";


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
-(AsyncResponse *)asyncHttpResponse:(NSURLConnection *)connection;
-(void)processAsyncResponse:(NSURLConnection *)connection;
@end

@implementation FileService

-(id)init {
	if ( (self=[super init]) ) {
        
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.NSArray" mapped:[NSArray class]];
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

-(id)remove:(NSString *)fileURL {
    if (!fileURL || !fileURL.length)
        return [backendless throwFault:FAULT_NO_FILE_URL];
    NSArray *args = [NSArray arrayWithObjects:fileURL, nil];
    return [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_DELETE args:args];
}

-(id)removeDirectory:(NSString *)path {
    if (!path || !path.length)
        return [backendless throwFault:FAULT_NO_DIRECTORY_PATH];    
    NSArray *args = [NSArray arrayWithObjects:path, nil];
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
    NSArray *args = @[path, fileName, content, @(overwrite)];
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
    
    NSArray *args = @[filePathName, content, @(overwrite)];
    NSString *receiveUrl = [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_SAVE_FILE args:args];
    return [BackendlessFile file:receiveUrl];
}

-(NSString *)renameFile:(NSString *)oldPathName newName:(NSString *)newName {
    if (!oldPathName || !oldPathName.length)
        return [backendless throwFault:FAULT_NO_DIRECTORY_PATH];
    if (!newName || !newName.length)
        return [backendless throwFault:FAULT_NO_FILE_NAME];    
    NSArray *args = @[oldPathName, newName];
    return [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_RENAME_FILE args:args];
}

-(NSString *)copyFile:(NSString *)sourcePathName target:(NSString *)targetPathName {
    if (!sourcePathName || !sourcePathName.length || !targetPathName || !targetPathName.length)
        return [backendless throwFault:FAULT_NO_DIRECTORY_PATH];
    NSArray *args = @[sourcePathName, targetPathName];
    return [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_COPY_FILE args:args];
}

-(NSString *)moveFile:(NSString *)sourcePathName target:(NSString *)targetPathName {
    if (!sourcePathName || !sourcePathName.length || !targetPathName || !targetPathName.length)
        return [backendless throwFault:FAULT_NO_DIRECTORY_PATH];
    NSArray *args = @[sourcePathName, targetPathName];
    return [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_MOVE_FILE args:args];
}

-(NSArray *)listing:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive {
    return [self listing:path pattern:pattern recursive:recursive pagesize:DEFAULT_PAGE_SIZE offset:DEFAULT_OFFSET];
}

-(NSArray *)listing:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive pagesize:(int)pagesize offset:(int)offset {
    if (!path || !path.length)
        return [backendless throwFault:FAULT_NO_FILE_NAME];
    NSArray *args = @[path, pattern, @(recursive), @(pagesize), @(offset)];
    NSArray *collection = [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_LISTING args:args];
    return collection;
}

-(NSNumber *)exists:(NSString *)path {
    if (!path || !path.length)
        return [backendless throwFault:FAULT_NO_DIRECTORY_PATH];    
    NSArray *args = @[path];
    return [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_EXISTS args:args];
}

-(NSNumber *)getFileCount:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive countDirectories:(BOOL)countDirectories {
    if (!path || !path.length)
        return [backendless throwFault:FAULT_NO_DIRECTORY_PATH];
    if (!pattern || !pattern.length)
        return [backendless throwFault:FAULT_NO_PATTERN];    
    NSArray *args = @[path, pattern, @(recursive), @(countDirectories)];
    return [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_COUNT args:args];
}

-(NSNumber *)getFileCount:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive {
    return [self getFileCount:path pattern:pattern recursive:recursive countDirectories:NO];
}

-(NSNumber *)getFileCount:(NSString *)path pattern:(NSString *)pattern {
    return [self getFileCount:path pattern:pattern recursive:NO countDirectories:NO];
}

-(NSNumber *)getFileCount:(NSString *)path {
    return [self getFileCount:path pattern:@"*"];
}

// async methods with responder

-(void)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content overwriteIfExist:(BOOL)overwrite responder:(id <IResponder>)responder {
    if (!path || !path.length)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];
    if (!fileName || !fileName.length)
        return [responder errorHandler:FAULT_NO_FILE_NAME];
    if (!content|| !content.length)
        return [responder errorHandler:FAULT_NO_FILE_DATA];
    NSArray *args = @[path, fileName, content, @(overwrite)];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(saveFileResponse:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_SAVE_FILE args:args responder:_responder];
}

-(void)saveFile:(NSString *)filePathName content:(NSData *)content overwriteIfExist:(BOOL)overwrite responder:(id <IResponder>)responder {
    if (!filePathName || !filePathName.length)
        return [responder errorHandler:FAULT_NO_FILE_NAME];
    if (!content|| !content.length)
        return [responder errorHandler:FAULT_NO_FILE_DATA];    
    NSArray *args = @[filePathName, content, @(overwrite)];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(saveFileResponse:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_SAVE_FILE args:args responder:_responder];
}

-(void)listing:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive pagesize:(int)pagesize offset:(int)offset responder:(id <IResponder>)responder {
    if (!path || !path.length)
        return [responder errorHandler:FAULT_NO_FILE_NAME];
    NSArray *args = @[path, pattern, @(recursive), @(pagesize), @(offset)];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getListing:) selErrorHandler:nil];
    _responder.chained = responder;
    _responder.context = [BackendlessSimpleQuery query:pagesize offset:offset];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_LISTING args:args responder:_responder];
}

-(void)getFileCount:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive countDirectories:(BOOL)countDirectories responder:(id <IResponder>)responder {
    if (!path || !path.length)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];
    if (!pattern || !pattern.length)
        return [responder errorHandler:FAULT_NO_PATTERN];    
    NSArray *args = @[path, pattern, @(recursive), @(countDirectories)];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_COUNT args:args responder:responder];
}

// async methods with block-base callbacks

-(void)remove:(NSString *)fileURL response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!fileURL || !fileURL.length)
        return [responder errorHandler:FAULT_NO_FILE_URL];
    NSArray *args = [NSArray arrayWithObjects:fileURL, nil];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_DELETE args:args responder:responder];
}

-(void)removeDirectory:(NSString *)path response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!path || !path.length)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];
    NSArray *args = [NSArray arrayWithObjects:path, nil];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_DELETE args:args responder:responder];
}

-(void)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self saveFile:path fileName:fileName content:content overwriteIfExist:NO responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content overwriteIfExist:(BOOL)overwrite response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self saveFile:path fileName:fileName content:content overwriteIfExist:overwrite responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)saveFile:(NSString *)filePathName content:(NSData *)content response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self saveFile:filePathName content:content overwriteIfExist:NO responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)saveFile:(NSString *)filePathName content:(NSData *)content overwriteIfExist:(BOOL)overwrite response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self saveFile:filePathName content:content overwriteIfExist:overwrite responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)renameFile:(NSString *)oldPathName newName:(NSString *)newName response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!oldPathName || !oldPathName.length)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];
    if (!newName || !newName.length)
        return [responder errorHandler:FAULT_NO_FILE_NAME];
    NSArray *args = @[oldPathName, newName];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_RENAME_FILE args:args responder:responder];
}

-(void)copyFile:(NSString *)sourcePathName target:(NSString *)targetPathName response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!sourcePathName || !sourcePathName.length || !targetPathName || !targetPathName.length)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];    
    NSArray *args = @[sourcePathName, targetPathName];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_COPY_FILE args:args responder:responder];
}

-(void)moveFile:(NSString *)sourcePathName target:(NSString *)targetPathName response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!sourcePathName || !sourcePathName.length || !targetPathName || !targetPathName.length)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];    
    NSArray *args = @[sourcePathName, targetPathName];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_MOVE_FILE args:args responder:responder];
}

-(void)listing:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self listing:path pattern:pattern recursive:recursive pagesize:DEFAULT_PAGE_SIZE offset:DEFAULT_OFFSET responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)listing:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive pagesize:(int)pagesize offset:(int)offset response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self listing:path pattern:pattern recursive:recursive pagesize:pagesize offset:offset responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)exists:(NSString *)path response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!path || !path.length)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];
    NSArray *args = @[path];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_EXISTS args:args responder:responder];
}

-(void)getFileCount:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive countDirectories:(BOOL)countDirectories response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getFileCount:path pattern:pattern recursive:recursive countDirectories:countDirectories responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getFileCount:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
     [self getFileCount:path pattern:pattern recursive:recursive countDirectories:NO responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getFileCount:(NSString *)path pattern:(NSString *)pattern response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
     [self getFileCount:path pattern:pattern recursive:NO countDirectories:NO responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getFileCount:(NSString *)path response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {    
    [self getFileCount:path pattern:@"*" recursive:NO countDirectories:NO responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}


#pragma mark -
#pragma mark Private Methods

// callbacks

-(id)saveFileResponse:(id)response {
    return [BackendlessFile file:(NSString *)response];
}

-(id)getListing:(ResponseContext *)response {
    
    NSArray *collection = (NSArray *)response.response;
    //collection.query = response.context;
    return collection;
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


