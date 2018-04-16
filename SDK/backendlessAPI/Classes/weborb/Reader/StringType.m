//
//  StringType.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 14.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "StringType.h"
#import "DEBUG.h"

@implementation StringType

-(id)initWithString:(NSString *)string {	
	if ( (self=[super init]) ) {
		stringValue = string;
	}
	
	return self;
}

+(id)objectType:(NSString *)string {
	return [[[StringType alloc] initWithString:string] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC StringType"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark IAdaptingType Methods

-(Class)getDefaultType {
	return [stringValue class];
}

-(id)defaultAdapt {
	return stringValue;
}

-(id)adapt:(Class)type {
	
    [DebLog logN:@"StringType -> adapt: %@", type];
	
    return stringValue;
}

-(BOOL)canAdapt:(Class)formalArg {
	return NO;
}

-(BOOL)equals:(id)obj pairs:(NSDictionary *)visitedPairs {
	return ([stringValue compare:(NSString *)obj] == NSOrderedSame);
}

@end
