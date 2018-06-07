//
//  AnonymousObjectReader.m
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

#import "AnonymousObjectReader.h"
#import "DEBUG.h"
#import "AnonymousObject.h"
#import "Datatypes.h"
#import "RequestParser.h"

@implementation AnonymousObjectReader

+(id)typeReader {
	return [[[AnonymousObjectReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC AnonymousObjectReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
	
	NSMutableDictionary *properties = [NSMutableDictionary dictionary];
	AnonymousObject *anonymousObject = [AnonymousObject objectType:properties];
	[parseContext addReference:anonymousObject];
	
	while (YES) {
		 
		NSString *propName = [reader readString];
		if (!propName)
			break;
		
		id <IAdaptingType> obj = nil;
		int dataType = (int)[reader get];
		
		[DebLog log:_ON_READERS_LOG_ text:@"AnonymousObjectReader -> read:context: propName ='%@', dataType = %d", propName, dataType];
		
		if (dataType == REMOTEREFERENCE_DATATYPE_V1 && [propName compare:@"nc"] != NSOrderedSame)
			obj = nil;
		else 
			obj = [RequestParser readData:reader context:parseContext];

        if (!obj)
			break;

#if _ADAPT_DURING_PARSING_
        if ((obj = [obj defaultAdapt]))
            [properties setObject:obj forKey:propName];
#else
        [properties setObject:obj forKey:propName];
#endif
	}
	
	return anonymousObject;
}

@end
