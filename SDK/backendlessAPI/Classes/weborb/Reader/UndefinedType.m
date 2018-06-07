//
//  UndefinedType.m
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
