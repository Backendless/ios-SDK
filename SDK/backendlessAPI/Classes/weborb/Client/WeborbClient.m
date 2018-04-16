//
//  WeborbClient.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "WeborbClient.h"
#import "DEBUG.h"
#import "Engine.h"
#import "HttpEngine.h"
#import "RTMPClient.h"
#import "Types.h"
#import "V3Message.h"
#import "ReqMessage.h"
#import "AckMessage.h"
#import "AsyncMessage.h"
#import "ErrMessage.h"
#import "CommandMessage.h"
#import "ObjectFactories.h"
#import "BodyHolderFactory.h"
#import "Responder.h"
#import "Subscription.h"


@interface WeborbClient ()
-(void)defaultInit;
@end


@implementation WeborbClient
@synthesize subscribedHandler;

-(id)init {
	
    if ( (self=[super init]) ) {
        [self defaultInit];
	}
	
	return self;
}

-(id)initWithUrl:(NSString *)gatewayURL {
	
    if ( (self=[super init]) ) {
        [self defaultInit];
        
        engine = [Engine create:gatewayURL info:idInfo];
	}
	
	return self;
}

-(id)initWithUrl:(NSString *)gatewayURL destination:(NSString *)destination {
    
    if ( (self=[super init]) ) {
        [self defaultInit];
        if (destination)
            idInfo.destination = destination;
        
        engine = [Engine create:gatewayURL info:idInfo];
        
        [DebLog log:@"WeborbClient -> initWithUrl: engine.retaincount = %d", [engine retainCount]];
	}
	
	return self;

}

-(void)dealloc {
	
	[DebLog log:@"DEALLOC WeborbClient: engine.retaincount = %d", (engine)?[engine retainCount]:0];
    
    if (subscribedHandler)
        [subscribedHandler release];
    
    [idInfo release];
    
    [subscribers removeAllObjects];
    [subscribers release];
    
    if (engine) {
        [engine stop];
        [engine release];
    }
	
	[super dealloc];
}

#pragma mark -
#pragma mark ISubscribedHandler Methods

-(void)subscribed:(id)info {
	
	[DebLog log:@"WeborbClient -> subscribed: %@", info];
    
    if (subscribedHandler)
        [subscribedHandler subscribed:[NSString stringWithFormat:@"%@ is subscribed", info]];
}

-(void)unsubscribed:(id)info {
	
	[DebLog log:@"WeborbClient -> unsubscribed: %@", info];
    
    if (subscribedHandler)
        [subscribedHandler subscribed:[NSString stringWithFormat:@"%@ is unsubscribed", info]];
}

#pragma mark -
#pragma mark Private Methods

-(void)defaultInit {
    
    subscribedHandler = nil;
    engine = nil;
    idInfo = [[IdInfo alloc] init];        
    subscribers = [[NSMutableDictionary alloc] init];
    
    // TYPE MAPPING
    [[Types sharedInstance] addClientClassMapping:@"flex.messaging.messages.AcknowledgeMessage" mapped:[AckMessage class]];
    [[Types sharedInstance] addClientClassMapping:@"flex.messaging.messages.AsyncMessage" mapped:[AsyncMessage class]];
    [[Types sharedInstance] addClientClassMapping:@"flex.messaging.messages.RemotingMessage" mapped:[ReqMessage class]];
    [[Types sharedInstance] addClientClassMapping:@"flex.messaging.messages.CommandMessage" mapped:[CommandMessage class]];
    [[Types sharedInstance] addClientClassMapping:@"flex.messaging.messages.ErrorMessage" mapped:[ErrMessage class]];
    [[ObjectFactories sharedInstance] addArgumentObjectFactory:@"BodyHolder" factory:[BodyHolderFactory factory]];
}

-(BOOL)isActiveSubscriber {
    NSArray *keys = [subscribers allKeys];
    for (id key in keys) {
        Subscription *subscriber = (Subscription *)[subscribers objectForKey:key];
        if (subscriber.isSubscribed)
            return YES;
    }
    return NO;
}

-(void)publishResponseHandler:(id)response {
	[DebLog log:@"WeborbClient -> publishResponseHandler: response = %@", response];    
}

-(void)publishErrorHandler:(Fault *)fault {
	[DebLog log:@"WeborbClient -> publishErrorHandler: %@", fault];
}

