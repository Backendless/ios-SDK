//
//  SubscriptionOptions.m
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

#import "SubscriptionOptions.h"
#import "DEBUG.h"

#define DELIVERY_METHOD @[@"POLL", @"PUSH"]

@implementation SubscriptionOptions

-(id)init {
	
    if ( (self=[super init]) ) {
        _subscriberId = nil;
        _subtopic = nil;
        _selector = nil;
        _deliveryMethod = DELIVERY_METHOD[DELIVERY_POLL];
        _deviceId = nil;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC SubscriptionOptions"];
    
    [_subscriberId release];
    [_subtopic release];
    [_selector release];
    [_deliveryMethod release];
    [_deviceId release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(DeliveryMethodEnum)valDeliveryMethod {
    return _deliveryMethod?(DeliveryMethodEnum)[DELIVERY_METHOD indexOfObject:_deliveryMethod]:DELIVERY_POLL;
}

-(void)deliveryMethod:(DeliveryMethodEnum)deliveryMethod {
    _deliveryMethod = DELIVERY_METHOD[deliveryMethod];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<SubscriptionOptions> subscriberId: %@, subtopic: %@, selector = %@, deliveryMethod = %@, deviceId = %@", _subscriberId, _subtopic, _selector, _deliveryMethod, _deviceId];
}

@end
