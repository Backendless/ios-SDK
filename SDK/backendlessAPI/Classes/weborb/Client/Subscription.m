//
//  Subscription.m
//  CommLibiOS
//
//  Created by Vyacheslav Vdovichenko on 3/22/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import "Subscription.h"
#import "CommandMessage.h"
#import "Engine.h"
#import "WeborbClient.h"
#import "Responder.h"
#import "DEBUG.h"

#define ID_FMT @"%@#%@"

@implementation Subscription
@synthesize isSubscribed;

-(id)init {
    
    if ( (self = [super init]) ) {
        
        subTopic = nil;
        selector = nil;
        engine = nil;
        
        responder = nil;
        isSubscribed = NO;
        
        idInfo = nil;
        dsIdLock = nil;
    }
    
    return self;
}

-(id)initWithSubTopic:(NSString *)_subTopic selector:(NSString *)_selector engine:(Engine *)_engine {
    
    if ( (self = [super init]) ) {
        
        subTopic = [_subTopic retain];
        selector = [_selector retain];
        
        engine = _engine;
       
        responder = nil;
        isSubscribed = NO;
        
        idInfo = (engine) ? engine.idInfo : nil;
        dsIdLock = nil;
    }
    
    return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC Subscription"];
    
    if (responder)
        [responder release];
    
    if (subTopic) [subTopic release];
    if (selector) [selector release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Private Methods

-(void)subscribeResponse:(id)o {
    
    [DebLog log:@"Subscription -> subscribeResponse: %@", o];
    
    isSubscribed = YES;
    [engine onSubscribed:subTopic selector:selector responder:responder];
}

-(void)subscribeError:(Fault *)fault {
    
    [DebLog log:@"Subscription -> subscribeError: %@", fault];
    
    if (responder && [responder respondsToSelector:@selector(errorHandler:)])
        [responder performSelector:@selector(errorHandler:) withObject:fault];
}

-(void)unsubscribeResponse:(id)o {
    
    [DebLog log:@"Subscription -> unsubscribeResponse: %@", o];
    
    isSubscribed = NO;
    if (responder && [responder respondsToSelector:@selector(responseHandler:)])
        [responder performSelector:@selector(responseHandler:) withObject:[self getId]];
}

-(void)unsubscribeError:(Fault *)fault {
    
    [DebLog log:@"Subscription -> unsubscribeError: %@", fault];
    
    if (responder && [responder respondsToSelector:@selector(errorHandler:)])
        [responder performSelector:@selector(errorHandler:) withObject:fault];
}

-(void)initResponse:(id)o {
    
    [DebLog log:@"Subscription -> initResponse: %@", o];
    
    [self subscribe:responder];
}

-(void)initError:(Fault *)fault {
    
    [DebLog log:@"Subscription -> initError: %@", fault];
    
    if (responder && [responder respondsToSelector:@selector(errorHandler:)])
        [responder performSelector:@selector(errorHandler:) withObject:fault];
}

-(BOOL)initDsId {
    
    if (idInfo.dsId) 
        return NO;
    
    [DebLog log:@"Subscription -> initDsId"];
    
    [engine sendRequest:[CommandMessage command:@"5"] responder:
     [Responder responder:self selResponseHandler:@selector(initResponse:) selErrorHandler:@selector(initError:)]];
    
    return YES;
}

#pragma mark -
#pragma mark Public Methods

+(NSString *)getIdBySubTopicSelector:(NSString *)_subTopic selector:(NSString *)_selector {
    return [NSString stringWithFormat:ID_FMT, (_subTopic)?_subTopic:@"", (_selector)?_selector:@""];
}

-(NSString *)getId {
    return [Subscription getIdBySubTopicSelector:subTopic selector:selector];
}

+(CommandMessage *)getCommandMessage:(NSString *)operation subTopic:(NSString *)_subTopic selector:(NSString *)_selector idInfo:(IdInfo *)_idInfo {
    
    CommandMessage *message = [CommandMessage command:operation];
    message.headers = [NSMutableDictionary dictionary];
    
    if (_idInfo) {
        message.destination = _idInfo.destination;
        if (_idInfo.clientId) 
            message.clientId = _idInfo.clientId;
        [message.headers setValue:[NSString  stringWithString:_idInfo.dsId] forKey:DSID];
    }
    
    if (_selector)
        [message.headers setValue:_selector forKey:DSSELECTOR];
        
    if (_subTopic)
        [message.headers setValue:_subTopic forKey:DSSUBTOPIC];
    
    return message;
}

-(CommandMessage *)getCommandMessage:(NSString *)operation {
    return [Subscription getCommandMessage:operation subTopic:subTopic selector:selector idInfo:idInfo];
}

-(void)subscribe:(id <IResponder>)_responder {
    
    if (isSubscribed)
        return;
    
    if (_responder != responder) {
        if (responder) [responder release];
        responder = [_responder retain];
    }
    
    if ([self initDsId])
        return;
    
    [DebLog log:@"Subscription -> subscribe"];
        
    [engine sendRequest:[self getCommandMessage:@"0"] responder:
     [Responder responder:self selResponseHandler:@selector(subscribeResponse:) selErrorHandler:@selector(subscribeError:)]];
}

-(void)unsubscribe:(id <IResponder>)_responder {
    
    if (!isSubscribed)
        return;
    
    if (_responder != responder) {
        if (responder) [responder release];
        responder = [_responder retain];
    }
    
    [DebLog log:@"Subscription -> unsubscribe"];

    [engine sendRequest:[self getCommandMessage:@"1"] responder:
     [Responder responder:self selResponseHandler:@selector(unsubscribeResponse:) selErrorHandler:@selector(unsubscribeError:)]];
}

@end
