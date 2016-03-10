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

#define PUSH_POLICY @[@"ONLY", @"ALSO", @"NONE"]

@interface DeliveryOptions ()
@property (strong, nonatomic) NSString *pushPolicy;
@property (strong, nonatomic) NSNumber *pushBroadcast;
@property (strong, nonatomic) NSNumber *repeatEvery;
@end

@implementation DeliveryOptions

-(id)init {
	
    if ( (self=[super init]) ) {
        
        [self pushPolicy:PUSH_ALSO];
        [self pushBroadcast:FOR_ALL];
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

+(id)deliveryOptionsForNotification:(PushPolicyEnum)pushPolice {
    
    DeliveryOptions *deliveryOption = [[[DeliveryOptions alloc] init] autorelease];
    [deliveryOption pushPolicy:pushPolice];
    [deliveryOption pushBroadcast:FOR_ALL];
    return deliveryOption;
}

-(PushPolicyEnum)valPushPolicy {
    return (PushPolicyEnum)(_pushPolicy?[(NSArray *)PUSH_POLICY indexOfObject:_pushPolicy]:0);
}

-(void)pushPolicy:(PushPolicyEnum)pushPolicy {
    self.pushPolicy = PUSH_POLICY[pushPolicy];
}

-(UInt32)valPushBroadcast {
    return _pushBroadcast?[_pushBroadcast unsignedIntValue]:0;
}

-(void)pushBroadcast:(UInt32)pushBroadcast {
    self.pushBroadcast = [[NSNumber alloc] initWithUnsignedInt:pushBroadcast];
}

-(long)valRepeatEvery {
    return _repeatEvery?[_repeatEvery longValue]:0;
}

-(BOOL)repeatEvery:(long)repeatEvery {
    
    if (repeatEvery < 0) {
        return NO;
    }
    
    self.repeatEvery = [[NSNumber alloc] initWithLong:repeatEvery];
    return YES;    
}

-(void)addSinglecast:(NSString *)device {
    
    if (!_pushSinglecast) {
        self.pushSinglecast = [NSMutableArray new];
    }
    [_pushSinglecast addObject:device];
}

-(void)delSinglecast:(NSString *)device {    
    [_pushSinglecast removeObject:device];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<DeliveryOptions>  pushBroadcast: %d, pushSinglecast: %@, publishAt: %@, repeatEvery: %@, repeatExpiresAt: %@",  [_pushBroadcast intValue], _pushSinglecast, _publishAt, _repeatEvery, _repeatExpiresAt];
}

@end
