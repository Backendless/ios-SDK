//
//  ConcreteObject.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

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
