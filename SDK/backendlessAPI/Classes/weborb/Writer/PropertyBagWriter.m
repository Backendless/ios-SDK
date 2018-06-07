//
//  PropertyBagWriter.m
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
