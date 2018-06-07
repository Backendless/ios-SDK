//
//  AbstractReferenceableTypeWriter.m
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
#import "AbstractReferenceableTypeWriter.h"
#import "DEBUG.h"
#import "IProtocolFormatter.h"


@implementation AbstractReferenceableTypeWriter

-(id)init {	
	if ( (self=[super init]) ) {
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
