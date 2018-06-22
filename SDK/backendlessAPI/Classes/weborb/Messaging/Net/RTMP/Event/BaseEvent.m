//
//  BaseEvent.m
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

#import "BaseEvent.h"
#import "DEBUG.h"


@implementation BaseEvent
@synthesize type, obj, source, timestamp, header, sourceType;

-(id)init {	
	if ( (self=[super init]) ) {
		type = SYSTEM;
		source = nil;
        timestamp = 0;
	}
	
	return self;
}

-(id)initWithType:(EventType)eventType {	
	if ( (self=[super init]) ) {
		type = eventType;
		source = nil;
        timestamp = 0;
	}
	
	return self;
}

-(id)initWithType:(EventType)eventType andSource:(id <IEventListener>)eventSource {	
	if ( (self=[super init]) ) {
		type = eventType;
		source = eventSource;
        timestamp = 0;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BaseEvent"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark IRTMPEvent Methods

-(uint)getDataType {
	return 0;
}

@end
