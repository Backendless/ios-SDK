//
//  HttpEngine.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "HttpEngine.h"
#import "DEBUG.h"
#import "Datatypes.h"
#import "BinaryStream.h"
#import "FlashorbBinaryReader.h"
#import "RequestParser.h"
#import "V3Message.h"
#import "ReqMessage.h"
#import "ErrMessage.h"
#import "AsyncMessage.h"
#import "CommandMessage.h"
#import "Request.h"
#import "Body.h"
#import "ConcreteObject.h"
#import "AMFSerializer.h"
#import "WeborbClient.h"
#import "IAdaptingType.h"
#import "Responder.h"
#import "Subscription.h"
#import "ArrayType.h"

#define ON_PRINT_RESPONSE NO
#define _ON_HEADERS_LOG_ NO
#define ON_PRINT_REQUEST 0

#define REPEAT_REQUEST_ON 1
#define POLLING_INTERVAL 3.0f

#pragma mark -
#pragma mark AsyncHttpResponse Class

@interface AsyncHttpResponse : NSObject {
    NSURLConnection     *connection;
    NSMutableData       *receivedData;
    NSHTTPURLResponse   *responseUrl;
    id <IResponder>     responder;
    NSURLRequest        *request;
}
@property (nonatomic, assign) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSHTTPURLResponse *responseUrl;
@property (nonatomic, retain) id <IResponder> responder;
@property (nonatomic, retain) NSURLRequest *request;
@end

@implementation AsyncHttpResponse
@synthesize connection, receivedData, responseUrl, responder, request;

-(id)init {
    if ( (self=[super init]) ) {
        connection = nil;
        receivedData = nil;
        responseUrl = nil;
        responder = nil;
        request = nil;
    }
    
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC AsyncHttpResponse"];
    
    [receivedData release];
    [responseUrl release];
    [responder release];
    [request release];
    
    [super dealloc];
}

@end


#pragma mark -
#pragma mark HttpEngine Class

@implementation HttpEngine

-(id)init {
    if ( (self=[super init]) ) {
        asyncResponses = [[NSMutableArray alloc] init];
        isPolling = NO;
    }
    
    return self;
}

-(id)initWithUrl:(NSString *)url {
    if ( (self=[super initWithUrl:url]) ) {
        asyncResponses = [[NSMutableArray alloc] init];
        isPolling = NO;
    }
    
    return self;
}

