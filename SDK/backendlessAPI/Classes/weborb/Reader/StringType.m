//
//  StringType.m
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
