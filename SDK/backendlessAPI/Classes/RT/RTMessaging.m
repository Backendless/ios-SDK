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
#import "Backendless.h"

@interface RTMessaging() {
    NSMapTable *onConnectCallbacks;
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
        onConnectCallbacks = [NSMapTable new];
    }
    return self;
}

-(void)addConnectListener:(NSString *)channel onConnect:(void(^)(void))onConnect {
    ///???
    [backendless.messaging subscribe:channel
                            response:^(BESubscription *subscription) {
                                [self subscribeForPubSubConnect:channel onConnect:onConnect];
                            } error:^(Fault *fault) {
                                [DebLog log:@"MessagingService -> subscribeForChannelAsync Error: %@", fault];
                            }];
}

-(void)removeConnectListener:(NSString *)channel onConnect:(void(^)(void))onConnect {
    NSLog(@"onConnectCallbacks: %@", onConnectCallbacks);
  
    void(^onRemoveConnect)(id) = [onConnectCallbacks objectForKey:onConnect];
    [super stopSubscription:PUB_SUB_CONNECT_TYPE whereClause:nil onResult:onRemoveConnect];
    [onConnectCallbacks removeObjectForKey:onConnect];
    
    NSLog(@"onConnectCallbacks: %@", onConnectCallbacks);
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
