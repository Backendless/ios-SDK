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
    [super addSubscription:PUB_SUB_CONNECT options:options onResult:onSuccessfulConnect onError:nil handleResultSelector:nil fromClass:nil];
}

-(void)addConnectListener:(BOOL)isConnected response:(void (^)(void))responseBlock error:(void (^)(Fault *))errorBlock {
    void(^wrappedBlock)(id) = ^(id result) { responseBlock(); };
    [onConnectCallbacks setObject:wrappedBlock forKey:responseBlock];
    NSDictionary *options = @{@"channel"  : channel};
    [super addSubscription:PUB_SUB_CONNECT options:options onResult:wrappedBlock onError:errorBlock handleResultSelector:nil fromClass:nil];
}

-(void)removeConnectListeners:(void(^)(void))responseBlock {
    [super stopSubscriptionWithChannel:channel event:PUB_SUB_CONNECT whereClause:nil onResult:[onConnectCallbacks objectForKey:responseBlock]];
}

-(void)addMessageListener:(NSString *)selector response:(void(^)(Message *))responseBlock error:(void (^)(Fault *))errorBlock {
    NSDictionary *options = @{@"channel"  : channel};
    if (selector) {
        options = @{@"channel"  : channel,
                    @"selector" : selector};
    }
    [super addSubscription:PUB_SUB_MESSAGES options:options onResult:responseBlock onError:errorBlock handleResultSelector:@selector(handleMessage:) fromClass:self];
}

-(void)removeMessageListeners:(NSString *)selector response:(void(^)(Message *))responseBlock {
    [super stopSubscriptionWithChannel:channel event:PUB_SUB_MESSAGES whereClause:selector onResult:responseBlock];
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

-(void) addCommandListener:(void(^)(CommandObject *))responseBlock error:(void (^)(Fault *))errorBlock {
    NSDictionary *options = @{@"channel" : channel};
    [super addSubscription:PUB_SUB_COMMANDS options:options onResult:responseBlock onError:errorBlock handleResultSelector:@selector(handleCommand:) fromClass:self];
}

-(void)removeCommandListeners:(void(^)(CommandObject *))responseBlock {
    [super stopSubscriptionWithChannel:channel event:PUB_SUB_COMMANDS whereClause:nil onResult:responseBlock];
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

-(void)addUserStatusListener:(void(^)(UserStatusObject *))responseBlock error:(void (^)(Fault *))errorBlock {
    NSDictionary *options = @{@"channel" : channel};
    [super addSubscription:PUB_SUB_USERS options:options onResult:responseBlock onError:errorBlock handleResultSelector:@selector(handleUserStatus:) fromClass:self];
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
