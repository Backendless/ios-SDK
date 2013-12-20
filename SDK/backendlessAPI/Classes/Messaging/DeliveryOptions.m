//
//  DeliveryOptions.m
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

#import "DeliveryOptions.h"
#import "DEBUG.h"


@implementation DeliveryOptions

-(id)init {
	
    if ( (self=[super init]) ) {
        [self pushPolicy:PUSHONLY];
        [self pushBroadcast:IOS];
        _pushSinglecast = nil;
        _publishAt = nil;
        [self repeatEvery:0];
        _repeatExpiresAt = nil;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC DeliveryOptions"];
    
    [_pushPolicy release];
    [_pushBroadcast release];
    [_pushSinglecast release];
    [_publishAt release];
    [_repeatEvery release];
    [_repeatExpiresAt release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

+ (id)deliveryOptionsForNotification:(PushPolicyEnum)pushPolice
{
    DeliveryOptions *deliveryOption = [[[DeliveryOptions alloc] init] autorelease];
    [deliveryOption pushPolicy:pushPolice];
    [deliveryOption pushBroadcast:ALL];
    return deliveryOption;
}

-(PushPolicyEnum)valPushPolicy {
    return _pushPolicy ? [_pushPolicy unsignedIntValue] : 0;
}

-(BOOL)pushPolicy:(PushPolicyEnum)pushPolicy {
    _pushPolicy = [[NSNumber alloc] initWithUnsignedInt:(unsigned int)pushPolicy];
    return YES;
}

-(PushBroadcastEnum)valPushBroadcast {
    return _pushBroadcast ? [_pushBroadcast unsignedIntValue] : 0;
}

-(BOOL)pushBroadcast:(PushBroadcastEnum)pushBroadcast {
    [_pushBroadcast release];
    _pushBroadcast = [[NSNumber alloc] initWithUnsignedInt:(unsigned int)pushBroadcast];
    return YES;
}

-(long)valRepeatEvery {
    return _repeatEvery ? [_repeatEvery longValue] : 0;
}

-(BOOL)repeatEvery:(long)repeatEvery {
    
    if (repeatEvery < 0) {
        return NO;
    }
    
    [_repeatEvery release];
    _repeatEvery = [[NSNumber alloc] initWithLong:repeatEvery];
    return YES;    
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<DeliveryOptions>  pushBroadcast: %d, pushSinglecast: %@, publishAt: %@, repeatEvery: %@, repeatExpiresAt: %@",  [_pushBroadcast intValue], _pushSinglecast, _publishAt, _repeatEvery, _repeatExpiresAt];
}

-(BOOL)addSinglecast:(NSString *)device
{
    if (!_pushSinglecast) {
        _pushSinglecast = [[NSMutableArray alloc] init];
    }
    [_pushSinglecast addObject:device];
    return YES;
}
@end