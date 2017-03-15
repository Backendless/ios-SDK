//
//  ClassDefinition.m
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/11/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

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
