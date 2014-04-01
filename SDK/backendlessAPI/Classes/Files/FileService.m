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

#define FAULT_NO_FILE_URL [Fault fault:@"File URL is not set"]
#define FAULT_NO_DIRECTORY_PATH [Fault fault:@"Directory path is not set"]

// SERVICE NAME
static NSString *SERVER_FILE_SERVICE_PATH = @"com.backendless.services.file.FileService";
// METHOD NAMES
static NSString *METHOD_DELETE = @"deleteFileOrDirectory";


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
-(NSURLRequest *)httpUploadRequest:(NSString *)path content:(NSData *)content;
-(id)sendUploadRequest:(NSString *)path content:(NSData *)content;
-(void)sendUploadRequest:(NSString *)path content:(NSData *)content  responder:(id <IResponder>)responder;
-(AsyncResponse *)asyncHttpResponse:(NSURLConnection *)connection;
-(void)processAsyncResponse:(NSURLConnection *)connection;
@end

@implementation FileService

-(id)init {
	if ( (self=[super init]) ) {
        asyncResponses = [NSMutableArray new];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog log:@"DEALLOC FileService"];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [asyncResponses removeAllObjects];
    [asyncResponses release];
    
	[super dealloc];
}


#pragma mark -
#pragma mark Public Methods

// sync methods

//new

-(BackendlessFile *)upload:(NSString *)path content:(NSData *)content error:(Fault **)fault
{
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
-(BOOL)remove:(NSString *)fileURL error:(Fault **)fault
{
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
-(BOOL)removeDirectory:(NSString *)path error:(Fault **)fault
{
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

//deprecated

-(BackendlessFile *)upload:(NSString *)path content:(NSData *)content {
    return [self sendUploadRequest:path content:content];
}

-(id)remove:(NSString *)fileURL {
    
    if (!fileURL)
        return [backendless throwFault:FAULT_NO_FILE_URL];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, fileURL, nil];
    return [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_DELETE args:args];
    
}

-(id)removeDirectory:(NSString *)path {
    
    if (!path)
        return [backendless throwFault:FAULT_NO_DIRECTORY_PATH];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, path, nil];
    return [invoker invokeSync:SERVER_FILE_SERVICE_PATH method:METHOD_DELETE args:args];
    
}

// async methods with responder

-(void)upload:(NSString *)path content:(NSData *)content responder:(id <IResponder>)responder {
    [self sendUploadRequest:path content:content responder:responder];
}

-(void)remove:(NSString *)fileURL responder:(id <IResponder>)responder {
    
    if (!fileURL)
        return [responder errorHandler:FAULT_NO_FILE_URL];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, fileURL, nil];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_DELETE args:args responder:responder];
}

-(void)removeDirectory:(NSString *)path responder:(id <IResponder>)responder {
    
    if (!path)
        return [responder errorHandler:FAULT_NO_DIRECTORY_PATH];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, path, nil];
    [invoker invokeAsync:SERVER_FILE_SERVICE_PATH method:METHOD_DELETE args:args responder:responder];
}

// async methods with block-base callbacks

-(void)upload:(NSString *)path content:(NSData *)content response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self upload:path content:content responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)remove:(NSString *)fileURL response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self remove:fileURL responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)removeDirectory:(NSString *)path response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self removeDirectory:path responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

#pragma mark -
#pragma mark Private Methods

-(NSURLRequest *)httpUploadRequest:(NSString *)path content:(NSData *)content {
    
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
    NSString *url = [NSString stringWithFormat:@"%@/%@/files/%@", backendless.hostURL, backendless.versionNum, path];
    NSMutableURLRequest *webReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    if (backendless.headers) {
        NSArray *headers = [backendless.headers allKeys];
        for (NSString *header in headers)
        {
//            NSLog(@"%@", [header stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
            [webReq addValue:[backendless.headers valueForKey:header] forHTTPHeaderField:[header stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    [webReq addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    [webReq addValue:[NSString stringWithFormat:@"%ld", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    [webReq setHTTPMethod:@"POST"];
    [webReq setHTTPBody:body];
    
    [DebLog log:@"FileService -> httpUploadRequest: path: '%@', boundary: '%@'\n headers: %@", fileName, boundary, [webReq allHTTPHeaderFields]];
    
    return webReq;
}

// sync request

-(id)sendUploadRequest:(NSString *)path content:(NSData *)content {
    
    NSHTTPURLResponse *responseUrl;
    NSError *error;
    NSURLRequest *webReq = [self httpUploadRequest:path content:content];
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
}

// async request

-(void)sendUploadRequest:(NSString *)path content:(NSData *)content responder:(id <IResponder>)responder {
    
    // create the connection with the request and start the data exchananging
    NSURLRequest *webReq = [self httpUploadRequest:path content:content];
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


