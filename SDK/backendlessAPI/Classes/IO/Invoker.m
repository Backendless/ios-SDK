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

#import "Invoker.h"
#import "DEBUG.h"
#import "Backendless.h"
#import "WeborbClient.h"
#import "AdaptResponder.h"
#import "DefaultAdapter.h"
#import "DeviceRegistrationAdapter.h"

static NSString *URL_ENDING = @"binary";
static NSString *URL_DESTINATION = @"GenericDestination";

@interface Invoker() {
    WeborbClient *client;
}
@end

@implementation Invoker

+(Invoker *)sharedInstance {
    static Invoker *sharedInvoker;
    @synchronized(self) {
        if (!sharedInvoker)
            sharedInvoker = [Invoker new];
    }
    return sharedInvoker;
}

-(id)init {
    if (self = [super init]) {
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

#pragma mark Public Methods

-(void)setup {
    [client release];
    NSString *url = [NSString stringWithFormat:@"%@/%@/%@/%@", backendless.hostURL, backendless.appID, backendless.apiKey, URL_ENDING];
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

-(void)setNetworkActivityIndicatorOn:(BOOL)value {
    [client setNetworkActivityIndicatorOn:value];
}

-(id)invokeSync:(NSString *)className method:(NSString *)methodName args:(NSArray *)args  {
    return [self invokeSync:className method:methodName args:args responseAdapter:[DefaultAdapter new]];
}

-(id)invokeSync:(NSString *)className method:(NSString *)methodName args:(NSArray *)args responseAdapter:(id<IResponseAdapter>)responseAdapter {
    id type = [client invoke:className method:methodName args:args];
    return [responseAdapter adapt:type];
}

-(void)invokeAsync:(NSString *)className method:(NSString *)methodName args:(NSArray *)args responder:(id <IResponder>)responder {
    [self invokeAsync:className method:methodName args:args responder:responder responseAdapter:[DefaultAdapter new]];
}

-(void)invokeAsync:(NSString *)className method:(NSString *)methodName args:(NSArray *)args responder:(id <IResponder>)responder responseAdapter:(id<IResponseAdapter>)responseAdapter {
    AdaptResponder *_responder = [[AdaptResponder alloc] initWithResponder:responder responseAdapter:responseAdapter];
    _responder.chained = responder;
    [client invoke:className method:methodName args:args responder:_responder];
}

@end
