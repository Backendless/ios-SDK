//
//  FlexMessage.m
//  CommLibiOS
//
//  Created by Vyacheslav Vdovichenko on 2/16/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import "FlexMessage.h"
#import "DEBUG.h"
#import "RTMPConstants.h"

@interface FlexMessage ()
-(void)defaultInit;
@end

@implementation FlexMessage
@synthesize msgId, msgLength, msgTime, streamId, version, command;

-(id)init {	
	if ( (self=[super init]) ) {
        [self defaultInit];
	}
	
	return self;
}

-(id)initWithStream:(BinaryStream *)stream {	
	if ( (self=[super initWithStream:stream]) ) {
        [self defaultInit];
	}
	
	return self;
}

-(id)initWithCall:(id <IServiceCall>)_call {	
	if ( (self=[super initWithCall:_call]) ) {
        [self defaultInit];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC FlexMessage"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Private Methods

-(void)defaultInit {
    msgId = 0;
    msgLength = 0;
    msgTime = 0;
    streamId = 0;
    version = 3;
    command = nil;
}

#pragma mark -
#pragma mark Public Methods

-(BOOL)equals:(id)event {
	
	if (!event || ![event isKindOfClass:[FlexMessage class]])
		return NO;
	
	return [super equals:event];
}

-(NSString *)toString {
	return @"FlexMessage:";
}

#pragma mark -
#pragma mark IRTMPEvent Methods

-(uint)getDataType {
	return TYPE_FLEXINVOKE;
}

@end
