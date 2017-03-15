//
//  LongUTFStringReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 01.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "LongUTFStringReader.h"
#import "DEBUG.h"
#import "ByteArrayType.h"
#import "StringType.h"
#import "BinaryCodec.h"


@implementation LongUTFStringReader

+(id)typeReader {
	return [[[LongUTFStringReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC LongUTFStringReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
    
    BOOL isString = YES; // output: YES - NSString, NO - NSData 
    
    NSString *str;
    int len = [reader readUInteger];
    char *utf8str = [reader readChars:len];
    if (utf8str) {
        str = [NSString stringWithUTF8String:utf8str];
        free(utf8str);
    }
    else
        str = [NSString string];
	
	[DebLog logN:@"LongUTFStringReader -> '%@'", str];
    
	return (isString) ? [StringType objectType:str] : [ByteArrayType objectType:[BEBase64 decode:str]];
}

@end
