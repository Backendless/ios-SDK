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
    NSMapTable *onConnectCallbacks;
    NSString *channel;
}
@end

@implementation RTMessaging

-(RTMessaging *)initWithChannelName:(NSString *)channelName {
    if (self = [super init]) {
        onConnectCallbacks = [NSMapTable new];
        channel = channelName;
    }
    return self;
}

-(void)connect:(void(^)(id))onSuccessfulConnect {
    NSDictionary *options = @{@"channel"  : channel};
    [super addSubscription:PUB_SUB_CONNECT_TYPE options:options onResult:onSuccessfulConnect handleResultSelector:nil fromClass:nil];
}

// **************************************************

-(void)addErrorListener:(void(^)(Fault *))onError {
    [super addSimpleListener:ERROR_TYPE callBack:onError];
}

-(void)removeErrorListener:(void(^)(Fault *))onError {
    [super removeSimpleListener:ERROR_TYPE callBack:onError];
}

// **************************************************

-(void)addConnectListener:(BOOL)isConnected onConnect:(void (^)(void))onConnect {
    void(^wrappedOnConnect)(id) = ^(id result) { onConnect(); };
    [onConnectCallbacks setObject:wrappedOnConnect forKey:onConnect];
    [super addSimpleListener:PUB_SUB_CONNECT_TYPE callBack:wrappedOnConnect];
    if (isConnected) {
        onConnect();
    }
}

-(void)removeConnectListener:(void(^)(void))onConnect {
    [super removeSimpleListener:PUB_SUB_CONNECT_TYPE callBack:[onConnectCallbacks objectForKey:onConnect]];
    [super stopSubscription:channel event:PUB_SUB_CONNECT_TYPE whereClause:nil onResult:[onConnectCallbacks objectForKey:onConnect]];
}

// **************************************************

-(void)addMessageListener:(NSString *)selector onMessage:(void(^)(Message *))onMessage {
    NSDictionary *options = @{@"channel"  : channel};
    if (selector) {
        options = @{@"channel"  : channel,
                    @"selector" : selector};
    }
    [super addSubscription:PUB_SUB_MESSAGES_TYPE options:options onResult:onMessage handleResultSelector:@selector(handleMessage:) fromClass:self];
}

-(void)removeMessageListener:(NSString *)selector onMessage:(void (^)(Message *))onMessage {
    [super stopSubscription:channel event:PUB_SUB_MESSAGES_TYPE whereClause:selector onResult:onMessage];
}

-(Message *)handleMessage:(NSDictionary *)jsonResult {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *messageData = [self dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    Message *message = [Message new];
    message.data = messageData;
    message.headers = [messageData valueForKey:@"headers"];
    message.publisherId = [messageData valueForKey:@"publisherId"];
    return message;
}

// **************************************************

-(NSDictionary *)dictionaryFromJson:(NSString *)JSONString {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    NSError *error;
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
    for (NSString *fieldName in JSONDictionary) {
        if (![fieldName isEqualToString:@"___jsonclass"] && ![fieldName isEqualToString:@"__meta"] && ![fieldName isEqualToString:@"___class"]) {
            [dictionary setValue:[JSONDictionary valueForKey:fieldName] forKey:fieldName];
        }
    }
    return dictionary;
}

@end
