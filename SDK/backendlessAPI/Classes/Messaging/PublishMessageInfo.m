//
//  PublishMessageInfo.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2017 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "PublishMessageInfo.h"
#import "DEBUG.h"

@implementation PublishMessageInfo
@synthesize message, publisherId, subtopic, pushBroadcast, pushSinglecast, headers;

-(id)init {
    if (self = [super init]) {
        message = nil;
        publisherId = nil;
        subtopic = nil;
        pushBroadcast = nil;
        pushSinglecast = nil;
        headers = nil;
	}
	return self;
}

@end
