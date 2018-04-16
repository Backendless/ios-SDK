//
//  StringWriter.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 30.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

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
