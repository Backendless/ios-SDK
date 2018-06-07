//
//  PendingCall.m
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

#import "PendingCall.h"
#import "DEBUG.h"


@implementation PendingCall

-(id)init {	
	if ( (self=[super init]) ) {
		_result = nil;
		callbacks = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(id)initWithMethod:(NSString *)method {	
	if ( (self=[super initWithMethod:method]) ) {
		_result = nil;
		callbacks = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(id)initWithMethod:(NSString *)method andArguments:(NSArray *)args {	
	if ( (self=[super initWithMethod:method andArguments:args]) ) {
		_result = nil;
		callbacks = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(id)initWithName:(NSString *)name andMethod:(NSString *)method andArguments:(NSArray *)args {	
	if ( (self=[super initWithName:name andMethod:method andArguments:args]) ) {
		_result = nil;
		callbacks = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC PendingCall"];
	
	[callbacks removeAllObjects];
	[callbacks release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(void)registerCallback:(id <IPendingServiceCallback>)callback {
	[callbacks addObject:callback];
}
																
-(void)unregisterCallback:(id <IPendingServiceCallback>)callback {
	[callbacks removeObject:callback];
}

-(NSArray *)getCallbacks {
	return callbacks;
}

-(id)getResult;  {
    return _result;
}

-(void)setResult:(id)result {
    _result = result;
}
						  
@end
