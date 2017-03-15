//
//  V3DateReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 01.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "V3DateReader.h"
#import "DEBUG.h"
#import "DateType.h"


@implementation V3DateReader

+(id)typeReader {
	return [[[V3DateReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC V3DateReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
    
    int refId = [reader readVarInteger];
    if ((refId & 0x1) == 0)
        return [parseContext getReference:(refId >> 1)];

    double dateTime = [reader readDouble];	
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateTime/1000];
	[DebLog logN:@"V3DateReader -> %@", date];
    DateType *dateType = [DateType objectType:date];
    [parseContext addReference:dateType];
	return dateType;
}

@end
