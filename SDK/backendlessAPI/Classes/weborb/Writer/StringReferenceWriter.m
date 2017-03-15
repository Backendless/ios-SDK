//
//  StringReferenceWriter.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 04.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "StringReferenceWriter.h"
#import "IProtocolFormatter.h"
#import "ReferenceCache.h"

@implementation StringReferenceWriter

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[StringReferenceWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)formatter {
	
	if (!obj || !formatter)
		return;
    
	ReferenceCache *referenceCache = [formatter getReferenceCache];
	int refId = (referenceCache) ? [referenceCache getObjectId:obj] : -1;
	
	if (refId != -1) {
		[formatter writeStringReference:refId];
	}
	else {
		[referenceCache addString:obj];
		if (formatter.contextWriter)
			[formatter.contextWriter write:obj format:formatter];
	}
}

-(id <ITypeWriter>)getReferenceWriter {
	return nil;
}

@end
