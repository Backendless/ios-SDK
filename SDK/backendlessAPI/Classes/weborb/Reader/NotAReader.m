//
//  NotAReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "NotAReader.h"
#import "DEBUG.h"


@implementation NotAReader

+(id)typeReader {
	return [[[NotAReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC NotAReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
	
	[DebLog logN:@"NotAReader -> END OF OBJECT"];
	
	return nil;
}

@end
