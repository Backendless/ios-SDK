//
//  ByteArrayType.m
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

#import "ByteArrayType.h"
#import "DEBUG.h"


@implementation ByteArrayType

-(id)initWithData:(NSData *)data {	
	if ( (self=[super init]) ) {
		dataValue = [data retain];
	}
	
	return self;
}

+(id)objectType:(NSData *)data {
	return [[[ByteArrayType alloc] initWithData:data] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC ByteArrayType"];
    
    [dataValue release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark IAdaptingType Methods

-(Class)getDefaultType {
	return [dataValue class];
}

-(id)defaultAdapt {
	return dataValue;
}

-(id)adapt:(Class)type {
	
    [DebLog logN:@"ByteArrayType -> adapt: %@", type];
	
    return dataValue;
}

-(BOOL)canAdapt:(Class)formalArg {
	return NO;
}

-(BOOL)equals:(id)obj pairs:(NSDictionary *)visitedPairs {
	return NO;
}

@end
