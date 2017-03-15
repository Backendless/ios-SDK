//
//  DateReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 01.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "DateReader.h"
#import "DEBUG.h"
#import "DateType.h"


@implementation DateReader

+(id)typeReader {
	return [[[DateReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC DateReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
    
    double dateTime = [reader readDouble];
    // ignore the stupid timezone
    [reader readUnsignedShort];
	
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateTime/1000];
	[DebLog logN:@"DateReader -> %@", date];
	return [DateType objectType:date];
}

@end
