//
//  NamedObjectReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "NamedObjectReader.h"
#import "DEBUG.h"
#import "NamedObject.h"
#import "AnonymousObjectReader.h"


@implementation NamedObjectReader

+(id)typeReader {
	return [[[NamedObjectReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC NamedObjectReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
	
	NSString *objectName = [reader readString];
	
	[DebLog log:_ON_READERS_LOG_ text:@"NamedObjectReader -> read:context: objectName = '%@'", objectName];
		
	AnonymousObjectReader *objectReader = [AnonymousObjectReader typeReader];
	return [NamedObject objectType:objectName withObject:[objectReader read:reader context:parseContext]];
}

@end