-(void)unsubscribeResponseHandler:(id)response {
	
    [DebLog log:@"WeborbClient -> unsubscribeResponseHandler: %@", response];    
    
    [self unsubscribed:response];
    if (![self isActiveSubscriber])
        if (engine) [engine onUnsubscribed];
}

-(void)unsubscribeErrorHandler:(Fault *)fault {
	[DebLog log:@"WeborbClient -> unsubscribeErrorHandler: %@", fault];        
}

#pragma mark -
#pragma mark getters / setters

-(NSMutableDictionary *)getRequestHeaders {
    return (engine) ? engine.requestHeaders : nil;
}

-(void)setRequestHeaders:(NSMutableDictionary *)requestHeaders {
    if (engine) engine.requestHeaders = requestHeaders;
}

-(NSMutableDictionary *)getHttpHeaders {
    return (engine) ? engine.httpHeaders : nil;
}

-(void)setHttpHeaders:(NSMutableDictionary *)httpHeaders {
    if (engine) engine.httpHeaders = httpHeaders;
}

#pragma mark -
#pragma mark Public Methods

-(void)setClientClass:(Class)type forServerType:(NSString *)serverTypeName {
    [[Types sharedInstance] addClientClassMapping:serverTypeName mapped:type];
}

-(void)setNetworkActivityIndicatorOn:(BOOL)value {
    if (engine) engine.networkActivityIndicatorOn = value;
}

// sync invokes

-(id)invoke:(NSString *)methodName args:(NSArray *)args {
    return [self invoke:nil method:methodName args:args];
}

-(id)invoke:(NSString *)className method:(NSString *)methodName args:(NSArray *)args {
    return [engine invoke:className method:methodName args:args];
}

// async invokes

-(void)invoke:(NSString *)methodName args:(NSArray *)args responder:(id <IResponder>)responder {
    [self invoke:nil method:methodName args:args responder:responder];
}

-(void)invoke:(NSString *)className method:(NSString *)methodName args:(NSArray *)args responder:(id <IResponder>)responder {
    [engine invoke:className method:methodName args:args responder:responder];
}

// publish / subscribe

-(void)publish:(id)message {
    [self publish:message responder:nil subtopic:nil headers:nil];
}
-(void)publish:(id)message subtopic:(NSString *)subtopic {
    [self publish:message responder:nil subtopic:subtopic headers:nil];    
}

-(void)publish:(id)message headers:(NSDictionary *)headers {
    [self publish:message responder:nil subtopic:nil headers:headers];
}

-(void)publish:(id)message subtopic:(NSString *)subtopic headers:(NSDictionary *)headers {
    [self publish:message responder:nil subtopic:subtopic headers:headers];
}

-(void)publish:(id)message responder:(id <IResponder>)responder {
    [self publish:message responder:responder subtopic:nil headers:nil];
}

-(void)publish:(id)message responder:(id <IResponder>)responder subtopic:(NSString *)subtopic {
    [self publish:message responder:responder subtopic:subtopic headers:nil];    
}

-(void)publish:(id)message responder:(id <IResponder>)responder headers:(NSDictionary *)headers {
    [self publish:message responder:responder subtopic:nil headers:headers];
}

-(void)publish:(id)message responder:(id <IResponder>)responder subtopic:(NSString *)subtopic headers:(NSDictionary *)headers {
    
    AsyncMessage *asyncMessage;
    
    if ([message isMemberOfClass:[AsyncMessage class]]) {
        asyncMessage = (AsyncMessage *)message;
    }
    else {
        asyncMessage = [[[AsyncMessage alloc] init] autorelease];
        asyncMessage.body = [[[BodyHolder alloc] init] autorelease];
        asyncMessage.body.body = message;
    }
    
    asyncMessage.destination = idInfo.destination;
    asyncMessage.clientId = idInfo.clientId;
    asyncMessage.messageId = [[NSProcessInfo processInfo] globallyUniqueString];
    
    [DebLog log:@"WeborbClient -> publish: body = '%@', clientId = '%@'", asyncMessage.body.body, asyncMessage.clientId];
    
    if (!asyncMessage.headers)
        asyncMessage.headers = [NSMutableDictionary dictionary];
    if (headers)
        [asyncMessage.headers addEntriesFromDictionary:headers];
    if (subtopic)
        [asyncMessage.headers setValue:subtopic forKey:DSSUBTOPIC];
    if (idInfo.dsId)
        [asyncMessage.headers setValue:idInfo.dsId forKey:DSID];
    
    if (!responder)
        responder = [Responder responder:self 
                      selResponseHandler:@selector(publishResponseHandler:) 
                         selErrorHandler:@selector(publishErrorHandler:)];
    
    [engine sendRequest:asyncMessage responder:responder];
}

