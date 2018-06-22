//
//  AMFMessageWriter.m
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

#import "AMFMessageWriter.h"
#import "DEBUG.h"
#import "Request.h"
#import "MessageWriter.h"


@implementation AMFMessageWriter

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC AMFMessageWriter"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[AMFMessageWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)writer {
	
	if (!obj || !writer)
		return;
	
    Request *message = (Request *)obj;
    [writer beginWriteMessage:message];
    [writer writeMessageVersion:[message getVersion]];
    
    NSArray *headers = [message getResponseHeaders];
    [writer.writer writeUInt16:(unsigned short)headers.count];
    for (id header in headers)
        [[MessageWriter sharedInstance] writeObject:header format:writer];
        
    NSArray *bodies = [message getResponseBodies];
    [writer.writer writeUInt16:(unsigned short)bodies.count];
    for (id body in bodies)
        [[MessageWriter sharedInstance] writeObject:body format:writer];
    
    [writer endWriteMessage];
}

@end
