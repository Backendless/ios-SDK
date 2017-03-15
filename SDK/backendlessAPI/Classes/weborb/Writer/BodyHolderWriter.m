//
//  BodyHolderWriter.m
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/15/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "BodyHolderWriter.h"
#import "DEBUG.h"
#import "BodyHolder.h"
#import "MessageWriter.h"


@implementation BodyHolderWriter

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BodyHolderWriter"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[BodyHolderWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)writer {
	
	if (!obj || !writer)
		return;
	
    BodyHolder *body = (BodyHolder *)obj;
    [[MessageWriter sharedInstance] writeObject:body.body format:writer];
}

@end
