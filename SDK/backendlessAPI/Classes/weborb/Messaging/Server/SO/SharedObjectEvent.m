//
//  SharedObjectEvent.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 20.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "SharedObjectEvent.h"
#import "DEBUG.h"


@implementation SharedObjectEvent

-(id)init {	
	if ( (self=[super init]) ) {
		type = UNKNOWN;
		key = nil;
		value = nil;
	}
	
	return self;
}

-(id)initWithType:(SharedObjectEventType)_type withKey:(NSString *)_key andValue:(id)_value {	
	if ( (self=[super init]) ) {
		type = _type;
		key = _key;
		value = _value;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC SharedObjectEvent"];
		
	[super dealloc];
}


#pragma mark -
#pragma mark ISharedObjectEvent Methods

-(SharedObjectEventType)getType {
	return type;
}

-(NSString *)getKey {
	return key;
}

-(id)getValue {
	return value;
}


@end
