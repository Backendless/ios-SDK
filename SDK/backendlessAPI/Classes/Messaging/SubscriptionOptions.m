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

@implementation SubscriptionOptions

-(id)init {
	
    if ( (self=[super init]) ) {
        _subscriberId = nil;
        _subtopic = nil;
        _selector = nil;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC SubscriptionOptions"];
    
    [_subscriberId release];
    [_subtopic release];
    [_selector release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(NSString *)description {
    return [NSString stringWithFormat:@"<SubscriptionOptions> subscriberId: %@, subtopic: %@, selector = %@", _subscriberId, _subtopic, _selector];
}

@end