-(id)initWithUrl:(NSString *)url info:(IdInfo *)info {
    if ( (self=[super initWithUrl:url info:info]) ) {
        asyncResponses = [[NSMutableArray alloc] init];
        isPolling = NO;
    }
    
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC HttpEngine"];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [asyncResponses removeAllObjects];
    [asyncResponses release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark Private Methods

-(NSData *)createRequest:(V3Message *)v3Msg headers:(NSDictionary *)headers {
    
    [DebLog log:_ON_HEADERS_LOG_ text:@"HttpEngine -> createRequest: v3Msg.headers = %@\n", v3Msg.headers];
    
    NSMutableArray *headersArray = [NSMutableArray array];
    if (headers) {
        NSArray *names = [headers allKeys];
        for (NSString *headerName in names) {
            ConcreteObject *obj = [ConcreteObject objectType:[headers valueForKey:headerName]];
            [headersArray addObject:[MHeader headerWithObject:obj name:headerName]];
        }
    }
    
    NSString *null = @"null";
    Body *body = [Body bodyWithObject:nil serviceURI:null responseURI:null length:-1];
    NSMutableArray *bodiesArray = [NSMutableArray arrayWithObjects:body, nil];
    
    Request *request = [Request request:(float)AMF3 headers:headersArray bodies:bodiesArray];
    [request setResponseBodyData:[NSArray arrayWithObjects:v3Msg, nil]];
    BinaryStream *data = [AMFSerializer serializeToBytes:request];
    
#if ON_PRINT_REQUEST
    [DebLog logY:@"HttpEngine -> createRequest: clientId = '%@'\n%@", v3Msg.clientId, request];
    [data print:YES];
#endif
    
    return [NSData dataWithBytes:data.buffer length:data.size];
}

-(NSData *)createRequest:(V3Message *)v3Msg {
    return [self createRequest:v3Msg headers:nil];
}

-(AsyncHttpResponse *)asyncHttpResponse:(NSURLConnection *)connection {
    
    for (AsyncHttpResponse *async in asyncResponses)
        if (async.connection == connection)
            return async;
    
    return nil;
}


-(void)processAsyncAMFResponse:(AsyncHttpResponse *)async {
    
    id <IResponder> responder = (async.responder) ? async.responder : _responder;
    
    int statusCode = [async.responseUrl statusCode];
    if (statusCode != 200) {
        
        [DebLog log:@"HttpEngine -> sendRequest: (SYNC) response with *** INVALID statusCode = '%d'", statusCode];
        
        NSString *code = [NSString stringWithFormat:@"%d", statusCode];
        NSString *detail = [NSString stringWithFormat:@"HttpEngine: INVALID statusCode %d", statusCode];
        [responder errorHandler:[Fault fault:detail detail:detail faultCode:code]];
        
        // clean up received data
        [async release];
        return;
    }
    
    NSString *contentType = [[async.responseUrl allHeaderFields] valueForKey:@"Content-Type"];
    if (!(contentType) || ![contentType isEqualToString:@"application/x-amf"]) {
        
        NSString *body = [[[NSString alloc] initWithData:async.receivedData encoding:NSUTF8StringEncoding] autorelease];
        
        [DebLog log:@"HttpEngine -> processAsyncAMFResponse: response with *** INVALID 'Content-Type' = '%@', body = '%@'", contentType, body];
        
        Fault *fault = [Fault fault:@"HttpEngine: INVALID response 'Content-Type'" detail:contentType faultCode:@"9000"];
        [responder errorHandler:fault];
        
        // clean up received data
        [async release];
        return;
    }
    
    FlashorbBinaryReader *reader = [[FlashorbBinaryReader alloc]
                                    initWithStream:(char *)[async.receivedData bytes] andSize:[async.receivedData length]];
    
    [DebLog log:ON_PRINT_RESPONSE text:@"HttpEngine -> processAsyncAMFResponse: (ASYNC RESPONSE)\n"];
    [reader print:ON_PRINT_RESPONSE];
    
    Request *responseObject = [RequestParser readMessage:reader];
    NSArray *responseData = [responseObject getRequestBodyData];
    id <ICacheableAdaptingType> type = [responseData objectAtIndex:0];
    V3Message *v3 = (V3Message *)[type defaultAdapt];
#if _ReaderReferenceCache_IS_SINGLETON_
    [[ReaderReferenceCache cache] cleanCache];
#endif
    [reader release];
    
    [DebLog log:ON_PRINT_RESPONSE text:@"HttpEngine -> processAsyncAMFResponse: type: %@, type.typedObject = '%@', v3 = '%@'", type, [type getCacheKey], v3];
    
    if (v3) {
        if (idInfo) {
            if (!idInfo.dsId && v3.headers)
                idInfo.dsId = (NSString *)v3.headers[@"DSId"];
            if (!idInfo.clientId)
                idInfo.clientId = (NSString *)v3.clientId;
            
            [DebLog logN:@"@@@@@ idInfo: dsId = '%@', clientId = '%@', destination = '%@'", idInfo.dsId, idInfo.clientId, idInfo.destination];
        }
        
        if (v3.isError) {
            
            //typing and sent to delegate
            ErrMessage *result = (ErrMessage *)v3;
            Fault *fault = [Fault fault:result.faultString detail:result.faultDetail faultCode:result.faultCode];
            [responder errorHandler:fault];
        }
        else {
            
            id result = v3.body.body;
            
            [DebLog log:_ON_HEADERS_LOG_ text:@"HttpEngine -> processAsyncAMFResponse: v3.headers = %@\n", v3.headers];
            [DebLog logN:@"HttpEngine -> processAsyncAMFResponse: type = %@, returnValue: %@", [result class], result];
            
            [responder responseHandler:result];
        }
    }
    
    // clean up received data
    [async release];
}

-(void)pollingResponse:(id)result {
    
    [DebLog logN:@"HttpEngine -> pollingResponse: result = %@", result];
    
    if (!result)
        return;
    
    NSArray *arr = ([result isKindOfClass:[ArrayType class]]) ? [(ArrayType *)result getArray] :
    ([result isKindOfClass:[NSArray class]]) ? (NSArray *)result : nil;
    
    if (!arr)
        return;
    
    [DebLog logN:@"HttpEngine -> pollingResponse: async array count = %d", arr.count];
    
    for (id async in arr) {
        if ([async isMemberOfClass:[AsyncMessage class]])
            [self receivedMessage:async];
    }
}

-(void)pollingError:(Fault *)fault {
    
    if (!fault)
        return;
    
    [DebLog logN:@"HttpEngine -> pollingError: %@", fault];
    
    [(id <IResponder>)_responder errorHandler:fault];
}

-(void)receiveMessages:(id)obj {
    
    //printf("\n############################################### NEW POLLING #################################################\n\n");
    
    [DebLog logN:@"HttpEngine -> receiveMessages: obj = %@", obj];
    
    [self sendRequest:[Subscription getCommandMessage:@"2" subTopic:subTopic selector:selector idInfo:idInfo] responder:
     [Responder responder:self selResponseHandler:@selector(pollingResponse:) selErrorHandler:@selector(pollingError:)] repeated:NO];
    
#if 1
    dispatch_time_t interval = dispatch_time(DISPATCH_TIME_NOW, 1ull*NSEC_PER_SEC*3);
    dispatch_after(interval, dispatch_get_main_queue(), ^{
        [self receiveMessages:obj];
    });
#else
    [self performSelector:@selector(receiveMessages:) withObject:obj afterDelay:POLLING_INTERVAL];
#endif
}

-(NSURLRequest *)httpPostRequest:(V3Message *)v3Msg {
    
    // create the request
    NSURL *url = [NSURL URLWithString:gatewayUrl];
    NSMutableURLRequest *webReq = [NSMutableURLRequest requestWithURL:url];
    [webReq addValue:@"application/x-amf" forHTTPHeaderField:@"Content-Type"];
    
    if (httpHeaders) {
        NSArray *headers = [httpHeaders allKeys];
        for (NSString *header in headers)
            [webReq addValue:[httpHeaders valueForKey:header] forHTTPHeaderField:header];
    }
    
    [webReq setHTTPMethod:@"POST"];
    [webReq setHTTPBody:[self createRequest:v3Msg]];
    
    [DebLog logN:@"HttpEngine -> httpPostRequest: url: %@,  headers: %@", url, [webReq allHTTPHeaderFields]];
    
    return webReq;
}

-(BOOL)isNSURLErrorDomain:(NSError *)error {
    
    if (error && [error.domain isEqualToString:@"NSURLErrorDomain"]) {
        
#if 0 // TEMP check
        if (error.code == -1009)
            return YES;
#endif
        
        const NSInteger errorCodes[] = {-1001, -1003, -1004, -1005};
        for (int i = 0; i < 4; i++) {
            if (error.code == errorCodes[i])
                return YES;
        }
    }
    return NO;
}

#pragma mark -
#pragma mark Public Methods

// sync

-(id)invoke:(NSString *)className method:(NSString *)methodName args:(NSArray *)args {
    return [self sendRequest:[self createMessageForInvocation:className method:methodName args:args]];
}

-(id)sendRequest:(V3Message *)v3Msg {
    
    NSHTTPURLResponse *responseUrl;
    NSError *error = nil;
    NSData *receivedData;
    NSURLRequest *request = [self httpPostRequest:v3Msg];
    
    [self setNetworkActivityIndicatorOn:YES];
    
    receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseUrl error:&error];
    
#if REPEAT_REQUEST_ON
    while ([self isNSURLErrorDomain:error]) {
        
        [DebLog log:@"sendRequest: (SYNC) error ='%@'", error];
        
        sleep(1);
        
        error = nil;
        receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseUrl error:&error];
    }
#endif
    
    [self setNetworkActivityIndicatorOn:NO];
    
    if (!receivedData) {
        Fault *fault = (error) ? [Fault fault:[error  domain] detail:[error localizedDescription] faultCode:[NSString stringWithFormat:@"%ld",(long)[error code]]] : UNKNOWN_FAULT;
        [DebLog log:@"HttpEngine -> sendRequest: (SYNC) %@", fault];
        return fault;
    }
    
    int statusCode = [responseUrl statusCode];
    if (statusCode != 200) {
        
        [DebLog log:@"HttpEngine -> sendRequest: (SYNC) response with *** INVALID statusCode = '%d'", statusCode];
        
        NSString *code = [NSString stringWithFormat:@"%d", statusCode];
        NSString *detail = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
        return [Fault fault:detail detail:detail faultCode:code];
    }
    
    NSString *contentType = [[responseUrl allHeaderFields] valueForKey:@"Content-Type"];
    if (!(contentType) || ![contentType isEqualToString:@"application/x-amf"]) {
        
        NSString *body = [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease];
        
        [DebLog log:@"HttpEngine -> sendRequest: (SYNC) response with *** INVALID 'Content-Type' = '%@', body = '%@'", contentType, body];
        
        return [Fault fault:@"HttpEngine: INVALID response 'Content-Type'" detail:contentType faultCode:@"9000"];
    }
    
    FlashorbBinaryReader *reader = [[FlashorbBinaryReader alloc]
                                    initWithStream:(char *)[receivedData bytes] andSize:[receivedData length]];
    
    [DebLog log:ON_PRINT_RESPONSE text:@"HttpEngine -> sendRequest: (SYNC RESPONSE)\n"];
    [reader print:ON_PRINT_RESPONSE];
    
    Request *responseObject = [RequestParser readMessage:reader];
    NSArray *responseData = [responseObject getRequestBodyData];
    id <IAdaptingType> type = [responseData objectAtIndex:0];
    V3Message *v3 = (V3Message *)[type defaultAdapt];
#if _ReaderReferenceCache_IS_SINGLETON_
    [[ReaderReferenceCache cache] cleanCache];
#endif
    [reader release];
    
    [DebLog log:ON_PRINT_RESPONSE text:@"HttpEngine -> sendRequest: (SYNC) type: %@, type.defaultAdapt = '%@', v3 = '%@'", type, [v3 class], v3];
    
    if (v3) {
        if (idInfo) {
            
            if (!idInfo.dsId && v3.headers)
                idInfo.dsId = (NSString *)v3.headers[@"DSId"];
            if (!idInfo.clientId)
                idInfo.clientId = (NSString *)v3.clientId;
            
            [DebLog logN:@"@@@@@ idInfo (2): dsId = '%@', clientId = '%@', destination = '%@'", idInfo.dsId, idInfo.clientId, idInfo.destination];
        }
        
        if (v3.isError) {
            
            //typing and sent to delegate
            ErrMessage *result = (ErrMessage *)v3;
            
            [DebLog log:@"HttpEngine -> sendRequest: (SYNC) isError = YES, result: %@", result];
            
            return [Fault fault:result.faultString detail:result.faultDetail faultCode:result.faultCode];
        }
        else {
            
            id result = v3.body.body;
            
            [DebLog log:_ON_HEADERS_LOG_ text:@"HttpEngine -> sendRequest: v3.headers = %@\n", v3.headers];
            [DebLog log:@"HttpEngine -> sendRequest: (SYNC) type = %@, returnValue: %@", [result class], result];
            
            return result;
        }
    }
    
    return UNKNOWN_FAULT;
}

