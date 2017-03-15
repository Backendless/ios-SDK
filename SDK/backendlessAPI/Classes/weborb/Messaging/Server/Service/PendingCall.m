//
//  PendingCall.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 08.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "PendingCall.h"
#import "DEBUG.h"


@implementation PendingCall

-(id)init {	
	if( (self=[super init]) ) {
		_result = nil;
		callbacks = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(id)initWithMethod:(NSString *)method {	
	if( (self=[super initWithMethod:method]) ) {
		_result = nil;
		callbacks = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(id)initWithMethod:(NSString *)method andArguments:(NSArray *)args {	
	if( (self=[super initWithMethod:method andArguments:args]) ) {
		_result = nil;
		callbacks = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(id)initWithName:(NSString *)name andMethod:(NSString *)method andArguments:(NSArray *)args {	
	if( (self=[super initWithName:name andMethod:method andArguments:args]) ) {
		_result = nil;
		callbacks = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC PendingCall"];
	
	[callbacks removeAllObjects];
	[callbacks release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(void)registerCallback:(id <IPendingServiceCallback>)callback {
	[callbacks addObject:callback];
}
																
-(void)unregisterCallback:(id <IPendingServiceCallback>)callback {
	[callbacks removeObject:callback];
}

-(NSArray *)getCallbacks {
	return callbacks;
}

-(id)getResult;  {
    return _result;
}

-(void)setResult:(id)result {
    _result = result;
}
						  
@end
