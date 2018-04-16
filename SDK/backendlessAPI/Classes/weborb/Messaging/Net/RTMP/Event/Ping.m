//
//  Ping.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 07.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "Ping.h"
#import "DEBUG.h"
#import "RTMPConstants.h"


@implementation Ping
@synthesize value2, value3, value4, eventType;

-(id)init {	
	if ( (self=[super init]) ) {
		self.value2 = UNDEFINED;
		self.value3 = UNDEFINED;
		self.value4 = UNDEFINED;
		self.eventType = 0;
	}
	
	return self;
}

-(id)initWithType:(short)_eventType value2:(int)_value2 {	
	if ( (self=[super init]) ) {
		self.value2 = _value2;
		self.value3 = UNDEFINED;
		self.value4 = UNDEFINED;
		self.eventType = _eventType;
	}
	
	return self;
}

-(id)initWithType:(short)_eventType value2:(int)_value2 value3:(int)_value3 {	
	if ( (self=[super init]) ) {
		self.value2 = _value2;
		self.value3 = _value3;
		self.value4 = UNDEFINED;
		self.eventType = _eventType;
	}
	
	return self;
}

-(id)initWithType:(short)_eventType value2:(int)_value2  value3:(int)_value3 value4:(int)_value4 {
	if ( (self=[super init]) ) {
		self.value2 = _value2;
		self.value3 = _value3;
		self.value4 = _value4;
		self.eventType = _eventType;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC Ping"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

#pragma mark -
#pragma mark IRTMPEvent Methods

-(uint)getDataType {
	return TYPE_PING;
}

@end
