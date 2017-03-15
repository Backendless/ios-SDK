//
//  V3StringReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 30.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "V3StringReader.h"
#import "DEBUG.h"
#import "StringType.h"
#import "ReaderUtils.h"


@implementation V3StringReader

+(id)typeReader {
	return [[[V3StringReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC V3StringReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
    
    NSString *str = [ReaderUtils readString:reader context:parseContext];
	[DebLog logN:@"V3StringReader -> '%@'", str];
	return [StringType objectType:str];
}

@end
