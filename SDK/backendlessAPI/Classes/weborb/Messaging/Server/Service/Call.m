//
//  Call.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 08.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "Call.h"
#import "DEBUG.h"


@implementation Call
@synthesize sender, serviceName, serviceMethodName, arguments, status, exception;

-(id)init {	
	if ( (self=[super init]) ) {
		sender = nil;
		serviceName = nil;
		serviceMethodName = nil;
		arguments = nil;
		status = STATUS_PENDING;
		exception = nil;
        invokeId = 0;
	}
	
	return self;
}

-(id)initWithMethod:(NSString *)method {	
	if ( (self=[super init]) ) {
		sender = nil;
		serviceName = nil;
		serviceMethodName = method;
		arguments = nil;
		status = STATUS_PENDING;
		exception = nil;
        invokeId = 0;
	}
	
	return self;
}

-(id)initWithMethod:(NSString *)method andArguments:(NSArray *)args {	
	if ( (self=[super init]) ) {
		sender = nil;
		serviceName = nil;
		serviceMethodName = method;
		arguments = args;
		status = STATUS_PENDING;
		exception = nil;
        invokeId = 0;
	}
	
	return self;
}

-(id)initWithName:(NSString *)name andMethod:(NSString *)method andArguments:(NSArray *)args {	
	if ( (self=[super init]) ) {
		sender = nil;
		serviceName = name;
		serviceMethodName = method;
		arguments = args;
		status = STATUS_PENDING;
		exception = nil;
        invokeId = 0;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC Call"];
    
    [sender release]; // if (retain) property !!!
	
	[super dealloc];
}

#pragma mark -
#pragma mark IServiceCall Methods

-(BOOL)isSuccess {
	return (status == STATUS_SUCCESS_RESULT) || (status == STATUS_SUCCESS_NULL) || (status == STATUS_SUCCESS_VOID);
}

-(NSString *)getServiceMethodName {
    return serviceMethodName;
}

-(NSString *)getServiceName {
    return serviceName;
}

-(NSArray *)getArguments {
    return arguments;
}

-(uint)getStatus {
    return status;
}
    
-(NSException *)getException {
    return exception;
}

-(void)setInvokeId:(int)_invokeId {
    invokeId = _invokeId;
}
-(int)getInvokeId {
    return invokeId;
}

@end
