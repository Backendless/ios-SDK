//
//  MHeader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

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
