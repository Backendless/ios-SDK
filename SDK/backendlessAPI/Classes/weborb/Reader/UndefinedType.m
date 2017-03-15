//
//  UndefinedType.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 30.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "UndefinedType.h"
#import "DEBUG.h"


@implementation UndefinedType

+(id)objectType
{
	return [[[UndefinedType alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC UndefinedType"];
	
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
	
    [DebLog logN:@"UndefinedType -> adapt: %@", type];
    
	return [NSNull null];
}

-(BOOL)canAdapt:(Class)formalArg {
	return NO;
}

-(BOOL)equals:(id)obj pairs:(NSDictionary *)visitedPairs {
	return [obj isKindOfClass:[UndefinedType class]];
}

@end
