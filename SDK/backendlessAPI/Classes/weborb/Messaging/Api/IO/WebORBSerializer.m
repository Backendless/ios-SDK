//
//  WebORBSerializer.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 28.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "WebORBSerializer.h"
#import "DEBUG.h"
#import "Datatypes.h"
#import "AmfFormatter.h"
#import "AmfV3Formatter.h"
#import "MessageWriter.h"


@implementation WebORBSerializer
@synthesize buffer, version;

-(id)init {
	if( (self=[super init]) ) {
		version = AMF0;
		buffer = [[[FlashorbBinaryWriter alloc] initWithAllocation:1] autorelease];
	}
	
	return self;
}

-(id)initWithWriter:(FlashorbBinaryWriter *)source {
	if( (self=[super init]) ) {
		version = AMF0;
		buffer = source;
	}
	
	return self;
}

-(id)initWithWriter:(FlashorbBinaryWriter *)source andVersion:(int)ver {
	if( (self=[super init]) ) {
		version = ver;
		buffer = source;
	}
	
	return self;
}

+(id)writer {
	return [[[WebORBSerializer alloc] init] autorelease];
}

+(id)writer:(FlashorbBinaryWriter *)source {
	return [[[WebORBSerializer alloc] initWithWriter:source] autorelease];
}

+(id)writer:(FlashorbBinaryWriter *)source andVersion:(int)ver {
	return [[[WebORBSerializer alloc] initWithWriter:source andVersion:ver] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC WebORBSerializer"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods


#pragma mark -
#pragma mark ISerializer Methods

-(void)serialize:(id)obj {
    [self serialize:obj version:version];
}

-(void)serialize:(id)obj version:(int)ver {
	IProtocolFormatter *formatter = (ver == AMF0) ? [[AmfFormatter alloc] init] : [[AmfV3Formatter alloc] init];
    [formatter beginWriteBodyContent];
	[[MessageWriter sharedInstance] writeObject:obj format:formatter];
	[buffer write:formatter.writer.buffer length:formatter.writer.size];
    [formatter release];
}

-(int)getVersion {
	return version;
}

@end
