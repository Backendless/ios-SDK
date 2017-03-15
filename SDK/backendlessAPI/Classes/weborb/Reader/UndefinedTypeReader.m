//
//  UndefinedTypeReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 30.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "UndefinedTypeReader.h"
#import "DEBUG.h"
#import "UndefinedType.h"


@implementation UndefinedTypeReader

+(id)typeReader {
	return [[[UndefinedTypeReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC UndefinedTypeReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
	
	[DebLog logN:@"UndefinedTypeReader -> NULL"];
	
	return [UndefinedType objectType];
}

@end
