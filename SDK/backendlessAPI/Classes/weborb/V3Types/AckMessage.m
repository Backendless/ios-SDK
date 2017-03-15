//
//  AckMessage.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "AckMessage.h"


@implementation AckMessage

-(id)init {	
	if ( (self=[super init]) ) {
        clientId = [[NSProcessInfo processInfo] globallyUniqueString];
        messageId = [[NSProcessInfo processInfo] globallyUniqueString];
        correlationId = nil;
        headers = [NSMutableDictionary dictionary];
        timestamp = [[NSDate date] timeIntervalSince1970];
        body = [[[BodyHolder alloc] init] autorelease];
        body.body = nil;
        timeToLive = 0;
	}
	
	return self;
}

-(id)initWithObject:(id)obj correlationId:(NSString *)corrID clientId:(NSString *)clId {	
	if ( (self=[super init]) ) {
        clientId = (clId) ? clId : [[NSProcessInfo processInfo] globallyUniqueString];
        messageId = [[NSProcessInfo processInfo] globallyUniqueString];
        correlationId = [NSString stringWithString:corrID];
        headers = [NSMutableDictionary dictionary];
        timestamp = [[NSDate date] timeIntervalSince1970];
        body = [[[BodyHolder alloc] init] autorelease];
        body.body = obj;
        timeToLive = 0;
	}
	
	return self;
}

-(id)initWithObject:(id)obj correlationId:(NSString *)corrID clientId:(NSString *)clId headers:(NSDictionary *)headersDict {
	if ( (self=[super init]) ) {
        clientId = (clId) ? clId : [[NSProcessInfo processInfo] globallyUniqueString];
        messageId = [[NSProcessInfo processInfo] globallyUniqueString];
        correlationId = [NSString stringWithString:corrID];
        headers = (headersDict) ? [NSMutableDictionary  dictionaryWithDictionary:headersDict] : [NSMutableDictionary dictionary];
        timestamp = [[NSDate date] timeIntervalSince1970];
        body = [[[BodyHolder alloc] init] autorelease];
        body.body = obj;
        timeToLive = 0;
	}
	
	return self;
}

#pragma mark -
#pragma mark Public Methods

-(V3Message *)execute:(Request *)message {
    return self;
}

@end
