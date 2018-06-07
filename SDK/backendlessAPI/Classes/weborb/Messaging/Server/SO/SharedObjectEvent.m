//
//  SharedObjectEvent.m
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

#import "SharedObjectEvent.h"
#import "DEBUG.h"


@implementation SharedObjectEvent

-(id)init {	
	if ( (self=[super init]) ) {
		type = UNKNOWN;
		key = nil;
		value = nil;
	}
	
	return self;
}

-(id)initWithType:(SharedObjectEventType)_type withKey:(NSString *)_key andValue:(id)_value {	
	if ( (self=[super init]) ) {
		type = _type;
		key = _key;
		value = _value;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC SharedObjectEvent"];
		
	[super dealloc];
}


#pragma mark -
#pragma mark ISharedObjectEvent Methods

-(SharedObjectEventType)getType {
	return type;
}

-(NSString *)getKey {
	return key;
}

-(id)getValue {
	return value;
}


@end
