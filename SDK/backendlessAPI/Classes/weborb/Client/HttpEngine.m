//
//  HttpEngine.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

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
#define REPEAT_REQUEST_ON 1
#define POLLING_INTERVAL 3.0f

#pragma mark -
#pragma mark AsyncHttpResponse Class

@interface AsyncHttpResponse : NSObject {
    NSMutableData       *receivedData;
    NSHTTPURLResponse   *responseUrl;
    id <IResponder>     responder;
    NSURLRequest        *request;
}
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSHTTPURLResponse *responseUrl;
@property (nonatomic, retain) id <IResponder> responder;
@property (nonatomic, retain) NSURLRequest *request;
@end

@implementation AsyncHttpResponse
@synthesize receivedData, responseUrl, responder, request;

-(id)init {
    if (self = [super init]) {
        receivedData = nil;
        responseUrl = nil;
        responder = nil;
        request = nil;
    }
    return self;
}

@end


#pragma mark -
#pragma mark HttpEngine Class

@implementation HttpEngine

-(id)init {
    if (self = [super init]) {
        asyncResponses = [[NSMutableArray alloc] init];
        isPolling = NO;
    }
    return self;
}

-(id)initWithUrl:(NSString *)url {
    if (self = [super initWithUrl:url]) {
        asyncResponses = [[NSMutableArray alloc] init];
        isPolling = NO;
    }
    return self;
}

-(id)initWithUrl:(NSString *)url info:(IdInfo *)info {
    if (self = [super initWithUrl:url info:info]) {
        asyncResponses = [[NSMutableArray alloc] init];
        isPolling = NO;
    }
    return self;
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC HttpEngine"];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [asyncResponses removeAllObjects];
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
    return [NSData dataWithBytes:data.buffer length:data.size];
}

-(NSData *)createRequest:(V3Message *)v3Msg {
    return [self createRequest:v3Msg headers:nil];
}

-(void)processAsyncAMFResponse:(AsyncHttpResponse *)async {
    id <IResponder> responder = (async.responder) ? async.responder : _responder;
    int statusCode = (int)[async.responseUrl statusCode];
    if (statusCode != 200) {
        [DebLog log:@"HttpEngine -> sendRequest: (SYNC) response with *** INVALID statusCode = '%d'", statusCode];
        NSString *code = [NSString stringWithFormat:@"%d", statusCode];
        NSString *detail = [NSString stringWithFormat:@"HttpEngine: INVALID statusCode %d", statusCode];
        [responder errorHandler:[Fault fault:detail detail:detail faultCode:code]];
        return;
    }
    
    NSString *contentType = [[async.responseUrl allHeaderFields] valueForKey:@"Content-Type"];
    if (!(contentType) || ![contentType isEqualToString:@"application/x-amf"]) {
        NSString *body = [[NSString alloc] initWithData:async.receivedData encoding:NSUTF8StringEncoding];
        [DebLog log:@"HttpEngine -> processAsyncAMFResponse: response with *** INVALID 'Content-Type' = '%@', body = '%@'", contentType, body];
        Fault *fault = [Fault fault:@"HttpEngine: INVALID response 'Content-Type'" detail:contentType faultCode:@"9000"];
        [responder errorHandler:fault];
        return;
    }
    FlashorbBinaryReader *reader = [[FlashorbBinaryReader alloc] initWithStream:(char *)[async.receivedData bytes] andSize:[async.receivedData length]];
    [DebLog log:ON_PRINT_RESPONSE text:@"HttpEngine -> processAsyncAMFResponse: (ASYNC RESPONSE)\n"];
    [reader print:ON_PRINT_RESPONSE];
    Request *responseObject = [RequestParser readMessage:reader];
    NSArray *responseData = [responseObject getRequestBodyData];
    id <ICacheableAdaptingType> type = [responseData objectAtIndex:0];
#if _ReaderReferenceCache_IS_SINGLETON_
    [[ReaderReferenceCache cache] cleanCache];
#endif
    [responder responseHandler:type];
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
    [DebLog logN:@"HttpEngine -> receiveMessages: obj = %@", obj];
    [self sendRequest:[Subscription getCommandMessage:@"2" subTopic:subTopic selector:selector idInfo:idInfo] responder:
     [Responder responder:self selResponseHandler:@selector(pollingResponse:) selErrorHandler:@selector(pollingError:)] repeated:NO];
    dispatch_time_t interval = dispatch_time(DISPATCH_TIME_NOW, 1ull*NSEC_PER_SEC*3);
    dispatch_after(interval, dispatch_get_main_queue(), ^{
        [self receiveMessages:obj];
    });
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
    receivedData = [self sendSynchronousRequest:request returningResponse:&responseUrl error:&error];
#if REPEAT_REQUEST_ON
    while ([self isNSURLErrorDomain:error]) {
        [DebLog log:@"sendRequest: (SYNC) error ='%@'", error];
        sleep(1);
        error = nil;
        receivedData = [self sendSynchronousRequest:request returningResponse:&responseUrl error:&error];
    }
#endif
    [self setNetworkActivityIndicatorOn:NO];
    if (!receivedData) {
        Fault *fault = (error) ? [Fault fault:[error  domain] detail:[error localizedDescription] faultCode:[NSString stringWithFormat:@"%ld",(long)[error code]]] : UNKNOWN_FAULT;
        [DebLog log:@"HttpEngine -> sendRequest: (SYNC) %@", fault];
        return fault;
    }
    int statusCode = (int)[responseUrl statusCode];
    if (statusCode != 200) {
        [DebLog log:@"HttpEngine -> sendRequest: (SYNC) response with *** INVALID statusCode = '%d'", statusCode];
        NSString *code = [NSString stringWithFormat:@"%d", statusCode];
        NSString *detail = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
        return [Fault fault:detail detail:detail faultCode:code];
    }
    NSString *contentType = [[responseUrl allHeaderFields] valueForKey:@"Content-Type"];
    if (!(contentType) || ![contentType isEqualToString:@"application/x-amf"]) {
        NSString *body = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        [DebLog log:@"HttpEngine -> sendRequest: (SYNC) response with *** INVALID 'Content-Type' = '%@', body = '%@'", contentType, body];
        return [Fault fault:@"HttpEngine: INVALID response 'Content-Type'" detail:contentType faultCode:@"9000"];
    }
    FlashorbBinaryReader *reader = [[FlashorbBinaryReader alloc] initWithStream:(char *)[receivedData bytes] andSize:[receivedData length]];
    [DebLog log:ON_PRINT_RESPONSE text:@"HttpEngine -> sendRequest: (SYNC RESPONSE)\n"];
    [reader print:ON_PRINT_RESPONSE];
    Request *responseObject = [RequestParser readMessage:reader];
    NSArray *responseData = [responseObject getRequestBodyData];
    id<IAdaptingType> type = [responseData objectAtIndex:0];
#if _ReaderReferenceCache_IS_SINGLETON_
    [[ReaderReferenceCache cache] cleanCache];
#endif
    return type;
}

