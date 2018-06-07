//
//  StringReferenceWriter.m
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
