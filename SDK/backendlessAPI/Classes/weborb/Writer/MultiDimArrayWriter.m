//
//  MultiDimArrayWriter.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 11.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "MultiDimArrayWriter.h"
#import "IProtocolFormatter.h"


@implementation MultiDimArrayWriter

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[MultiDimArrayWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)writer {
	
	if (!obj || !writer)
		return;
}

@end