//async

-(void)invoke:(NSString *)className method:(NSString *)methodName args:(NSArray *)args responder:(id <IResponder>)responder {
    [self sendRequest:[self createMessageForInvocation:className method:methodName args:args] responder:responder];
}

-(void)sendURLRequest:(NSURLRequest *)request responder:(id <IResponder>)responder repeated:(BOOL)repeated {
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self setNetworkActivityIndicatorOn:YES];
        [DebLog logN:@"HttpEngine -> sendRequest: (SUCSESS) the connection with url: '%@' is created", gatewayUrl];
        AsyncHttpResponse *async = [[AsyncHttpResponse alloc] init];
        async.receivedData = [NSMutableData new];
        async.responder = responder;
        if (response) {
            NSHTTPURLResponse *responseUrl = (NSHTTPURLResponse *)response;
            [async.receivedData setLength:0];
            async.responseUrl = responseUrl;
        }
        if (data) {
            [DebLog logN:@"HttpEngine ->connection didReceiveData: length = %d", [data length]];
            [async.receivedData appendData:data];
        }
        if (error) {
            [self setNetworkActivityIndicatorOn:NO];
#if REPEAT_REQUEST_ON
            if ([self isNSURLErrorDomain:error] && async.request) {
                [DebLog log:@"HttpEngine ->connection didFailWithError: '%@'", error];
                [self repeatURLRequest:async];
                return;
            }
#endif
            Fault *fault = (error) ? [Fault fault:[error domain] detail:[error localizedDescription] faultCode:[NSString stringWithFormat:@"%ld",(long)[error code]]] : UNKNOWN_FAULT;
            [async.responder errorHandler:fault];
        }
        [self processAsyncAMFResponse:async];
    }] resume];
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
        [asyncResponses removeObject:async];
    });
}

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
    __block NSData *blockData = nil;
    @try {
        __block NSURLResponse *blockResponse = nil;
        __block NSError *blockError = nil;
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable subData, NSURLResponse * _Nullable subResponse, NSError * _Nullable subError) {
            blockData = subData;
            blockError = subError;
            blockResponse = subResponse;
            dispatch_group_leave(group);
        }] resume];
        dispatch_group_wait(group,  DISPATCH_TIME_FOREVER);
        *error = blockError;
        *response = blockResponse;
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    } @finally {
        return blockData;
    }
}

@end
