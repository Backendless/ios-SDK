//
//  RtmpEngine.m
//  CommLibiOS
//
//  Created by Vyacheslav Vdovichenko on 2/15/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import "RtmpEngine.h"
#import "DEBUG.h"
#import "IPendingServiceCall.h"
#import "IPendingServiceCallback.h"
#import "V3Message.h"
#import "ErrMessage.h"
#import "Responder.h"
#import "Header.h"
#import "Packet.h"
#import "WeborbClient.h"
#import "RTMPClient.h"
#include "Call.h"


#pragma mark -
#pragma mark Private ICallbackProcessor Protocol

@protocol ICallbackProcessor <NSObject>
-(void)processV3Message:(V3Message *)v3 responder:(id <IResponder>)responder;
@end


#pragma mark -
#pragma mark Private CallBack Class

@interface CallBack : NSObject <IPendingServiceCallback> {
    id <IResponder> _responder;
    id _processor;
}
-(id)initWithResponder:(id <IResponder>)responder processor:(id)processor;
+(id)callback:(id <IResponder>)responder processor:(id)processor;
@end


#pragma mark -
#pragma mark RtmpEngine Class

@interface RtmpEngine (ICallbackProcessor) <ICallbackProcessor>
@end


@interface RtmpEngine (IRTMPClientDelegate) <IRTMPClientDelegate>
@end


@interface RtmpEngine ()
-(void)defaultInit;
@end


@implementation RtmpEngine
@synthesize client;

-(id)init {	
	if ( (self=[super init]) ) {
        client = nil;
        
        _host = nil;
        _port = 1935;
        _app = nil;
        protocol = nil;
    }
	
	return self;
}

-(id)initWithUrl:(NSString *)url {	
	if ( (self=[super initWithUrl:url]) ) {
        [self defaultInit];
	}
	
	return self;
}

