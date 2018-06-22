//
//  BooleanReader.m
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

#import "BooleanReader.h"
#import "DEBUG.h"
#import "BooleanType.h"

@implementation BooleanReader

-(id)init {	
	if ( (self=[super init]) ) {
        val = NO;
        initialized = NO;
	}
	
	return self;
}

-(id)initWithValue:(BOOL)value {	
	if ( (self=[super init]) ) {
        val = value;
        initialized = YES;
	}
	
	return self;
}

+(id)typeReader {
	return [[[BooleanReader alloc] init] autorelease];
}

+(id)typeReader:(BOOL)initvalue {
	return [[[BooleanReader alloc] initWithValue:initvalue] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BooleanReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
    
	BOOL boolean = (initialized) ? val : [reader readBoolean];
	[DebLog logN:@"BooleanReader -> %@", (boolean)?@"YES":@"NO"];
	return [BooleanType objectType:boolean];
}


@end
