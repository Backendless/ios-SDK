//
//  Message.m
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

#import "Message.h"
#import "DEBUG.h"

@implementation Message

-(id)init {
	
    if ( (self=[super init]) ) {
        _messageId = nil;
        _headers= nil;
        _data = nil;
        _publisherId = nil;
        _timestamp = nil;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC Message"];
    
    [_messageId release];
    [_headers release];
    [_data release];
    [_publisherId release];
    [_timestamp release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(long)valTimestamp {
    return _timestamp ? [_timestamp longValue] : 0;
}

@end