-(id)initWithUrl:(NSString *)url info:(IdInfo *)info {	
	if ( (self=[super initWithUrl:url info:info]) ) {
        [self defaultInit];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog log:@"DEALLOC RtmpEngine"];
    
    if (_host) [_host release];
    if (_app) [_app release];
    if (protocol) [protocol release];
    if (client) [client release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Private Methods

-(void)defaultInit {
	
	[DebLog log:@"RtmpEngine -> defaultInit: url = %@", gatewayUrl];
    
    NSURL *url = [NSURL URLWithString:gatewayUrl];
    _host = [[url host] retain];
    _port = [[url port] intValue];
	_app = [[[url path] substringFromIndex:1] retain];  
    protocol = [[url scheme] retain];
    
    client = [[RTMPClient alloc] init:gatewayUrl];
    client.delegate = self;
}

-(void)receive:(AsyncMessage *)obj {
	
	[DebLog logN:@"RtmpEngine -> receive: obj = %@", obj];
    
    [self receivedMessage:obj];    
}

#pragma mark -
#pragma mark Public Methods

-(void)invoke:(NSString *)className method:(NSString *)methodName args:(NSArray *)args responder:(id <IResponder>)responder {
    
    if (!methodName || !responder)
        return;
    
    [DebLog log:@"RtmpEngine -> invoke: className = '%@', methodname = '%@', args = %@", className, methodName, args];
    
    if (className)
        [self sendRequest:[self createMessageForInvocation:className method:methodName args:args] responder:responder];
    else 
        [client invoke:methodName withArgs:args responder:[CallBack callback:responder processor:nil]];
}

-(void)sendRequest:(V3Message *)v3Msg responder:(id <IResponder>)responder {
    
    if (!v3Msg || !responder)
        return;

    if (!v3Msg.headers) 
        v3Msg.headers = [NSMutableDictionary dictionary];
    
    [DebLog log:@"RtmpEngine -> sendRequest: headers = '%@'\n clientID = '%@'", v3Msg.headers, v3Msg.clientId];
    
    [client flexInvoke:@"SendRequest" message:v3Msg responder:[CallBack callback:responder processor:self]];
}

-(void)stop {
    
    [client removeDelegate:self];
    [client clearPendingCalls];
    
    [super stop];
}

@end


#pragma mark -
#pragma mark ICallbackProcessor Methods 

@implementation RtmpEngine (ICallbackProcessor)

-(void)processV3Message:(V3Message *)v3 responder:(id <IResponder>)responder {
    
    if (!v3)
        return;
    
    if (idInfo) {
        
        if (!idInfo.dsId && v3.headers)
            idInfo.dsId = (NSString *)[v3.headers valueForKey:@"DSId"];
        if (!idInfo.clientId)
            idInfo.clientId = (NSString *)v3.clientId;
        
        [DebLog logN:@"RtmpEngine -> processV3Message: idInfo.dsId = '%@' idInfo.clientId = '%@'", idInfo.dsId, idInfo.clientId];
    }
    
    if (v3.isError) {
        
        ErrMessage *result = (ErrMessage *)v3;
        
        [DebLog log:@"RtmpEngine -> processV3Message: error = %@, detail = %@, faultCode = %@", result.faultString, result.faultDetail, result.faultCode];
        
        Fault *fault = [Fault fault:result.faultString detail:result.faultDetail faultCode:result.faultCode];
        [responder errorHandler:fault];
    }
    else {
        [responder responseHandler:v3];
    }
}

@end

#pragma mark -
#pragma mark IRTMPClientDelegate Methods 

@implementation RtmpEngine (IRTMPClientDelegate)

-(void)connectedEvent {
    [DebLog log:@"RtmpEngine <IRTMPClientDelegate>> connectedEvent\n"];
}

-(void)disconnectedEvent {
    [DebLog log:@"RtmpEngine <IRTMPClientDelegate>> disconnectedEvent\n"];
}

-(void)connectFailedEvent:(int)code description:(NSString *)description {
    [DebLog log:@"RtmpEngine <IRTMPClientDelegate>> connectFailedEvent: %d = %@\n", code, description];
}

-(void)resultReceived:(id <IServiceCall>)call {
    
    NSString *method = [call getServiceMethodName];
    NSArray *args = [call getArguments];
    int status = [call getStatus];
    
    [DebLog log:@"RtmpEngine <IRTMPClientDelegate> resultReceived: status = %d, method = '%@', arguments = %@", status, method, args];
    
    if (status != STATUS_SUCCESS_RESULT) // this call is not a server invoke
        return;
    
    if (![method isKindOfClass:[NSString class]] || [method isEqualToString:@"_error"]) 
        return;
    
    id result = (args.count) ? [args objectAtIndex:0] : nil;
    
    [DebLog logN:@"RtmpEngine <IRTMPClientDelegate> resultReceived: result = %@", result];
    
    SEL selMethod = NSSelectorFromString([NSString stringWithFormat:@"%@:", method]);
    
    if ([self respondsToSelector:selMethod])
        [self performSelector:selMethod withObject:result];
}

@end


#pragma mark -
#pragma mark Private CallBack Class implementation

@implementation CallBack

-(id)initWithResponder:(id <IResponder>)responder processor:(id)processor {
	if ( (self=[super init]) ) {
        _responder = [responder retain];
        _processor = [processor retain];
    }
    
    return self;
}

+(id)callback:(id <IResponder>)responder processor:(id)processor {
    return [[[CallBack alloc] initWithResponder:responder processor:processor] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC CallBack"];
    
    if (_responder) [_responder release];
    if (_processor) [_processor release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark IPendingServiceCallback Methods 

-(void)resultReceived:(id <IPendingServiceCall>)call {
    
    id result = [call getResult];
	
	[DebLog logN:@"CallBack -> resultReceived: result = %@", result];
    
    if (_processor && [_processor conformsToProtocol:@protocol(ICallbackProcessor)]) 
        [_processor processV3Message:(V3Message *)result responder:_responder];
    else 
        [_responder responseHandler:result];
}

-(void)connectFailedEvent:(int)code description:(NSString *)description {
	
    [DebLog log:@"CallBack -> connectFailedEvent: code = %d, description = %@ ", code, description];
    
    NSString *_code = [NSString stringWithFormat:@"%d", code];
    [_responder errorHandler:[Fault fault:[NSString stringWithFormat:@"Error: %d", code] detail:description faultCode:_code]];
}

@end


