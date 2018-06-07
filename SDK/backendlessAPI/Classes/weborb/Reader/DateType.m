//
//  DateType.m
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

#import "DateType.h"
#import "DEBUG.h"


@implementation DateType

-(id)initWithDate:(NSDate *)date {	
	if ( (self=[super init]) ) {
		dateObj = date;
	}
	
	return self;
}

+(id)objectType:(NSDate *)date {
	return [[[DateType alloc] initWithDate:date] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC DateType"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark IAdaptingType Methods

-(Class)getDefaultType {
	return [dateObj class];
}

-(id)defaultAdapt {
	return dateObj;
}

-(id)adapt:(Class)type {
	
    [DebLog logN:@"DateType -> adapt: %@", type];
    
	return dateObj;
}

-(BOOL)canAdapt:(Class)formalArg {
	return NO;
}

-(BOOL)equals:(id)obj pairs:(NSDictionary *)visitedPairs {
	return ([dateObj compare:(NSDate *)obj] == NSOrderedSame);
}

@end
