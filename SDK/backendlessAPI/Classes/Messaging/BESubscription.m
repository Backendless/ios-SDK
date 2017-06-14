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

@interface BESubscription () {
    uint pollingInterval;
    NSTimer *pollingTimer;
}
@end


@implementation BESubscription

-(id)init {
    if (self = [super init]) {
        _subscriptionId = nil;
        _channelName = nil;
        _responder = nil;
        _deliveryMethod = DELIVERY_POLL;
        pollingInterval = backendless.messagingService.pollingFrequencySec;
    }
    return self;
}

-(id)initWithChannelName:(NSString *)channelName responder:(id <IResponder>)subscriptionResponder {
    if (self = [super init]) {
        self.subscriptionId = nil;
        self.channelName = channelName;
        self.responder = subscriptionResponder;
        _deliveryMethod = DELIVERY_POLL;
        pollingInterval = backendless.messagingService.pollingFrequencySec;
    }
    return self;
}

-(id)initWithChannelName:(NSString *)channelName response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    if (self = [super init]) {
        self.subscriptionId = nil;
        self.channelName = channelName;
        self.responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
        _deliveryMethod = DELIVERY_POLL;
        pollingInterval = backendless.messagingService.pollingFrequencySec;
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
#pragma mark Public Methods

-(uint)getPollingInterval {
    return pollingInterval;
}

-(void)cancel {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (_deliveryMethod == DELIVERY_PUSH) {
        [backendless.messaging.subscriptions pop:_channelName withObject:self];
    }
    [_subscriptionId release];
    _subscriptionId = nil;
    [_channelName release];
    _channelName = nil;
    [_responder release];
    _responder = nil;
    if (pollingTimer) {
        [pollingTimer invalidate];
        pollingTimer = nil;
    }
}

-(void)startPollingSync {
    pollingTimer = [NSTimer scheduledTimerWithTimeInterval:[self getPollingInterval] target:self selector:NSSelectorFromString(@"getMessagesFromSubscriptionSync:") userInfo:nil repeats: YES];
    [pollingTimer fire];
}

-(void)getMessagesFromSubscriptionSync:(NSTimer *)timer {
    NSArray<Message *> *messages = [backendless.messaging pollMessages:self.channelName subscriptionId:self.subscriptionId];
    [self.responder responseHandler:messages];
}

-(void)startPollingAsync {
    pollingTimer = [NSTimer scheduledTimerWithTimeInterval:[self getPollingInterval] target:self selector:NSSelectorFromString(@"getMessagesFromSubscriptionAsync:") userInfo:nil repeats: YES];
    [pollingTimer fire];
}

-(void)getMessagesFromSubscriptionAsync:(NSTimer *)timer {
    [backendless.messaging pollMessages:self.channelName
                         subscriptionId:self.subscriptionId
                               response:^(NSArray<Message *> *messages) {
                                   [self.responder responseHandler:messages];
                               }
                                  error:^(Fault *fault) {
                                      [DebLog log:@"MessagingService -> getMessagesFromSubscriptionAsync Error: %@", fault];
                                  }];
}

@end
