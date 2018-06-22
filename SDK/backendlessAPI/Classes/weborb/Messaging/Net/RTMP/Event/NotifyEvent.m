//
//
//  NotifyEvent.m
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

#import "NotifyEvent.h"
#import "DEBUG.h"
#import "RTMPConstants.h"


@implementation NotifyEvent
@synthesize call, data, invokeId, connectionParams;

-(id)init {	
	if ( (self=[super initWithType:SERVICE_CALL]) ) {
		call = nil;
		data = nil;
		invokeId = 0;
		connectionParams = nil;
	}
	
	return self;
}

-(id)initWithStream:(BinaryStream *)stream {	
	if ( (self=[super initWithType:SERVICE_CALL]) ) {
		call = nil;
		data = stream;
		invokeId = 0;
		connectionParams = nil;
	}
	
	return self;
}

-(id)initWithCall:(id <IServiceCall>)_call {	
	if ( (self=[super initWithType:SERVICE_CALL]) ) {
		call = _call;
		data = nil;
		invokeId = 0;
		connectionParams = nil;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC Notify"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(BOOL)equals:(id)event {
	
	if (!event)
		return NO;
	
	if (![event isKindOfClass:[NotifyEvent class]])
		return NO;
	
	NotifyEvent *other = (NotifyEvent *)event;
	
	if ((connectionParams == nil && other.connectionParams != nil) || (connectionParams != nil && other.connectionParams == nil))
		return NO;
	
	if (![connectionParams isEqualToDictionary:other.connectionParams])
		return NO;
	
	if (invokeId != other.invokeId)
		return NO;
	
	if (call != other.call)
		return NO;
	
	return YES;
}

-(NSString *)toString {
	return @"NotifyEvent";
}

-(void)releaseInternal {
	if (data) [data release];
}

-(NotifyEvent *)duplicate {
	
	// TODO
	
	return nil;
}

#pragma mark -
#pragma mark IRTMPEvent Methods

-(uint)getDataType {
	return TYPE_NOTIFY;
}

@end
