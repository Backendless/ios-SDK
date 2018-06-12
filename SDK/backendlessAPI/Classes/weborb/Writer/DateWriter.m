//
//  DateWriter.m
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

#import "DateWriter.h"
#import "DEBUG.h"
#import "IProtocolFormatter.h"
#import "ReferenceCache.h"
#import "MessageWriter.h"


@interface DateWriter () {
	BOOL	isReferenceable;
}
@end

@implementation DateWriter

-(id)init {
	if ( (self=[super init]) ) {
#if _ON_REFERENCEBLE_TYPE_WRITER_
		isReferenceable = YES;
#else
		isReferenceable = NO;
#endif
	}
	
	return self;
}

-(id)initIsReferenceable:(BOOL)value {
	if ( (self=[super init]) ) {
		isReferenceable = value;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC DateWriter"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[DateWriter new] autorelease];
}

+(id)writerIsReferenceable:(BOOL)value {
	return [[[DateWriter alloc] initIsReferenceable:value] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)writer {
	
	if (!obj || !writer)
		return;

	ReferenceCache *referenceCache = (isReferenceable) ? [writer getReferenceCache] : nil;
	int refId = (referenceCache) ? [referenceCache getObjectId:obj] : -1;
	
	if (refId != -1) {
		[writer writeDateReference:refId];
	}
	else {
        
        [referenceCache addObject:obj];
        
        [DebLog log:_ON_WRITERS_LOG_ text:@"DateWriter -> write: obj = <%@> %@", [obj class], obj];
        
        if ([obj isKindOfClass:[NSDate class]]) {
            [writer writeDate:(NSDate *)obj];
        }
        else {
            [DebLog logY:@"DateWriter -> write: ERROR - uncorrect obj = <%@> %@", [obj class], obj];
            return;
            }
	}
    
    [writer.writer print:NO];
}

-(id <ITypeWriter>)getReferenceWriter {
	return nil;
}

@end
