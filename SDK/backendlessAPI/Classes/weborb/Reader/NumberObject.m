//
//  NumberObject.m
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

#import "NumberObject.h"
#import "DEBUG.h"
#import "Types.h"
#import "ITypeReader.h"

@implementation NumberObject

-(id)initWithNumber:(NSNumber *)data
{	
	if ( (self=[super init]) ) {
		number = data;
	}
	
	return self;
}

+(id)objectType:(NSNumber *)data
{
	return [[[NumberObject alloc] initWithNumber:data] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC NumberObject"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark IAdaptingType Methods

-(Class)getDefaultType {
	return [number class];
}

-(id)defaultAdapt {
	
    [DebLog log:_ON_READERS_LOG_ text:@"NumberObject -> defaultAdapt"];
    
	return number;
}

-(id)adapt:(Class)type {
	
    [DebLog log:_ON_READERS_LOG_ text:@"NumberObject -> adapt: %@", type];
    
    if ([type conformsToProtocol:@protocol(IAdaptingType)]) {
        return self;
    }
	
	return number;
}

-(BOOL)canAdapt:(Class)formalArg {
	return NO;
}

-(BOOL)equals:(id)obj pairs:(NSDictionary *)visitedPairs {
	return [number isEqualToNumber:(NSNumber *)obj];
}

@end
