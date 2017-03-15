//
//  PointerReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 01.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "PointerReader.h"
#import "DEBUG.h"


@implementation PointerReader

+(id)typeReader {
	return [[[PointerReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC PointerReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
	
	int pointer = [reader readUnsignedShort];    
    [DebLog logN:@"PointerReader -> pointer = %d", pointer];	
	return [parseContext getReference:pointer];
}

@end
