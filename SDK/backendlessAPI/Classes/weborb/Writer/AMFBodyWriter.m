//
//  AMFBodyWriter.m
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/6/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "AMFBodyWriter.h"
#import "DEBUG.h"
#import "Body.h"
#import "MessageWriter.h"


@implementation AMFBodyWriter

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC AMFBodyWriter"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[AMFBodyWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)writer {
	
	if (!obj || !writer)
		return;
	
    NSString *null = @"null";
    Body *body = (Body *)obj;
    [writer.writer writeString:(body.responseUri)?body.responseUri:null];
    [writer.writer writeString:(body.serviceUri)?body.serviceUri:null];
    [writer.writer writeInt:-1];
    [writer resetReferenceCache];
    [writer beginWriteBodyContent];
    [[MessageWriter sharedInstance] writeObject:body.responseDataObject format:writer];
    [writer endWriteBodyContent];
}

@end
