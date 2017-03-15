//
//  AMFHeaderWriter.m
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/6/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "AMFHeaderWriter.h"
#import "DEBUG.h"
#import "MHeader.h"
#import "MessageWriter.h"


@implementation AMFHeaderWriter

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC AMFHeaderWriter"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[AMFHeaderWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)writer {
	
	if (!obj || !writer)
		return;
	
    MHeader *header = (MHeader *)obj;
    [writer.writer writeString:header.headerName];
    [writer.writer writeBoolean:header.mustUnderstand];
    [writer.writer writeInt:-1];
    [[MessageWriter sharedInstance] writeObject:header.headerValue format:writer];
}

@end
