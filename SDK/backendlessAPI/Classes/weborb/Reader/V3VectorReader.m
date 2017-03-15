//
//  V3VectorReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 01.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "V3VectorReader.h"
#import "DEBUG.h"
#import "Datatypes.h"
#import "ArrayType.h"
#import "V3ObjectReader.h"
#import "ReaderUtils.h"
#import "RequestParser.h"


@implementation V3VectorReader

-(id)initWithType:(int)type {	
	if( (self=[super init]) ) {
        _type = type;
	}
	
	return self;
}

+(id)typeReader:(int)type {
	return [[[V3VectorReader alloc] initWithType:type] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC V3VectorReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
	
    [DebLog logN:@"V3VectorReader -> read:context:"];
    
    int handle = [reader readVarInteger];
    if ((handle & 0x1) == 0)
        return [parseContext getReference:(handle >> 1)];
    
    handle = handle >> 1;
	
	NSMutableArray *array = [NSMutableArray array];
	ArrayType *arrayType = [ArrayType objectType:array];
	[parseContext addReference:arrayType];
	
	// whether vector is readonly
    [reader readVarInteger];
    // type name of the vector's elements
    [ReaderUtils readString:reader context:parseContext];

    for (int i = 0; i < handle; i++) {
        switch (_type) {
			case INT_VECTOR_V3:
                [array addObject:[NSNumber numberWithInt:[reader readInteger]]];
				break;
			case UINT_VECTOR_V3:
                [array addObject:[NSNumber numberWithInt:[reader readUInteger]]];
				break;
			case DOUBLE_VECTOR_V3:
                [array addObject:[NSNumber numberWithDouble:[reader readDouble]]];
				break;
			default:
                [array addObject:[RequestParser readData:reader context:parseContext]];
				break;
		}
	}

	return arrayType;
}

@end
