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

// SERVICE NAME
static NSString *SERVER_EVENTS_PATH = @"com.backendless.services.servercode.EventHandler";
// METHOD NAMES
static NSString *METHOD_DISPATCH_EVENT = @"dispatchEvent";

@implementation Events

-(id)init {
	if ( (self=[super init]) ) {
        
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC Events"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

// sync methods with fault option

-(NSDictionary *)dispatch:(NSString *)name args:(NSDictionary *)eventArgs fault:(Fault **)fault
{
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, name, eventArgs, nil];
    id result = [invoker invokeSync:SERVER_EVENTS_PATH method:METHOD_DISPATCH_EVENT args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

// async methods with responder

-(void)dispatch:(NSString *)name args:(NSDictionary *)eventArgs responder:(id<IResponder>)responder
{
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, name, eventArgs, nil];
    [invoker invokeAsync:SERVER_EVENTS_PATH method:METHOD_DISPATCH_EVENT args:args responder:responder];
}

-(void)dispatch:(NSString *)name args:(NSDictionary *)eventArgs response:(void (^)(NSDictionary *))responseBlock error:(void (^)(Fault *))errorBlock
{
    [self dispatch:name args:eventArgs responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

@end
