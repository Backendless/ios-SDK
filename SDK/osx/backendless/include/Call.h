//
//  Call.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 08.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IServiceCall.h"
#import "IPendingServiceCallback.h"

enum call_status
{
	STATUS_PENDING = 0x01,
	STATUS_SUCCESS_RESULT = 0x02,
	STATUS_SUCCESS_NULL = 0x03,
	STATUS_SUCCESS_VOID = 0x04,
	
	STATUS_SERVICE_NOT_FOUND = 0x10,
	STATUS_METHOD_NOT_FOUND = 0x11,
	STATUS_ACCESS_DENIED = 0x12,
	STATUS_INVOCATION_EXCEPTION = 0x13,
	STATUS_GENERAL_EXCEPTION = 0x14,
	STATUS_APP_SHUTTING_DOWN = 0x15,
};

@protocol IRTMPClientDelegate;

@interface Call : NSObject <IServiceCall> {
	id <IPendingServiceCallback>	sender;
	NSString	*serviceName;
	NSString	*serviceMethodName;
	NSArray		*arguments;
	uint		status;
	NSException *exception;
    int         invokeId;
}
//@property (nonatomic, assign) id <IPendingServiceCallback> sender;
@property (nonatomic, retain) id <IPendingServiceCallback> sender;
@property (nonatomic, assign) NSString *serviceName;
@property (nonatomic, assign) NSString *serviceMethodName;
@property (nonatomic, assign) NSArray *arguments;
@property (readwrite) uint status;
@property (nonatomic, assign) NSException *exception;

-(id)initWithMethod:(NSString *)method;
-(id)initWithMethod:(NSString *)method andArguments:(NSArray *)args;	
-(id)initWithName:(NSString *)name andMethod:(NSString *)method andArguments:(NSArray *)args;

@end
