//
//  ClassDefinition.m
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

#import "ClassDefinition.h"
#import "DEBUG.h"

@implementation ClassDefinition
@synthesize members, className;

-(id)init {	
	if ( (self=[super init]) ) {
		members = [NSMutableDictionary new];
        className = nil;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC ClassDefinition"];
	
	[members removeAllObjects];
    [members release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(void)addMemberInfo:(NSString *)name member:(id)memberInfo {
    [members setObject:memberInfo forKey:name];
}

-(BOOL)containsMember:(NSString *)name {
    return (name && [members valueForKey:name]);
}

@end
