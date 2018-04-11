//
//  Events.m
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

#import "Events.h"
#import "Backendless.h"
#import "Invoker.h"

static NSString *SERVER_EVENTS_PATH = @"com.backendless.services.servercode.EventHandler";
static NSString *METHOD_DISPATCH_EVENT = @"dispatchEvent";

@implementation Events

-(void)dealloc {
	[DebLog logN:@"DEALLOC Events"];
	[super dealloc];
}

// sync methods with fault return (as exception)

-(NSDictionary *)dispatch:(NSString *)name args:(NSDictionary *)eventArgs {    
    NSArray *args = @[name, eventArgs];
    return [invoker invokeSync:SERVER_EVENTS_PATH method:METHOD_DISPATCH_EVENT args:args];
}

// async methods with responder

-(void)dispatch:(NSString *)name args:(NSDictionary *)eventArgs responder:(id<IResponder>)responder {
    NSArray *args = @[name, eventArgs];
    [invoker invokeAsync:SERVER_EVENTS_PATH method:METHOD_DISPATCH_EVENT args:args responder:responder];
}

// async methods with block-based callbacks

-(void)dispatch:(NSString *)name args:(NSDictionary *)eventArgs response:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self dispatch:name args:eventArgs responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

@end
