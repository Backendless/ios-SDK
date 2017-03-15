//
//  V3Message.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "V3Message.h"
#import "DEBUG.h"
#import "Request.h"


@implementation V3Message
@synthesize timestamp, body, timeToLive, destination, messageId, clientId, headers, correlationId, isError;

-(id)init {	
	if( (self=[super init]) ) {
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
