//
//  BodyHolder.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "BodyHolder.h"


@implementation BodyHolder
@synthesize body;

-(id)init {	
	if ( (self=[super init]) ) {
        body = nil;
	}
	
	return self;
}

@end
