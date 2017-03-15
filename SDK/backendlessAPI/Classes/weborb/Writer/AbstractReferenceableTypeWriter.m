//
//  AbstractReferenceableTypeWriter.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 30.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "AbstractReferenceableTypeWriter.h"
#import "DEBUG.h"
#import "IProtocolFormatter.h"


@implementation AbstractReferenceableTypeWriter

-(id)init {	
	if( (self=[super init]) ) {
#if _ON_REFERENCEBLE_TYPE_WRITER_
		referenceWriter = [ObjectReferenceWriter new];
#else
        referenceWriter = nil;
#endif
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC AbstractReferenceableTypeWriter"];
    
    [referenceWriter release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[AbstractReferenceableTypeWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)formatter {
}

-(id <ITypeWriter>)getReferenceWriter {
	return referenceWriter;
}

@end
