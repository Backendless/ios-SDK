//
//  ByteArrayType.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.09.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "ByteArrayType.h"
#import "DEBUG.h"


@implementation ByteArrayType

-(id)initWithData:(NSData *)data {	
	if( (self=[super init]) ) {
		dataValue = [data retain];
	}
	
	return self;
}

+(id)objectType:(NSData *)data {
	return [[[ByteArrayType alloc] initWithData:data] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC ByteArrayType"];
    
    [dataValue release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark IAdaptingType Methods

-(Class)getDefaultType {
	return [dataValue class];
}

-(id)defaultAdapt {
	return dataValue;
}

-(id)adapt:(Class)type {
	
    [DebLog logN:@"ByteArrayType -> adapt: %@", type];
	
    return dataValue;
}

-(BOOL)canAdapt:(Class)formalArg {
	return NO;
}

-(BOOL)equals:(id)obj pairs:(NSDictionary *)visitedPairs {
	return NO;
}

@end
