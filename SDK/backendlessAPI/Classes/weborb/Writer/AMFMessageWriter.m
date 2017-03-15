//
//  AMFMessageWriter.m
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/6/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "AMFMessageWriter.h"
#import "DEBUG.h"
#import "Request.h"
#import "MessageWriter.h"


@implementation AMFMessageWriter

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC AMFMessageWriter"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[AMFMessageWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)writer {
	
	if (!obj || !writer)
		return;
	
    Request *message = (Request *)obj;
    [writer beginWriteMessage:message];
    [writer writeMessageVersion:[message getVersion]];
    
    NSArray *headers = [message getResponseHeaders];
    [writer.writer writeUInt16:(unsigned short)headers.count];
    for (id header in headers)
        [[MessageWriter sharedInstance] writeObject:header format:writer];
        
    NSArray *bodies = [message getResponseBodies];
    [writer.writer writeUInt16:(unsigned short)bodies.count];
    for (id body in bodies)
        [[MessageWriter sharedInstance] writeObject:body format:writer];
    
    [writer endWriteMessage];
}

@end
