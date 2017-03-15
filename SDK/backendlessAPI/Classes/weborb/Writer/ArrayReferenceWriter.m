//
//  ArrayReferenceWriter.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 11.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "ArrayReferenceWriter.h"
#import "MessageWriter.h"
#import "IProtocolFormatter.h"
#import "ReferenceCache.h"
#import "DEBUG.h"


@implementation ArrayReferenceWriter

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[ArrayReferenceWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)formatter {
	
	[DebLog log:_ON_WRITERS_LOG_ text:@"ArrayReferenceWriter -> write:%@ format:%@", obj, formatter];
	
	if (!obj || !formatter)
		return;
    
	ReferenceCache *referenceCache = [formatter getReferenceCache];
	int refId = (referenceCache) ? [referenceCache getObjectId:obj] : -1;
	
	if (refId != -1) {
		[formatter writeArrayReference:refId];
	}
	else {
		[referenceCache addObject:obj];
		if (formatter.contextWriter)
			[formatter.contextWriter write:obj format:formatter];
	}
}

-(id <ITypeWriter>)getReferenceWriter {
	return nil;
}

@end
