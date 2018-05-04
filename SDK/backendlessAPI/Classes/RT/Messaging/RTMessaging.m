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
}
@end

@implementation RTMessaging

-(instancetype)initWithChannelName:(NSString *)channelName {
    if (self = [super init]) {
        channel = channelName;
    }
    return self;
}

-(void)connect:(void(^)(id))onSuccessfulConnect onError:(void(^)(Fault *))onError {
    NSDictionary *options = @{@"channel"  : channel};
    [super addSubscription:PUB_SUB_CONNECT options:options onResult:onSuccessfulConnect onError:onError handleResultSelector:nil fromClass:nil];
}

-(void)addJoinListener:(BOOL)isConnected response:(void(^)(void))responseBlock error:(void (^)(Fault *))errorBlock {
    void(^wrappedBlock)(id) = ^(id result) { responseBlock(); };
    NSDictionary *options = @{@"channel"  : channel};
    [super addSubscription:PUB_SUB_CONNECT options:options onResult:wrappedBlock onError:errorBlock handleResultSelector:nil fromClass:nil];
}

-(void)removeJoinListeners {
    [super stopSubscriptionWithChannel:channel event:PUB_SUB_CONNECT whereClause:nil];
}

-(void)addMessageListener:(NSString *)selector response:(void(^)(PublishMessageInfo *))responseBlock error:(void (^)(Fault *))errorBlock {
    NSDictionary *options = @{@"channel"  : channel};
    if (selector) {
        options = @{@"channel"  : channel,
                    @"selector" : selector};
    }    
    [super addSubscription:PUB_SUB_MESSAGES options:options onResult:responseBlock onError:errorBlock handleResultSelector:@selector(handlePublishMessageInfo:) fromClass:self];
}

-(void)removeMessageListeners:(NSString *)selector {
    [super stopSubscriptionWithChannel:channel event:PUB_SUB_MESSAGES whereClause:selector];
}

-(PublishMessageInfo *)handlePublishMessageInfo:(NSDictionary *)jsonResult {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *messageData = [jsonHelper dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    PublishMessageInfo *messageInfo = [PublishMessageInfo new];
    messageInfo.messageId = [messageData valueForKey:@"messageId"];
    messageInfo.timestamp = [messageData valueForKey:@"timestamp"];
    messageInfo.message = [messageData valueForKey:@"message"];
    messageInfo.publisherId = [messageData valueForKey:@"publisherId"];
    messageInfo.subtopic = [messageData valueForKey:@"subtopic"];
    messageInfo.pushSinglecast = [messageData valueForKey:@"pushSinglecast"];
    messageInfo.pushBroadcast = [messageData valueForKey:@"pushBroadcast"];
    messageInfo.publishPolicy = [messageData valueForKey:@"publishPolicy"];
    messageInfo.query = [messageData valueForKey:@"query"];
    messageInfo.publishAt = [messageData valueForKey:@"publishAt"];
    messageInfo.repeatEvery = [messageData valueForKey:@"repeatEvery"];
    messageInfo.repeatExpiresAt = [messageData valueForKey:@"repeatExpiresAt"];
    messageInfo.headers = [messageData valueForKey:@"headers"];
    return messageInfo;
}

-(void) addCommandListener:(void(^)(CommandObject *))responseBlock error:(void (^)(Fault *))errorBlock {
    NSDictionary *options = @{@"channel" : channel};
    [super addSubscription:PUB_SUB_COMMANDS options:options onResult:responseBlock onError:errorBlock handleResultSelector:@selector(handleCommand:) fromClass:self];
}

-(void)removeCommandListeners {
    [super stopSubscriptionWithChannel:channel event:PUB_SUB_COMMANDS whereClause:nil];
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

-(void)removeUserStatusListeners {
    [super stopSubscriptionWithChannel:channel event:PUB_SUB_USERS whereClause:nil];
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
