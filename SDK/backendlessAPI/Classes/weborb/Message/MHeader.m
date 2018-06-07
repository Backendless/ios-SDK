//
//  MHeader.m
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

#import "MHeader.h"


@implementation MHeader
@synthesize headerName, mustUnderstand, headerValue;

-(id)init {	
	if ( (self=[super init]) ) {
        headerName = nil;
        headerValue = nil;
        mustUnderstand = NO;
	}
	
	return self;
}

-(id)initWithObject:(id <IAdaptingType>)dataObj name:(NSString *)name understand:(BOOL)must length:(int)length {
	if ( (self=[super init]) ) {
        headerName = name;
        headerValue = dataObj;
        mustUnderstand = must;
	}
	
	return self;
}

+(id)headerWithObject:(id <IAdaptingType>)dataObj name:(NSString *)name understand:(BOOL)must length:(int)length {
	return [[[MHeader alloc] initWithObject:dataObj name:name understand:must length:length] autorelease];
}

+(id)headerWithObject:(id <IAdaptingType>)dataObj name:(NSString *)name {
	return [[[MHeader alloc] initWithObject:dataObj name:name understand:NO length:-1] autorelease];
}

@end
