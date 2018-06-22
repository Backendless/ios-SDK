//
//  AckMessage.m
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
