//
//  ArrayWriter.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

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
	int length = (int)[arrayObj count];
	
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
