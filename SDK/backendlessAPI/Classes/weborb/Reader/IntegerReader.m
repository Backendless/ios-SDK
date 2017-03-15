//
//  IntegerReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 30.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "IntegerReader.h"
#import "DEBUG.h"
#import "NumberObject.h"


@implementation IntegerReader

+(id)typeReader {
	return [[[IntegerReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC IntegerReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
	
	NSNumber *number = [NSNumber numberWithInt:(([reader readVarInteger] << 3) >> 3)];
	[DebLog logN:@"NumberReader -> %@", number];
	return [NumberObject objectType:number];
}

@end
