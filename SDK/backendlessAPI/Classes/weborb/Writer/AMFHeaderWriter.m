//
//  AMFHeaderWriter.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */


#import "AMFHeaderWriter.h"
#import "DEBUG.h"
#import "MHeader.h"
#import "MessageWriter.h"


@implementation AMFHeaderWriter

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC AMFHeaderWriter"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[AMFHeaderWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)writer {
	
	if (!obj || !writer)
		return;
	
    MHeader *header = (MHeader *)obj;
    [writer.writer writeString:header.headerName];
    [writer.writer writeBoolean:header.mustUnderstand];
    [writer.writer writeInt:-1];
    [[MessageWriter sharedInstance] writeObject:header.headerValue format:writer];
}

@end
