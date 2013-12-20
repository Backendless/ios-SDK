//
//  Invoker.m
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

#import "Invoker.h"
#import "DEBUG.h"
#import "Backendless.h"
#import "WeborbClient.h"
#import "Responder.h"

static NSString *URL_ENDING = @"binary";
static NSString *URL_DESTINATION = @"GenericDestination";


@interface Invoker () {
    WeborbClient    *client;
}

@end

@implementation Invoker

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(Invoker *)sharedInstance {
	
    static Invoker *sharedInvoker;
	@synchronized(self)
	{
		if (!sharedInvoker)
			sharedInvoker = [Invoker new];
	}
	return sharedInvoker;
}

-(id)init {
	
    if ( (self=[super init]) ) {
        
        client = nil;
        _throwException = YES;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC Invoker"];

    [client release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Public Methods

-(void)setup {
    
    [client release];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/%@", backendless.hostURL, backendless.versionNum, URL_ENDING];
    client = [[WeborbClient alloc] initWithUrl:url destination:URL_DESTINATION];
    client.requestHeaders = backendless.headers;
    
    [DebLog log:@"Invoker -> init: url = %@, client.requestHeaders = \n%@", url, client.requestHeaders];
}

-(void)setRequestHeader:(NSString *)header value:(id)value {
    
    if (!header || !value)
        return;
    
    if (!client.requestHeaders)
        client.requestHeaders = [NSMutableDictionary new];
    
    [client.requestHeaders setObject:value forKey:header];
    
    [DebLog log:@"Invoker -> setRequestHeader: client.requestHeaders = \n%@", client.requestHeaders];
}

-(void)removeRequestHeader:(NSString *)header {
    
    if (!header || !client.requestHeaders)
        return;
    
    [client.requestHeaders removeObjectForKey:header];
    
    [DebLog log:@"Invoker -> removeRequestHeader: client.requestHeaders = \n%@", client.requestHeaders];
}

-(id)invokeSync:(NSString *)className method:(NSString *)methodName args:(NSArray *)args {
    
    id result = [client invoke:className method:methodName args:args];
    if (_throwException && [result isKindOfClass:[Fault class]])
        @throw result;
    
    return result;
}

-(void)invokeAsync:(NSString *)className method:(NSString *)methodName args:(NSArray *)args responder:(id <IResponder>)responder {    
    [client invoke:className method:methodName args:args responder:responder];
}

@end