-(Subscription *)subscribe:(id <IResponder>)responder {
    return [self subscribe:responder subtopic:nil selector:nil];
}

-(Subscription *)subscribe:(id <IResponder>)responder subtopic:(NSString *)subTopic {
    return [self subscribe:responder subtopic:subTopic selector:nil];    
}

-(Subscription *)subscribe:(id <IResponder>)responder subtopic:(NSString *)subTopic selector:(NSString *)selector {
    
    NSString *key = [Subscription getIdBySubTopicSelector:subTopic selector:selector];
    
    [DebLog log:@"WeborbClient -> subscribe: key ='%@', responder class = %@", key, [responder class]];
    
    Subscription *token = [subscribers objectForKey:key];
    if (!token) {
        token = [[Subscription alloc] initWithSubTopic:subTopic selector:selector engine:engine];
        [subscribers setValue:token forKey:[token getId]];
    }
        
    engine.subscribedHandler = [SubscribedHandler responder:self selSubscribedHandler:@selector(subscribed:)];
    [token subscribe:responder];
    
    return token;
}

-(void)unsubscribe {
    [self unsubscribe:nil selector:nil];    
}

-(void)unsubscribe:(NSString *)subTopic {
    [self unsubscribe:subTopic selector:nil];
}

-(void)unsubscribe:(NSString *)subTopic selector:(NSString *)selector {
    
    NSString *key = [Subscription getIdBySubTopicSelector:subTopic selector:selector];
    
    [DebLog log:@"WeborbClient -> unsubscribe: key ='%@'", key];
    
    Subscription *token = [subscribers objectForKey:key];
    if (token) 
        [token unsubscribe:
         [Responder responder:self 
           selResponseHandler:@selector(unsubscribeResponseHandler:) 
              selErrorHandler:@selector(unsubscribeErrorHandler:)]]; 
    else {
        [DebLog log:@"WeborbClient -> unsubscribe: subscription '%@' is not exist", key];
    }
        
}

-(void)sendMessage:(V3Message *)v3Msg responder:(id <IResponder>)responder {
    [engine sendRequest:v3Msg responder:responder];
}

-(void)stop {
    [subscribers removeAllObjects];
    if (engine) [engine stop];
}

@end


@implementation IdInfo
@synthesize clientId, dsId, destination;

-(id)init {	
	if ( (self=[super init]) ) {
        clientId = nil;
        dsId = nil;
        destination = [@"GenericDestination" retain];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog log:@"DEALLOC IdInfo"];
    
    if (clientId) [clientId release];
    if (dsId) [dsId release];
    if (destination) [destination release];
	
	[super dealloc];
}

@end


@implementation SubscribedHandler

-(id)init {
    
    if (self = [super init]) {
        _responder = nil;
        _subscribedHandler = nil;
    }
    
    return self;
}

-(id)initWithResponder:(id)responder selSubscribedHandler:(SEL)selSubscribedHandler {
    
    if (self = [super init]) {
        _responder = [responder retain];
        _subscribedHandler = selSubscribedHandler;
    }
    
    return self;
}

+(id)responder:(id)responder selSubscribedHandler:(SEL)selSubscribedHandler {
    return [[[SubscribedHandler alloc] initWithResponder:responder selSubscribedHandler:selSubscribedHandler] autorelease];
}

-(void)dealloc {
	
	[DebLog log:@"DEALLOC SubscribedHandler"];

    if (_responder)
        [_responder release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ISubscribedHandler Methods

-(void)subscribed:(id)info {
	
	[DebLog log:@"SubscribedHandler -> subscribed: %@", info];
    
    if (_responder && _subscribedHandler && [_responder respondsToSelector:_subscribedHandler])
        [_responder performSelector:_subscribedHandler withObject:info];
}

@end


