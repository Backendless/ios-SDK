//
//  PublishMessageInfo.m
//  backendlessAPI
//
//  Created by Vyacheslav Vdovichenko on 10/2/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import "PublishMessageInfo.h"
#import "DEBUG.h"

@implementation PublishMessageInfo
@synthesize message, publisherId, subtopic, pushBroadcast, pushSinglecast, headers;

-(id)init {
    if (self = [super init]) {
        message = nil;
        publisherId = nil;
        subtopic = nil;
        pushBroadcast = nil;
        pushSinglecast = nil;
        headers = nil;
	}
	return self;
}

-(id)initWithMessage:(NSString *)_message {
    if (self = [super init]) {
        message = [_message retain];
        publisherId = nil;
        subtopic = nil;
        pushBroadcast = nil;
        pushSinglecast = nil;
        headers = nil;
	}
	return self;
}

-(void)dealloc {
	[DebLog logN:@"DEALLOC PublishMessageInfo"];    
    if (message) [message release];
    if (publisherId) [publisherId release];
    if (subtopic) [subtopic release];
    if (pushBroadcast) [pushBroadcast release];
    if (pushSinglecast) [pushSinglecast release];
    if (headers) [headers release];
	[super dealloc];
}

-(void)addHeaders:(NSDictionary *)_headers {
    headers ? [headers addEntriesFromDictionary:_headers] : [[NSMutableDictionary alloc] initWithDictionary:_headers];
}

@end
