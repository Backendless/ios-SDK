//
//  Events.m
//  backendlessAPI
//
//  Created by Yury Yaschenko on 6/25/14.
//  Copyright (c) 2014 BACKENDLESS.COM. All rights reserved.
//

#import "Events.h"
#import "Backendless.h"
#import "Invoker.h"

static NSString *SERVER_EVENTS_PATH = @"com.backendless.services.servercode.EventHandler";

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

//api

-(NSDictionary *)dispatchEventName:(NSString *)name args:(NSDictionary *)eventArgs fault:(Fault **)fault
{
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, name, eventArgs nil];
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

-(void)dispatchEventName:(NSString *)name args:(NSDictionary *)eventArgs responder:(id<IResponder>)responder
{
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, name, eventArgs nil];
    [invoker invokeAsync:SERVER_EVENTS_PATH method:METHOD_DISPATCH_EVENT args:args responder:responder];
}

-(void)dispatchEventName:(NSString *)name args:(NSDictionary *)eventArgs response:(void (^)(NSDictionary *))responseBlock error:(void (^)(Fault *))errorBlock
{
    [self dispatchEventName:name args:eventArgs responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}
@end
