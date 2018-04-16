//
//  BooleanType.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 24.05.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "BooleanType.h"
#import "DEBUG.h"


@implementation BooleanType

-(id)initWithBoolean:(BOOL)data
{	
	if ( (self=[super init]) ) {
		boolean = [NSNumber numberWithBool:data];
	}
	
	return self;
}

+(id)objectType:(BOOL)data
{
	return [[[BooleanType alloc] initWithBoolean:data] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BooleanType"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark IAdaptingType Methods

-(Class)getDefaultType {
	return [boolean class];
}

-(id)defaultAdapt {
	return boolean;
}

-(id)adapt:(Class)type {
	
    [DebLog logN:@"BooleanType -> adapt: %@", type];
    
	return boolean;
}

-(BOOL)canAdapt:(Class)formalArg {
	return NO;
}

-(BOOL)equals:(id)obj pairs:(NSDictionary *)visitedPairs {
	return [boolean isEqualToNumber:(NSNumber *)obj];
}


@end
