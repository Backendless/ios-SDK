//
//  V3Reader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 01.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "V3Reader.h"
#import "DEBUG.h"
#import "Datatypes.h"
#import "RequestParser.h"


@implementation V3Reader

+(id)typeReader {
	return [[[V3Reader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC V3Reader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
	
	[DebLog logN:@"V3Reader -> ID"];
	
	return [RequestParser readData:reader context:([parseContext getVersion]==AMF3)?parseContext:[parseContext getCachedContext:AMF3]];
}

@end
