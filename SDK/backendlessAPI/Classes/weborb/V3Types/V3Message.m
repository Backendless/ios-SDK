//
//  V3Message.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "V3Message.h"
#import "DEBUG.h"
#import "Request.h"


@implementation V3Message
@synthesize timestamp, body, timeToLive, destination, messageId, clientId, headers, correlationId, isError;

-(id)init {	
	if ( (self=[super init]) ) {
        timestamp = 0;
        body = nil;
        timeToLive = 0;
        destination = nil;
        messageId = nil; 
        clientId = nil;
        headers = nil;
        correlationId = nil;
        isError = NO;
	}
	
	return self;
}

#pragma mark -
#pragma mark Public Methods

-(V3Message *)execute:(Request *)message  context:(NSDictionary *)context {
    return nil;
}

@end
