//
//  NumberObject.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "NumberObject.h"
#import "DEBUG.h"
#import "Types.h"
#import "ITypeReader.h"

@implementation NumberObject

-(id)initWithNumber:(NSNumber *)data
{	
	if ( (self=[super init]) ) {
		number = data;
	}
	
	return self;
}

+(id)objectType:(NSNumber *)data
{
	return [[[NumberObject alloc] initWithNumber:data] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC NumberObject"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark IAdaptingType Methods

-(Class)getDefaultType {
	return [number class];
}

-(id)defaultAdapt {
	
    [DebLog log:_ON_READERS_LOG_ text:@"NumberObject -> defaultAdapt"];
    
	return number;
}

-(id)adapt:(Class)type {
	
    [DebLog log:_ON_READERS_LOG_ text:@"NumberObject -> adapt: %@", type];
    
    if ([type conformsToProtocol:@protocol(IAdaptingType)]) {
        return self;
    }
	
	return number;
}

-(BOOL)canAdapt:(Class)formalArg {
	return NO;
}

-(BOOL)equals:(id)obj pairs:(NSDictionary *)visitedPairs {
	return [number isEqualToNumber:(NSNumber *)obj];
}

@end
