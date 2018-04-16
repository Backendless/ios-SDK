//
//  ReqMessage.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "ReqMessage.h"


@implementation ReqMessage
@synthesize operation, source, messageRefType;

-(id)init {	
	if ( (self=[super init]) ) {
        operation = nil;
        source = nil;
        messageRefType = nil;
	}
	
	return self;
}

@end
