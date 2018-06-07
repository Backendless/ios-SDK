//
//  RTHelper.m
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

#import "RTHelper.h"
#import "Invoker.h"
#import "Responder.h"
#import "Backendless.h"

static NSString *SERVER_RT_SERVICE_PATH  = @"com.backendless.rt.RTService";
static NSString *METHOD_LOOKUP  = @"lookup";

@implementation RTHelper

+(id)lookup {
    id result = [invoker invokeSync:SERVER_RT_SERVICE_PATH method:METHOD_LOOKUP args:@[]];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

@end
