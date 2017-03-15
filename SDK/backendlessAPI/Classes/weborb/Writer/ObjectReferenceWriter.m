//
//  ObjectReferenceWriter.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 30.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "ObjectReferenceWriter.h"
#import "MessageWriter.h"
#import "IProtocolFormatter.h"
#import "ReferenceCache.h"
#import "DEBUG.h"

@implementation ObjectReferenceWriter

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[ObjectReferenceWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)formatter {
	
	[DebLog log:_ON_WRITERS_LOG_ text:@"ObjectReferenceWriter -> write: (0) %@ format:%@", obj, formatter];
	
	if (!obj || !formatter)
		return;
    
	ReferenceCache *referenceCache = [formatter getReferenceCache];
	int refId = (referenceCache) ? [referenceCache getObjectId:obj] : -1;
	
	[DebLog log:_ON_WRITERS_LOG_ text:@"ObjectReferenceWriter -> write: (1) refId = %d", refId];
	
	if (refId != -1) {
		[formatter writeObjectReference:refId];
	}
	else {
		[referenceCache addObject:obj];
        [DebLog log:_ON_WRITERS_LOG_ text:@"ObjectReferenceWriter -> write: (2) contextWriter = %@", formatter.contextWriter];
		if (formatter.contextWriter)
			[formatter.contextWriter write:obj format:formatter];
	}
	
	[DebLog log:_ON_WRITERS_LOG_ text:@"ObjectReferenceWriter -> write: (FINISHED)"];
}

-(id <ITypeWriter>)getReferenceWriter {
	return nil;
}

@end
