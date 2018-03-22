//
//  Responder.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 26.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "Responder.h"
#import "AsyncMessage.h"
#import "DEBUG.h"

static NSString *IT_IS_FAULT = @"It's Fault";
static NSString *EMPTY_STRING = @"";

@implementation Fault
@synthesize message, detail, faultCode, context;

-(id)init {
    
    if ( (self = [super init]) ) {
        message = IT_IS_FAULT;
        detail = EMPTY_STRING;
        faultCode = EMPTY_STRING;
        context = nil;
    }
    
    return self;
}

-(id)initWithMessage:(NSString *)_message {
    
    if ( (self = [super init]) ) {
        message = (_message) ? _message :IT_IS_FAULT;
        detail = EMPTY_STRING;
        faultCode = EMPTY_STRING;
    }
    
    return self;
}

-(id)initWithMessage:(NSString *)_message detail:(NSString *)_detail {
    
    if ( (self = [super init]) ) {
        message = (_message) ? _message : IT_IS_FAULT;
        detail = (_detail) ? _detail : EMPTY_STRING;
        faultCode = EMPTY_STRING;
    }
    
    return self;
}

-(id)initWithMessage:(NSString *)_message faultCode:(NSString *)_faultCode {
    
    if ( (self = [super init]) ) {
        message = (_message) ? _message : IT_IS_FAULT;
        detail = EMPTY_STRING;
        faultCode = (_faultCode) ? _faultCode : EMPTY_STRING;
    }
    
    return self;
}

-(id)initWithMessage:(NSString *)_message detail:(NSString *)_detail faultCode:(NSString *)_faultCode {
    
    if ( (self = [super init]) ) {
        message = (_message) ? _message : IT_IS_FAULT;
        detail = (_detail) ? _detail : EMPTY_STRING;
        faultCode = (_faultCode) ? _faultCode : EMPTY_STRING;
    }
    
    return self;
}

+(id)fault:(NSString *)_message {
    return [[[Fault alloc] initWithMessage:_message] autorelease];
}


+(id)fault:(NSString *)_message detail:(NSString *)_detail {
    return [[[Fault alloc] initWithMessage:_message detail:_detail] autorelease];
}

+(id)fault:(NSString *)_message faultCode:(NSString *)_faultCode {
    return [[[Fault alloc] initWithMessage:_message faultCode:_faultCode] autorelease];
}

+(id)fault:(NSString *)_message detail:(NSString *)_detail faultCode:(NSString *)_faultCode {
    return [[[Fault alloc] initWithMessage:_message detail:_detail faultCode:_faultCode] autorelease];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"FAULT = '%@' [%@] <%@> ", faultCode, message, detail];
}

@end


@implementation SubscribeResponse
@synthesize response, headers;

-(id)init {
    
    if ( (self = [super init]) ) {
        response = [NSNull null];
        headers = [NSDictionary dictionary];
    }
    
    return self;
}

-(id)initWithResponse:(id)_response {
    
    if ( (self = [super init]) ) {
        response = (_response) ? _response : [NSNull null];
        headers = [NSDictionary dictionary];
    }
    
    return self;
}

-(id)initWithResponse:(id)_response heasers:(NSDictionary *)_headers {
    
    if ( (self = [super init]) ) {
        response = (_response) ? _response : [NSNull null];
        headers = (_headers) ? _headers : [NSDictionary dictionary];
    }
    
    return self;
}

+(id)response:(id)_response{
    return [[[SubscribeResponse alloc] initWithResponse:_response] autorelease];
}

+(id)response:(id)_response heasers:(NSDictionary *)_headers {
    return [[[SubscribeResponse alloc] initWithResponse:_response heasers:_headers] autorelease];
}

@end


@implementation ResponseContext
@synthesize response = _response, context = _context;

+(id)response:(id)response context:(id)context {
    
    ResponseContext *rc = [ResponseContext new];
    rc.response = response;
    rc.context = context;
    
    return [rc autorelease];
}

