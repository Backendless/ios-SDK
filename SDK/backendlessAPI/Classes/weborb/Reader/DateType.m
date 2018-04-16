//
//  DateType.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 01.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

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
