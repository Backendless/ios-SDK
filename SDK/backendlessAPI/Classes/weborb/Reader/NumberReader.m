//
//  NumberReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "NumberReader.h"
#import "DEBUG.h"
#import "NumberObject.h"

@implementation NumberReader

+(id)typeReader {
	return [[[NumberReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC NumberReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
	
	NSNumber *number = [NSNumber numberWithDouble:[reader readDouble]];
	[DebLog logN:@"NumberReader -> %@", number];
	return [NumberObject objectType:number];
}

@end