@end


@implementation Responder
@synthesize chained = _chained, context = _context;

-(id)init {
    
    if ( (self = [super init]) ) {
        _responder = nil;
        _responseHandler = nil;
        _errorHandler = nil;
        _chained = nil;
        _context = nil;
    }
    
    return self;
}

-(id)initWithResponder:(id)responder selResponseHandler:(SEL)selResponseHandler selErrorHandler:(SEL)selErrorHandler {
    
    if ( (self = [super init]) ) {
        _responder = [responder retain];
        _responseHandler = selResponseHandler;
        _errorHandler = selErrorHandler;
        _chained = nil;
        _context = nil;
    }
    
    return self;
}

+(id)responder:(id)responder selResponseHandler:(SEL)selResponseHandler selErrorHandler:(SEL)selErrorHandler {
    return [[[Responder alloc] initWithResponder:responder selResponseHandler:selResponseHandler selErrorHandler:selErrorHandler] autorelease];
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC Responder"];
    
    [_responder release];
    [_chained release];
    [_context release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark IResponder Methods

-(id)responseHandler:(id)response {
    
    if (_responder && _responseHandler && [_responder respondsToSelector:_responseHandler])
        response = [_responder performSelector:_responseHandler
                                    withObject:_context?[ResponseContext response:response context:_context]:response];
    if (_chained)
        [_chained responseHandler:response];
    return response;
}

-(void)errorHandler:(Fault *)fault {
    
    fault.context = self;
    if (_responder && _errorHandler && [_responder respondsToSelector:_errorHandler])
        [_responder performSelector:_errorHandler withObject:fault];
    
    fault.context = nil;
    if (_chained)
        [_chained errorHandler:fault];
}

@end


@implementation SubscribeResponder

+(id)responder:(id)responder selResponseHandler:(SEL)selResponseHandler selErrorHandler:(SEL)selErrorHandler {
    return [[[SubscribeResponder alloc] initWithResponder:responder selResponseHandler:selResponseHandler selErrorHandler:selErrorHandler] autorelease];
}

#pragma mark -
#pragma mark IResponder Methods

-(id)responseHandler:(id)response {
    
    [DebLog logN:@"SubscribeResponder -> responseHandler: response = %@", response];
    
    if ([response isMemberOfClass:[AsyncMessage class]]) {
        
        AsyncMessage *message = (AsyncMessage *)response;
        NSArray *bodies = message.body.body;
        
        for (id obj in bodies) {
            if (_responder && _responseHandler && [_responder respondsToSelector:_responseHandler])
                [_responder performSelector:_responseHandler withObject:[SubscribeResponse response:obj heasers:message.headers]];
        }
    }
    else {
        [super responseHandler:response];
    }
    
    return response;
}

@end


typedef void (^ResponseHandlerBlock)(id);
typedef void (^ErrorHandlerBlock)(Fault *);

@interface ResponderBlocksContext () <IResponder>

@property (copy) ResponseHandlerBlock responseBlock;
@property (copy) ErrorHandlerBlock errorBlock;

@end

@implementation ResponderBlocksContext
@synthesize responseBlock, errorBlock;

+(Responder *)responderBlocksContext:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    
    ResponderBlocksContext *blocksContext = [[ResponderBlocksContext new] autorelease];
    blocksContext.responseBlock = responseBlock;
    blocksContext.errorBlock = errorBlock;
    
    return [Responder responder:blocksContext selResponseHandler:@selector(responseHandler:) selErrorHandler:@selector(errorHandler:)];
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC ResponderBlocksContext"];
    
    [responseBlock release];
    [errorBlock release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark IResponder Methods

-(id)responseHandler:(id)response {
    if (self.responseBlock)
        self.responseBlock(response);
    return response;
}

-(void)errorHandler:(Fault *)fault {
    if (self.errorBlock)
        self.errorBlock(fault);
}

@end


