//
//  Invoke.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 06.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

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
