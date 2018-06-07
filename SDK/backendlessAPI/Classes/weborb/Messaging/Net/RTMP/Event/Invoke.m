//
//  Invoke.m
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

#import "Invoke.h"
#import "DEBUG.h"
#import "RTMPConstants.h"


@implementation Invoke

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC Invoke"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(BOOL)equals:(id)event {
	
	if (!event || ![event isKindOfClass:[Invoke class]])
		return NO;
	
	return [super equals:event];
}

-(NSString *)toString {
	return @"Invoke";
}

#pragma mark -
#pragma mark IRTMPEvent Methods

-(uint)getDataType {
	return TYPE_INVOKE;
}

@end
