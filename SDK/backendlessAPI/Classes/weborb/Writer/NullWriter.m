//
//  NullWriter.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 30.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "NullWriter.h"
#import "IProtocolFormatter.h"

@implementation NullWriter

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[NullWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)writer {
	
	if (!writer)
		return;
    
	[writer writeNull];
}

@end
