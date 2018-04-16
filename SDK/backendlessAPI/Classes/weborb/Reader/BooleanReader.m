//
//  BooleanReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 24.05.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "BooleanReader.h"
#import "DEBUG.h"
#import "BooleanType.h"

@implementation BooleanReader

-(id)init {	
	if ( (self=[super init]) ) {
        val = NO;
        initialized = NO;
	}
	
	return self;
}

-(id)initWithValue:(BOOL)value {	
	if ( (self=[super init]) ) {
        val = value;
        initialized = YES;
	}
	
	return self;
}

+(id)typeReader {
	return [[[BooleanReader alloc] init] autorelease];
}

+(id)typeReader:(BOOL)initvalue {
	return [[[BooleanReader alloc] initWithValue:initvalue] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BooleanReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
    
	BOOL boolean = (initialized) ? val : [reader readBoolean];
	[DebLog logN:@"BooleanReader -> %@", (boolean)?@"YES":@"NO"];
	return [BooleanType objectType:boolean];
}


@end
