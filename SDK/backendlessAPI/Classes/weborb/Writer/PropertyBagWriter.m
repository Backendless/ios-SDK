//
//  PropertyBagWriter.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 31.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "PropertyBagWriter.h"
#import "DEBUG.h"
#import "IProtocolFormatter.h"
#import "AnonymousObject.h"
#import "MessageWriter.h"


@implementation PropertyBagWriter

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC PropertyBagWriter"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[PropertyBagWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)writer {
    
    [DebLog log:_ON_WRITERS_LOG_ text:@"PropertyBagWriter -> write:%@ format:%@", obj, writer];
	
	if (!obj || !writer)
		return;
	
	AnonymousObject *object = (AnonymousObject *)obj;
	NSMutableDictionary *propertyBag = object.properties;
    NSArray *keys = [propertyBag allKeys];
	
	[writer beginWriteObject:(int)[propertyBag count]];
	for (NSString *key in keys) {
		[writer writeFieldName:key];
		[writer endWriteFieldValue];
		[[MessageWriter sharedInstance] writeObject:[propertyBag objectForKey:key] format:writer];
		[writer endWriteFieldValue];
	}
	[writer endWriteObject];
}

@end
