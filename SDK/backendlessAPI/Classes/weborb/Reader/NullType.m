//
//  NullType.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "NullType.h"
#import "DEBUG.h"

@implementation NullType

+(id)objectType
{
	return [[[NullType alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC NullType"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark IAdaptingType Methods

-(Class)getDefaultType {
	return [NSNull class];
}

-(id)defaultAdapt {
	return [NSNull null];
}

-(id)adapt:(Class)type {
	
    [DebLog logN:@"NullType -> adapt: %@", type];
    
	return [NSNull null];
}

-(BOOL)canAdapt:(Class)formalArg {
	return NO;
}

-(BOOL)equals:(id)obj pairs:(NSDictionary *)visitedPairs {
	return (obj == nil);
}

@end