//async

-(void)invoke:(NSString *)className method:(NSString *)methodName args:(NSArray *)args responder:(id <IResponder>)responder {
    [self sendRequest:[self createMessageForInvocation:className method:methodName args:args] responder:responder];
}

-(void)sendURLRequest:(NSURLRequest *)request responder:(id <IResponder>)responder repeated:(BOOL)repeated {
    
    // create the connection with the request and start the data exchananging
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        
        [self setNetworkActivityIndicatorOn:YES];
        
        [DebLog logN:@"HttpEngine -> sendRequest: (SUCSESS) the connection with url: '%@' is created", gatewayUrl];
        
        AsyncHttpResponse *async = [[AsyncHttpResponse alloc] init];
        // save the connection
        async.connection = connection;
        // create the NSMutableData to hold the received data
        async.receivedData = [[[NSMutableData alloc] init] autorelease];
        // save the request responder
        async.responder = responder;
#if REPEAT_REQUEST_ON
        // save the request message
        async.request = repeated?request:nil;
#endif
        
        [asyncResponses addObject:async];
    }
    else {
        [DebLog logY:@"HttpEngine -> sendRequest: (ERROR) the connection with url: '%@' didn't create", gatewayUrl];
    }
}

-(void)sendRequest:(V3Message *)v3Msg responder:(id <IResponder>)responder {
    [self sendURLRequest:[self httpPostRequest:v3Msg] responder:responder repeated:YES];
}

