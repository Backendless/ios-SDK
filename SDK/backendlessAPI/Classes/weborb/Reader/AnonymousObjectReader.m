//
//  AnonymousObjectReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 14.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

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
