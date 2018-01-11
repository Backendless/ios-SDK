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
#import "RTListener.h"
#import "JSONHelper.h"

@interface RTMessaging() {
    NSString *channel;
    NSMapTable *onConnectCallbacks;
}
@end

@implementation RTMessaging

-(instancetype)initWithChannelName:(NSString *)channelName {
    if (self = [super init]) {
        channel = channelName;
        onConnectCallbacks = [NSMapTable new];
    }
    return self;
}

-(void)connect:(void(^)(id))onSuccessfulConnect {
    NSDictionary *options = @{@"channel"  : channel};
    [super addSubscription:PUB_SUB_CONNECT options:options onResult:onSuccessfulConnect handleResultSelector:nil fromClass:nil];
}

-(void)addErrorListener:(void(^)(Fault *))onError {
    [super addSimpleListener:ERROR callBack:onError];
}

-(void)removeErrorListeners:(void(^)(Fault *))onError {
    [super removeSimpleListeners:ERROR callBack:onError];
}

-(void)addConnectListener:(BOOL)isConnected onConnect:(void(^)(void))onConnect {
    void(^wrappedOnConnect)(id) = ^(id result) { onConnect(); };
    [onConnectCallbacks setObject:wrappedOnConnect forKey:onConnect];
    [super addSimpleListener:PUB_SUB_CONNECT callBack:wrappedOnConnect];
    if (isConnected) {
        onConnect();
    }
}

-(void)removeConnectListeners:(void(^)(void))onConnect {
    [super removeSimpleListeners:PUB_SUB_CONNECT callBack:[onConnectCallbacks objectForKey:onConnect]];
    [super stopSubscriptionWithChannel:channel event:PUB_SUB_CONNECT whereClause:nil onResult:[onConnectCallbacks objectForKey:onConnect]];
}

-(void)addMessageListener:(NSString *)selector onMessage:(void(^)(Message *))onMessage {
    NSDictionary *options = @{@"channel"  : channel};
    if (selector) {
        options = @{@"channel"  : channel,
                    @"selector" : selector};
    }
    [super addSubscription:PUB_SUB_MESSAGES options:options onResult:onMessage handleResultSelector:@selector(handleMessage:) fromClass:self];
}

-(void)removeMessageListeners:(NSString *)selector onMessage:(void(^)(Message *))onMessage {
    [super stopSubscriptionWithChannel:channel event:PUB_SUB_MESSAGES whereClause:selector onResult:onMessage];
}

-(Message *)handleMessage:(NSDictionary *)jsonResult {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *messageData = [jsonHelper dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    Message *message = [Message new];
    message.data = messageData;
    message.headers = [messageData valueForKey:@"headers"];
    message.publisherId = [messageData valueForKey:@"publisherId"];
    return message;
}

-(void) addCommandListener:(void(^)(CommandObject *))onCommand {
    NSDictionary *options = @{@"channel" : channel};
    [super addSubscription:PUB_SUB_COMMANDS options:options onResult:onCommand handleResultSelector:@selector(handleCommand:) fromClass:self];
}

-(void)removeCommandListeners:(void(^)(CommandObject *))onCommand {
    [super stopSubscriptionWithChannel:channel event:PUB_SUB_COMMANDS whereClause:nil onResult:onCommand];
}

-(CommandObject *)handleCommand:(NSDictionary *)jsonResult {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *commandData = [jsonHelper dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    CommandObject *command = [CommandObject new];
    command.type = [commandData valueForKey:@"type"];
    command.connectionId = [commandData valueForKey:@"connectionId"];
    command.userId = [commandData valueForKey:@"userId"];
    command.data = [jsonHelper parseBackObjectForJSON:[commandData valueForKey:@"data"]];
    return command;
}

-(void)addUserStatusListener:(void(^)(UserStatusObject *))onUserStatus {
    NSDictionary *options = @{@"channel" : channel};
    [super addSubscription:PUB_SUB_USERS options:options onResult:onUserStatus handleResultSelector:@selector(handleUserStatus:) fromClass:self];
}

-(void)removeUserStatusListeners:(void(^)(UserStatusObject *))onUserStatus {
    [super stopSubscriptionWithChannel:channel event:PUB_SUB_USERS whereClause:nil onResult:onUserStatus];
}

-(UserStatusObject *)handleUserStatus:(NSDictionary *)jsonResult {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *userStatusData = [jsonHelper dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    UserStatusObject *userStatus = [UserStatusObject new];
    userStatus.status = [userStatusData valueForKey:@"status"];
    userStatus.data = [userStatusData valueForKey:@"data"];
    return userStatus;
}

@end