-(void)sendRequest:(V3Message *)v3Msg responder:(id <IResponder>)responder repeated:(BOOL)repeated {
    [self sendURLRequest:[self httpPostRequest:v3Msg] responder:responder repeated:repeated];
}

-(void)onSubscribed:(NSString *)_subTopic selector:(NSString *)_selector responder:(id <IResponder>)responder {
    
    [DebLog logN:@"HttpEngine -> onSubscribed: subtopic = %@, selector = %@", _subTopic, _selector];
    
    [super onSubscribed:_subTopic selector:_selector responder:responder];
    
    if (isPolling)
        return;
    
    [self receiveMessages:nil];
    isPolling = YES;
}

-(void)onUnsubscribed {
    
    [DebLog logN:@"HttpEngine -> onUnsubscribed"];
    
    if (!isPolling)
        return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    isPolling = NO;
}


-(void)repeatURLRequest:(AsyncHttpResponse *)async {
    
    dispatch_time_t interval = dispatch_time(DISPATCH_TIME_NOW, 1ull*NSEC_PER_SEC*5);
    dispatch_after(interval, dispatch_get_main_queue(), ^{
        
        [self sendURLRequest:async.request responder:async.responder repeated:YES];
        
        // clean up received data
        [asyncResponses removeObject:async];
        [async release];
    });
}


