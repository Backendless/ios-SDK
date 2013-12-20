//
//  MessageStatus.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "MessageStatus.h"
#import "DEBUG.h"


@implementation MessageStatus

-(id)init {
	
    if ( (self=[super init]) ) {
        _messageId = nil;
        _status = nil;
        _errorMessage = nil;
	}
	
	return self;
}

-(id)initWithId:(NSString *)messageId {
	
    if ( (self=[super init]) ) {
        self.messageId = messageId;
        _status = nil;
        _errorMessage = nil;
	}
	
	return self;
}

-(id)initWithId:(NSString *)messageId status:(PublishStatusEnum)status {
	
    if ( (self=[super init]) ) {
        self.messageId = messageId;
        [self status:status];
        _errorMessage = nil;
	}
	
	return self;
}

-(id)initWithId:(NSString *)messageId status:(PublishStatusEnum)status errorMessage:(NSString *)errorMessage {
	
    if ( (self=[super init]) ) {
        self.messageId = messageId;
        [self status:status];
        self.errorMessage = errorMessage;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC MessageStatus"];
    
    [_messageId release];
    [_status release];
	[_errorMessage release];
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(PublishStatusEnum)valStatus {
    return (PublishStatusEnum)[_status intValue];
}

-(void)status:(PublishStatusEnum)status {
    _status = [[NSNumber alloc] initWithUnsignedInt:(unsigned int)status];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<MessageStatus> messageId: %@, status: %@ errorMessage: %@", _messageId, _status, _errorMessage];
}

@end
