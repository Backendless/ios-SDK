//
//  AMFBodyWriter.m
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


#import "AMFBodyWriter.h"
#import "DEBUG.h"
#import "Body.h"
#import "MessageWriter.h"


@implementation AMFBodyWriter

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC AMFBodyWriter"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[AMFBodyWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)writer {
	
	if (!obj || !writer)
		return;
	
    NSString *null = @"null";
    Body *body = (Body *)obj;
    [writer.writer writeString:(body.responseUri)?body.responseUri:null];
    [writer.writer writeString:(body.serviceUri)?body.serviceUri:null];
    [writer.writer writeInt:-1];
    [writer resetReferenceCache];
    [writer beginWriteBodyContent];
    [[MessageWriter sharedInstance] writeObject:body.responseDataObject format:writer];
    [writer endWriteBodyContent];
}

@end
