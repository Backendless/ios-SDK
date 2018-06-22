//
//  ArrayReferenceWriter.m
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
