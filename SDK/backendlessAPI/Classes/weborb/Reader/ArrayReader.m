//
//  ArrayReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 13.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "ArrayReader.h"
#import "DEBUG.h"
#import "ArrayType.h"
#import "RequestParser.h"


@implementation ArrayReader

+(id)typeReader {
	return [[[ArrayReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC ArrayReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
	
	NSMutableArray *array = [NSMutableArray array];
	ArrayType *arrayType = [ArrayType objectType:array];
	[parseContext addReference:arrayType];
	
	int length = [reader readInteger];
	
	[DebLog logN:@"ArrayReader -> length = %d", length];
	
	for (int i = 0; i < length; i++) {
		id obj = [RequestParser readData:reader context:parseContext];
		if (obj) {
#if _ADAPT_DURING_PARSING_
            obj = [obj defaultAdapt];
            if (!obj) obj = [NSNull null];
#endif
			[array addObject:obj];
        }
	}
	
	[DebLog log:@"ArrayReader -> array.count = %d, array = %@", [array count], array];
	
	return arrayType;
}

@end
