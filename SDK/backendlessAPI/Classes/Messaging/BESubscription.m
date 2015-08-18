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
#import "HashMap.h"
#import "Backendless.h"


@implementation BESubscription

-(id)init {
	
    if ( (self=[super init]) ) {
        _subscriptionId = nil;
        _channelName = nil;
        _responder = nil;
        _deliveryMethod = DELIVERY_POLL;
	}
	
	return self;
}

-(id)initWithChannelName:(NSString *)channelName responder:(id <IResponder>)subscriptionResponder {
	
    if ( (self=[super init]) ) {
        self.subscriptionId = nil;
        self.channelName = channelName;
        self.responder = subscriptionResponder;
        _deliveryMethod = DELIVERY_POLL;
	}
	
	return self;    
}

-(id)initWithChannelName:(NSString *)channelName response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
	
    if ( (self=[super init]) ) {
        self.subscriptionId = nil;
        self.channelName = channelName;
        self.responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
        _deliveryMethod = DELIVERY_POLL;
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

#define _BY_DISPATCH_TIME_ 1

-(void)pollingMessages {
    
    if (!_subscriptionId)
        return;
    
    //printf("\n############################################### NEW POLLING #################################################\n\n");
    
    [backendless.messagingService pollMessages:_channelName subscriptionId:_subscriptionId responder:_responder];
#if _BY_DISPATCH_TIME_
    dispatch_time_t interval = dispatch_time(DISPATCH_TIME_NOW, 1ull*NSEC_PER_MSEC*backendless.messagingService.pollingFrequencyMs);
    dispatch_after(interval, dispatch_get_main_queue(), ^{
        [self pollingMessages];
    });
#else
    [self performSelector:@selector(pollingMessages) withObject:nil afterDelay:(double)backendless.messagingService.pollingFrequencyMs/1000];
#endif
}

#pragma mark -
#pragma mark getters/setters

-(void)setSubscriptionId:(NSString *)subscriptionId {
    
#if !_BY_DISPATCH_TIME_
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
#endif
    
    [_subscriptionId release];
    _subscriptionId = [subscriptionId retain];
    
    if (!_subscriptionId)
        return;
    
    switch (_deliveryMethod) {
        
        case DELIVERY_POLL: {
            
            [DebLog log:@"BESubscription -> (DELIVERY_POLL) pollingFrequency: %d", (double)backendless.messagingService.pollingFrequencyMs/1000];
            
#if _BY_DISPATCH_TIME_
            dispatch_time_t interval = dispatch_time(DISPATCH_TIME_NOW, 100ull*NSEC_PER_MSEC);
            dispatch_after(interval, dispatch_get_main_queue(), ^{
                [self pollingMessages];
            });
#else
            [self performSelector:@selector(pollingMessages) withObject:nil afterDelay:0.1f];
#endif
            break;
        }
        
        case DELIVERY_PUSH: {
            [backendless.messaging.subscriptions push:_channelName withObject:self];
            [DebLog log:@"BESubscription -> (DELIVERY_PUSH) subscriptions: %@", backendless.messaging.subscriptions.node];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark Public Methods

-(void)cancel {
    
#if !_BY_DISPATCH_TIME_
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
#endif
    
    if (_deliveryMethod == DELIVERY_PUSH) {
        [backendless.messaging.subscriptions pop:_channelName withObject:self];
    }
    
    [_subscriptionId release];
    _subscriptionId = nil;
    
    [_channelName release];
    _channelName = nil;
    
    [_responder release];
    _responder = nil;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<Subscription> subscriptionId: %@, channelName: %@, responder: %@", _subscriptionId, _channelName, _responder];
}

@end
