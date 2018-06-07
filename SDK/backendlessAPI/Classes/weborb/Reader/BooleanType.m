//
//  BooleanType.m
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
