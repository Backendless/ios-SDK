//
//  Engine.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <UIKit/UIKit.h>
#endif

#import "Engine.h"
#import "DEBUG.h"
#import "WeborbClient.h"
#import "HttpEngine.h"
#import "V3Message.h"
#import "AsyncMessage.h"
#import "ErrMessage.h"
#import "ReqMessage.h"
#import "Responder.h"
#import "Subscription.h"


@interface Engine (ISubscribedHandler) <ISubscribedHandler>
@end


@interface Engine ()
-(void)_defaultInit;
@end


@implementation Engine
@synthesize subscribedHandler, idInfo, requestHeaders, httpHeaders, networkActivityIndicatorOn;

-(id)init {	
	if ( (self=[super init]) ) {
        [self _defaultInit];
	}
	
	return self;
}

-(id)initWithUrl:(NSString *)url {	
	if ( (self=[super init]) ) {
        [self _defaultInit];
        gatewayUrl = [url retain];
	}
	
	return self;
}

-(id)initWithUrl:(NSString *)url info:(IdInfo *)info {	
	if ( (self=[super init]) ) {
        [self _defaultInit];
        gatewayUrl = [url retain];
        idInfo = info;
	}
	
	return self;
}

+(id)create:(NSString *)url {
    
    NSURL *_url = [NSURL URLWithString:url];
    NSString *scheme = [_url scheme];
	
    [DebLog log:@"Engine -> create: scheme = %@, app = %@", scheme, [[_url path] substringFromIndex:1]];
    
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"])
        return [[HttpEngine alloc] initWithUrl:url];
    
    return nil;
}

+(id)create:(NSString *)url info:(IdInfo *)info {
    
    NSURL *_url = [NSURL URLWithString:url];
    NSString *scheme = [_url scheme];
	
    [DebLog log:@"Engine -> create: scheme = %@, app = %@, destination = %@", scheme, [[_url path] substringFromIndex:1], info.destination];
    
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"])
        return [[HttpEngine alloc] initWithUrl:url info:info];
    
    return nil;
}

-(void)dealloc {
	
	[DebLog log:@"DEALLOC Engine"];
    
    if (subscribedHandler)
        [subscribedHandler release];
    
    if (gatewayUrl) [gatewayUrl release];
    if (subTopic) [subTopic release];
    if (selector) [selector release];
    if (_responder) [_responder release];
    
    if (requestHeaders) [requestHeaders release];
    if (httpHeaders) [httpHeaders release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Private Methods

-(void)_defaultInit {
	
	[DebLog logN:@"Engine -> _defaultInit"];
    
    subscribedHandler = nil;
    idInfo = nil;
    
    gatewayUrl = nil;
    subTopic = nil;
    selector = nil;
    _responder = nil;
    
    requestHeaders = nil;
    httpHeaders = nil;
    
    networkActivityIndicatorOn = NO;
}

#pragma mark -
#pragma mark Public Methods

-(void)setNetworkActivityIndicator:(BOOL)value {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    if (networkActivityIndicatorOn) [UIApplication sharedApplication].networkActivityIndicatorVisible = value;
#endif
}

// sync

static NSString *NOT_IMPLEMENTED = @"This method is not implemented";

-(id)invoke:(NSString *)className method:(NSString *)methodName args:(NSArray *)args {
    return [Fault fault:NOT_IMPLEMENTED detail:NOT_IMPLEMENTED faultCode:@"-9998"];
}

-(id)sendRequest:(V3Message *)v3Msg {
    return [Fault fault:NOT_IMPLEMENTED detail:NOT_IMPLEMENTED faultCode:@"-9998"];
}

//async

-(void)invoke:(NSString *)className method:(NSString *)methodName args:(NSArray *)args responder:(id <IResponder>)responder {
}

-(void)sendRequest:(V3Message *)v3Msg responder:(id <IResponder>)responder {
}

-(void)onSubscribed:(NSString *)_subTopic selector:(NSString *)_selector responder:(id <IResponder>)responder {
    
    [self subscribed:[Subscription getIdBySubTopicSelector:_subTopic selector:_selector]];
    
    if (subTopic) [subTopic release];
    subTopic = [_subTopic retain];
    
    if (selector) [selector release];
    selector = [_selector retain];
    
    if (_responder) [_responder release];
    _responder = [responder retain];
}

-(void)onUnsubscribed {
	
    [DebLog logN:@"Engine -> onUnsubscribed"];
    
    if (subscribedHandler)
        [subscribedHandler release];
    subscribedHandler = nil;
}

-(void)stop {
    [self onUnsubscribed];
}

// "protected" (for inside usage)

-(void)receivedMessage:(AsyncMessage *)message {

    if (!_responder || ![_responder conformsToProtocol:@protocol(IResponder)])
        return;
    
    id <IResponder> responder = (id <IResponder>)_responder;
    
    if (message.isError) {
        
        ErrMessage *result = (ErrMessage *)message;
        
        [DebLog logN:@"Engine -> receivedMessage: error = %@, detail = %@, faultCode = %@", result.faultString, result.faultDetail, result.faultCode];
        
        Fault *fault = [Fault fault:result.faultString detail:result.faultDetail faultCode:result.faultCode];
        [responder errorHandler:fault];
        
        return;
    }
   
	[DebLog log:@"Engine -> receivedMessage: responder class = %@\nheaders = %@, \nbody = %@", [responder class], message.headers, message.body.body];

    //[responder responseHandler:obj];
    [responder responseHandler:message];
}

-(V3Message *)createMessageForInvocation:(NSString *)className method:(NSString *)methodName args:(NSArray *)args {
    
    ReqMessage *bodyMessage = [[[ReqMessage alloc] init] autorelease];
    bodyMessage.body = [[[BodyHolder alloc] init] autorelease];
    bodyMessage.body.body = (args) ? args : [NSArray array];
    bodyMessage.destination = idInfo.destination;
    if (className)
        bodyMessage.source = className;
    bodyMessage.operation = methodName;
    if (requestHeaders)
        bodyMessage.headers = requestHeaders;
    
    return bodyMessage;
}

-(V3Message *)createMessageForInvocation:(NSString *)methodName args:(NSArray *)args {
    return [self createMessageForInvocation:nil method:methodName args:args];
}


@end


#pragma mark -
#pragma mark ISubscribedHandler Methods

@implementation Engine (ISubscribedHandler)

-(void)subscribed:(id)info {
    if (subscribedHandler)
        [subscribedHandler subscribed:info];
}

@end

