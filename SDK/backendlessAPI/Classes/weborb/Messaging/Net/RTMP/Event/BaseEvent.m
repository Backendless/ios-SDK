//
//  BaseEvent.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 06.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

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
