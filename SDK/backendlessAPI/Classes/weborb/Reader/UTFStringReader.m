//
//  UTFStringReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 14.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "UTFStringReader.h"
#import "DEBUG.h"
#import "StringType.h"

@implementation UTFStringReader

+(id)typeReader {
	return [[[UTFStringReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC UTFStringReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
	
	NSString *str = [reader readString];
	
	[DebLog logN:@"UTFStringReader -> '%@'", str];

	return [StringType objectType:str];
}

@end
