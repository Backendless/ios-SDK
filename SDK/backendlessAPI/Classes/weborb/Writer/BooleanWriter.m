//
//  BooleanWriter.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 30.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "BooleanWriter.h"
#import "IProtocolFormatter.h"


@implementation BooleanWriter

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[BooleanWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)writer {
	
	if (!obj || !writer)
		return;
    
	[writer writeBoolean:[(NSNumber *)obj boolValue]];
}

@end
