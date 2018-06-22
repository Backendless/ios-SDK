//
//  ObjectReferenceWriter.m
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
