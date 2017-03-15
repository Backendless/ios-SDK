//
//  BoundPropertyBagWriter.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 26.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "BoundPropertyBagWriter.h"
#import "MessageWriter.h"
#import "IObjectSerializer.h"
#import "DEBUG.h"


@implementation BoundPropertyBagWriter

#pragma mark -
#pragma mark Private Methods

-(NSString *)getClientClass:(NSDictionary *)dictionary {
    // TODO: extract client class
    return nil;
}

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[BoundPropertyBagWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)writer {
	
	[DebLog log:_ON_WRITERS_LOG_ text:@"BoundPropertyBagWriter -> write:%@ format:%@", obj, writer];
	
	if (!obj || !writer)
		return;
    
    NSDictionary *props = (NSDictionary *)obj;
    id <IObjectSerializer> serializer = [writer getObjectSerializer];
	[serializer writeObject:[self getClientClass:props] fields:props format:writer];
}

@end
