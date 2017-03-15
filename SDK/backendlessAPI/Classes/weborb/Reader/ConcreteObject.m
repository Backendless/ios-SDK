//
//  ConcreteObject.m
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/7/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "ConcreteObject.h"
#import "DEBUG.h"


@implementation ConcreteObject

-(id)initWithObject:(id)object {	
	if ( (self=[super init]) ) {
		theObj = object;
	}
	
	return self;
}

+(id)objectType:(id)object {
	return [[[ConcreteObject alloc] initWithObject:object] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC ConcreteObject"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark IAdaptingType Methods

-(Class)getDefaultType {
	return [theObj class];
}

-(id)defaultAdapt {
	return theObj;
}

-(id)adapt:(Class)type {
	
    [DebLog logN:@"ConcreteObject -> adapt: %@", type];
    
	return theObj;
}

-(BOOL)canAdapt:(Class)formalArg {
	return NO;
}

-(BOOL)equals:(id)obj pairs:(NSDictionary *)visitedPairs {
	return [theObj isEqual:obj];
}

@end
