//
//  RTMessaging.m
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

#import "RTMessaging.h"
#import "RTListener+RTListenerMethods.h"

@interface RTMessaging() {
    NSMutableDictionary *onConnectCallbacks;
}
@end

@implementation RTMessaging

+(RTMessaging *)sharedInstance {
    static RTMessaging *sharedRTMessaging;
    @synchronized(self) {
        if (!sharedRTMessaging)
            sharedRTMessaging = [[RTMessaging alloc] init];
    }
    return sharedRTMessaging;
}

- (RTMessaging *)init {
    if (self = [super init]) {
        onConnectCallbacks = [NSMutableDictionary new];
    }
    return self;
}

-(void)addConnectListener:(NSString *)channel onConnect:(void (^)(void))onConnect {
    [self subscribeForPubSubConnect:channel onConnect:onConnect];
}

-(void)subscribeForPubSubConnect:(NSString *)channel onConnect:(void(^)(void))onConnect {
    
    void(^wrappedOnConnect)(id) = ^(id result) {
        onConnect();
    };
    [onConnectCallbacks setObject:wrappedOnConnect forKey:onConnect];
    [super addSimpleListener:PUB_SUB_CONNECT_TYPE callBack:wrappedOnConnect];
    
    NSDictionary *options = @{@"channel" : channel};
    [super addSubscription:PUB_SUB_CONNECT_TYPE options:options onResult:wrappedOnConnect handleResultSelector:nil fromClass:nil];
};

@end
