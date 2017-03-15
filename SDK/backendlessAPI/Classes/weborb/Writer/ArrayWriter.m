//
//  ArrayWriter.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 11.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "ArrayWriter.h"
#import "DEBUG.h"
#import "IProtocolFormatter.h"
#import "ArrayReferenceWriter.h"
#import "MessageWriter.h"


@implementation ArrayWriter

-(id)init {	
	if ( (self=[super init]) ) {
#if _ON_REFERENCEBLE_TYPE_WRITER_
		referenceWriter = [ArrayReferenceWriter new];
#else
        referenceWriter = nil;
#endif
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC ArrayWriter"];
    
    [referenceWriter release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[ArrayWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)writer {
	
	[DebLog log:_ON_WRITERS_LOG_ text:@"ArrayWriter -> write:%@ format:%@", obj, writer];
	
	if (!obj || !writer)
		return;
	
	NSArray *arrayObj = [obj isKindOfClass:[NSSet class]] ? [obj allObjects] : (NSArray *)obj;
	int length = [arrayObj count];
	
	[writer beginWriteArray:length];
	
	id <ITypeWriter> typeWriter = nil;
	id <ITypeWriter> contextWriter = nil;
	
	for (int i = 0; i < length; i++) {
		
        id value = [arrayObj objectAtIndex:i];
		if (!contextWriter) {
			typeWriter = [[MessageWriter sharedInstance] getWriter:value format:writer];
			//contextWriter = writer.contextWriter; // ????????? in C# it works  !!!!
		}
		else {
			writer.contextWriter = contextWriter;
		}
		
        [typeWriter write:value format:writer];
	}
	
	[writer endWriteArray];
}

-(id <ITypeWriter>)getReferenceWriter {
	return referenceWriter;
}

@end