#pragma mark -
#pragma mark NSURLConnection Delegate Methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    AsyncHttpResponse *async = [self asyncHttpResponse:connection];
    if (!async)
        return;
    
    NSHTTPURLResponse *responseUrl = (NSHTTPURLResponse *)response;
#if 0
    int statusCode = [responseUrl  statusCode];
    [DebLog logY:@"HttpEngine ->connection didReceiveResponse: statusCode=%d ('%@')\nheaders:\n%@", statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode], [responseUrl  allHeaderFields]];
#endif
    // connection is starting, clear buffer
    [async.receivedData setLength:0];
    // save response url
    async.responseUrl = responseUrl;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    AsyncHttpResponse *async = [self asyncHttpResponse:connection];
    if (!async)
        return;
    
    [DebLog logN:@"HttpEngine ->connection didReceiveData: length = %d", [data length]];
    
    // data is arriving, add it to the buffer
    [async.receivedData appendData:data];
}

-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError *)error {
    
    [self setNetworkActivityIndicatorOn:NO];
    
    AsyncHttpResponse *async = [self asyncHttpResponse:connection];
    if (!async)
        return;
    
    // something went wrong, release connection
    [connection release];
    connection = nil;
    
#if REPEAT_REQUEST_ON
    if ([self isNSURLErrorDomain:error] && async.request) {
        
        [DebLog log:@"HttpEngine ->connection didFailWithError: '%@'", error];
        
        [self repeatURLRequest:async];
        return;
    }
#endif
    
    Fault *fault = (error) ? [Fault fault:[error domain] detail:[error localizedDescription] faultCode:[NSString stringWithFormat:@"%ld",(long)[error code]]] : UNKNOWN_FAULT;
    [async.responder errorHandler:fault];
    
    // clean up received data
    [asyncResponses removeObject:async];
    [async release];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [self setNetworkActivityIndicatorOn:NO];
    
    AsyncHttpResponse *async = [self asyncHttpResponse:connection];
    if (!async)
        return;
    
    // all done, release connection
    [connection release];
    connection = nil;
    
    [DebLog logN:@"HttpEngine -> connectionDidFinishLoading: receivedData.length = %d, responder = %@", (async.receivedData)?[async.receivedData length]:-1, async.responder];
    
    [asyncResponses removeObject:async];
    if (!async.receivedData || ![async.receivedData length]) {
        // clean up received data
        [async release];
        return;
    }
    
    // receivedData processing
    dispatch_async( dispatch_get_main_queue(), ^{
        [self processAsyncAMFResponse:async];
    });
}

@end
