//
//  BoundPropertyBagWriter.m
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
