//
//  NullReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "NullReader.h"
#import "DEBUG.h"
#import "NullType.h"

@implementation NullReader

+(id)typeReader {
	return [[[NullReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC NullReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
	
	[DebLog logN:@"NullReader -> NULL"];
	
	return [NullType objectType];
}

@end
