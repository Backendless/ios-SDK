//
//  Subscription.m
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

#import "BESubscription.h"
#import "Responder.h"
#import "DEBUG.h"
#import "Backendless.h"

#define POLLING_INTERVAL 1.0f


@implementation BESubscription

-(id)init {
	
    if ( (self=[super init]) ) {
        _subscriptionId = nil;
        _channelName = nil;
        _responder = nil;
	}
	
	return self;
}

-(id)initWithChannelName:(NSString *)channelName responder:(id <IResponder>)subscriptionResponder {
	
    if ( (self=[super init]) ) {
        self.subscriptionId = nil;
        self.channelName = channelName;
        self.responder = subscriptionResponder;
	}
	
	return self;    
}

-(id)initWithChannelName:(NSString *)channelName response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
	
    if ( (self=[super init]) ) {
        self.subscriptionId = nil;
        self.channelName = channelName;
        self.responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
	}
	
	return self;
}

+(id)subscription:(NSString *)channelName responder:(id <IResponder>)subscriptionResponder {
    return [[[BESubscription alloc] initWithChannelName:channelName responder:subscriptionResponder] autorelease];
}

+(id)subscription:(NSString *)channelName response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    return [BESubscription subscription:channelName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}


-(void)dealloc {
	
	[DebLog logN:@"DEALLOC Subscription"];
    
    [self cancel];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Private Methods

-(void)pollingMessages {
    [backendless.messagingService pollMessages:_channelName subscriptionId:_subscriptionId responder:_responder];
    [self performSelector:@selector(pollingMessages) withObject:nil afterDelay:POLLING_INTERVAL];
}

#pragma mark -
#pragma mark getters/setters

-(void)setSubscriptionId:(NSString *)subscriptionId {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [_subscriptionId release];
    _subscriptionId = [subscriptionId retain];
    [self performSelector:@selector(pollingMessages) withObject:nil afterDelay:0.1f];
}

#pragma mark -
#pragma mark Public Methods

-(void)cancel {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [_subscriptionId release];
    _subscriptionId = nil;
    
    [_channelName release];
    _channelName = nil;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<Subscription> subscriptionId: %@, channelName: %@, responder: %@", _subscriptionId, _channelName, _responder];
}

@end
