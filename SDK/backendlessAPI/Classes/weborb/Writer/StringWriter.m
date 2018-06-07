//
//  StringWriter.m
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

#import "StringWriter.h"
#import "DEBUG.h"
#import "ITypeWriter.h"
#import "IProtocolFormatter.h"
#import "ReferenceCache.h"
#import "MessageWriter.h"


@interface StringWriter () {
	BOOL	isReferenceable;
}
@end

@implementation StringWriter

-(id)init {	
	if ( (self=[super init]) ) {
#if _ON_REFERENCEBLE_STRING_WRITER_
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
	
	[DebLog logN:@"DEALLOC StringWriter"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[StringWriter new] autorelease];
}

+(id)writerIsReferenceable:(BOOL)value {
	return [[[StringWriter alloc] initIsReferenceable:value] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)writer {
	
	if (!obj || !writer)
		return;
	
	ReferenceCache *referenceCache = isReferenceable ? [writer getReferenceCache] : nil;
	int refId = referenceCache ? [obj isKindOfClass:[NSString class]] ? [referenceCache getStringId:obj] : [referenceCache getObjectId:obj] : -1;
    
    [DebLog log:_ON_WRITERS_LOG_ text:@"StringWriter -> write: obj = <%@> %@, referenceCache = %@, refId = %d", [obj class], obj, referenceCache, refId];
	
	if (refId != -1) {
		[writer writeStringReference:refId];
	}
	else {        
        
        if ([obj isKindOfClass:[NSString class]]) {
            [referenceCache addString:(NSString *)obj];
            [writer writeString:(NSString *)obj];
        }
        else 
            if ([obj isKindOfClass:[NSData class]]) {
                [referenceCache addObject:obj];
                [writer writeData:(NSData *)obj];
            }
            else {
                [DebLog logY:@"StringWriter -> write: ERROR - uncorrect obj = <%@> %@", [obj class], obj];
                return;
            }
	}
    
    [writer.writer print:NO];
}

-(id <ITypeWriter>)getReferenceWriter {
	return nil;
}

@end
