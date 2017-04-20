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
-(NSURLRequest *)httpUploadRequest:(NSString *)path content:(NSData *)content overwrite:(NSNumber *)overwrite;
-(id)sendUploadRequest:(NSString *)path content:(NSData *)content overwrite:(NSNumber *)overwrite;
-(void)sendUploadRequest:(NSString *)path content:(NSData *)content overwrite:(NSNumber *)overwrite responder:(id <IResponder>)responder;
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

-(BackendlessFile *)upload:(NSString *)path content:(NSData *)content {
    return [self sendUploadRequest:path content:content overwrite:nil];
}

-(BackendlessFile *)upload:(NSString *)path content:(NSData *)content overwrite:(BOOL)overwrite {
    return [self sendUploadRequest:path content:content overwrite:@(overwrite)];
}

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
    //collection.query = [BackendlessSimpleQuery query:pagesize offset:offset];
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
    return [self getFileCount:path pattern:pattern recursive:NO];
}

-(NSNumber *)getFileCount:(NSString *)path {
    return [self getFileCount:path pattern:@"*"];
}

// async methods with responder

-(void)remove:(NSString *)fileURL responder:(id <IResponder>)responder {
    
    if (!fileURL || !fileURL.length)
        return [responder errorHandler:FAULT_NO_FILE_URL];
    
    NSArray *args = [NSArray arrayWithObjects:fileURL, nil];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_DELETE args:args responder:responder];
}

-(void)removeDirectory:(NSString *)path responder:(id <IResponder>)responder {
    
    if (!path || !path.length)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];
    
    NSArray *args = [NSArray arrayWithObjects:path, nil];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_DELETE args:args responder:responder];
}

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

-(void)moveFile:(NSString *)sourcePathName target:(NSString *)targetPathName responder:(id <IResponder>)responder {
    
    if (!sourcePathName || !sourcePathName.length || !targetPathName || !targetPathName.length)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];
    
    NSArray *args = @[sourcePathName, targetPathName];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_MOVE_FILE args:args responder:responder];
}

-(void)listing:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive responder:(id <IResponder>)responder {
    [self listing:path pattern:pattern recursive:recursive pagesize:DEFAULT_PAGE_SIZE offset:DEFAULT_OFFSET responder:responder];
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

-(void)exists:(NSString *)path responder:(id <IResponder>)responder {
    
    if (!path || !path.length)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];
    
    NSArray *args = @[path];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_EXISTS args:args responder:responder];
}

-(void)getFileCount:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive countDirectories:(BOOL)countDirectories responder:(id <IResponder>)responder {
    
    if (!path || !path.length)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];
    
    if (!pattern || !pattern.length)
        return [responder errorHandler:FAULT_NO_PATTERN];
    
    NSArray *args = @[path, pattern, @(recursive), @(countDirectories)];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_COUNT args:args responder:responder];
}

-(void)getFileCount:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive responder:(id <IResponder>)responder {
    [self getFileCount:path pattern:pattern recursive:recursive countDirectories:NO responder:responder];
}

-(void)getFileCount:(NSString *)path pattern:(NSString *)pattern responder:(id <IResponder>)responder {
    [self getFileCount:path pattern:pattern recursive:NO countDirectories:NO responder:responder];
}

-(void)getFileCount:(NSString *)path responder:(id <IResponder>)responder {
    [self getFileCount:path pattern:@"*" recursive:NO countDirectories:NO responder:responder];
}


// async methods with block-base callbacks

-(void)upload:(NSString *)path content:(NSData *)content response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self sendUploadRequest:path content:content overwrite:nil responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)upload:(NSString *)path content:(NSData *)content overwrite:(BOOL)overwrite response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self sendUploadRequest:path content:content overwrite:@(overwrite) responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)remove:(NSString *)fileURL response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self remove:fileURL responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)removeDirectory:(NSString *)path response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self removeDirectory:path responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
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
    [self moveFile:sourcePathName target:targetPathName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)listing:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self listing:path pattern:pattern recursive:recursive responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)listing:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive pagesize:(int)pagesize offset:(int)offset response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self listing:path pattern:pattern recursive:recursive pagesize:pagesize offset:offset responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)exists:(NSString *)path response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self exists:path responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getFileCount:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive countDirectories:(BOOL)countDirectories response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getFileCount:path pattern:pattern recursive:recursive countDirectories:countDirectories responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getFileCount:(NSString *)path pattern:(NSString *)pattern recursive:(BOOL)recursive response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getFileCount:path pattern:pattern recursive:recursive responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getFileCount:(NSString *)path pattern:(NSString *)pattern response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getFileCount:path pattern:pattern responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getFileCount:(NSString *)path response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getFileCount:path responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
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
    //      String urlStr = Backendless.getUrl() + '/' + Backendless.getApplicationId() + '/' + Backendless.getAPIKey() + "/files/" + encodeURL( path ) + "/" + encodeURL( name );

    NSString *url = [NSString stringWithFormat:@"%@/%@/%@/files/%@?overwrite=%@", backendless.hostURL, backendless.appID, backendless.apiKey, path, [overwrite boolValue]?@"true":@"false"];
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
    if (statusCode == 200 && receivedData) {
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


