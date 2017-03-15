//
//  V3ByteArrayReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 01.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "V3ByteArrayReader.h"
#import "DEBUG.h"
#import "ArrayType.h"
#import "NumberObject.h"
#import "ByteArrayType.h"


@implementation V3ByteArrayReader

+(id)typeReader {
	return [[[V3ByteArrayReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC V3ByteArrayReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
    
    int refId = [reader readVarInteger];
    if ((refId & 0x1) == 0)
        return [parseContext getReference:(refId >> 1)];
	
    int arraySize = (refId >> 1);
	char *bytes = [reader readChars:arraySize];
    NSData *data = [NSData dataWithBytes:bytes length:arraySize];
    free(bytes);
    
    ByteArrayType *arrayType = [ByteArrayType objectType:data];
    [parseContext addReference:arrayType];
    
    return arrayType;    
}

@end
