//
//  BoundPropertyBagReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 16.05.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "BoundPropertyBagReader.h"
#import "DEBUG.h"
#import "AnonymousObject.h"
#import "RequestParser.h"


@implementation BoundPropertyBagReader

+(id)typeReader {
	return [[[BoundPropertyBagReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BoundPropertyBagReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
	
	NSMutableDictionary *properties = [NSMutableDictionary dictionary];
	AnonymousObject *anonymousObject = [AnonymousObject objectType:properties];
	[parseContext addReference:anonymousObject];
    
    [reader readInteger]; 	
	while (YES) {
        
		NSString *propName = [reader readString];
		if (!propName)
			break;
		
		id <IAdaptingType> obj = nil;
		int dataType = (int)[reader get];
		
		[DebLog logN:@"BoundPropertyBagReader -> '%@', type %d", propName, dataType];
        
        obj = [RequestParser readData:reader context:parseContext];
		if (!obj)
			break;
        
#if _ADAPT_DURING_PARSING_
        if ((obj = [obj defaultAdapt])) {
            [properties setObject:obj forKey:propName];
        }
#else
        [properties setObject:obj forKey:propName];
#endif
        [DebLog logN:@"BoundPropertyBagReader -> '%@' <%d> : '%@' <%@>", propName, dataType, obj, [obj class] ];
	}
	
	return anonymousObject;
}

@end
