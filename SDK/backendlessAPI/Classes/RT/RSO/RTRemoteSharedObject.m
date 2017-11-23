//
//  RTRemoteSharedObject.m
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

#import "RTRemoteSharedObject.h"
#import "RTMethod.h"

@interface RTRemoteSharedObject() {
    NSString *rso;
    NSMapTable *onConnectCallbacks;
}
@end

@implementation RTRemoteSharedObject

-(instancetype)initWithRSOName:(NSString *)rsoName {
    if (self = [super init]) {
        rso = rsoName;
        onConnectCallbacks = [NSMapTable new];
    }
    return self;
}

-(void)connect:(void(^)(id))onSuccessfulConnect {
    NSDictionary *options = @{@"name"  : rso};
    [super addSubscription:RSO_CONNECT options:options onResult:onSuccessfulConnect handleResultSelector:nil fromClass:nil];
}

-(void)addErrorListener:(void(^)(Fault *))onError {
    [super addSimpleListener:ERROR callBack:onError];
}

-(void)removeErrorListener:(void(^)(Fault *))onError {
    [super removeSimpleListener:ERROR callBack:onError];
}

-(void)addConnectListener:(BOOL)isConnected onConnect:(void(^)(void))onConnect {
    void(^wrappedOnConnect)(id) = ^(id result) { onConnect(); };
    [onConnectCallbacks setObject:wrappedOnConnect forKey:onConnect];
    [super addSimpleListener:RSO_CONNECT callBack:wrappedOnConnect];
    if (isConnected) {
        onConnect();
    }
}

-(void)removeConnectListener:(void(^)(void))onConnect {
    [super removeSimpleListener:RSO_CONNECT callBack:[onConnectCallbacks objectForKey:onConnect]];
    [super stopSubscriptionWithRSO:rso event:RSO_CONNECT onResult:[onConnectCallbacks objectForKey:onConnect]];
}

// *************************************************

-(void)addChangesListener:(void(^)(RSOChangesObject *))onChange {
    NSDictionary *options = @{@"name" : rso};
    [super addSubscription:RSO_CHANGES options:options onResult:onChange handleResultSelector:@selector(handleRSOChanges:) fromClass:self];
}

-(void)removeChangesListener:(void(^)(RSOChangesObject *))onChange {
    [super stopSubscriptionWithRSO:rso event:RSO_CHANGES onResult:onChange];
}

-(RSOChangesObject *)handleRSOChanges:(NSDictionary *)jsonResult {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *rsoChangesData = [self dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];    
    RSOChangesObject *rsoChangesObject = [RSOChangesObject new];    
    rsoChangesObject.key = [rsoChangesData valueForKey:@"key"];
    rsoChangesObject.data = [rsoChangesData valueForKey:@"data"];
    rsoChangesObject.connectionId = [rsoChangesData valueForKey:@"connectionId"];
    rsoChangesObject.userId = [rsoChangesData valueForKey:@"userId"];
    return rsoChangesObject;
}

// *************************************************

-(void)addClearListener:(void (^)(RSOClearedObject *))onClear {
    NSDictionary *options = @{@"name" : rso};
    [super addSubscription:RSO_CLEARED options:options onResult:onClear handleResultSelector:@selector(handleRSOCleared:) fromClass:self];
}

-(void)removeClearListener:(void (^)(RSOClearedObject *))onClear {
    [super stopSubscriptionWithRSO:rso event:RSO_CLEARED onResult:onClear];
}

-(RSOClearedObject *)handleRSOCleared:(NSDictionary *)jsonResult {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *rsoClearedData = [self dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    RSOClearedObject *rsoClearedObject = [RSOClearedObject new];
    rsoClearedObject.connectionId = [rsoClearedData valueForKey:@"connectionId"];
    rsoClearedObject.userId = [rsoClearedData valueForKey:@"userId"];
    return rsoClearedObject;
}

// *************************************************

-(void)addCommandListener:(void (^)(CommandObject *))onCommand {
    NSDictionary *options = @{@"name" : rso};
    [super addSubscription:RSO_COMMANDS options:options onResult:onCommand handleResultSelector:@selector(handleCommand:) fromClass:self];
}

-(void)removeCommandListener:(void (^)(CommandObject *))onCommand {
    [super stopSubscriptionWithRSO:rso event:RSO_COMMANDS onResult:onCommand];
}

-(CommandObject *)handleCommand:(NSDictionary *)jsonResult {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *commandData = [self dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    CommandObject *command = [CommandObject new];
    command.type = [commandData valueForKey:@"type"];
    command.connectionId = [commandData valueForKey:@"connectionId"];
    command.userId = [commandData valueForKey:@"userId"];
    command.data = [commandData valueForKey:@"data"];
    return command;
}

-(void)addUserStatusListener:(void(^)(UserStatusObject *))onUserStatus {
    NSDictionary *options = @{@"name" : rso};
    [super addSubscription:RSO_USERS options:options onResult:onUserStatus handleResultSelector:@selector(handleUserStatus:) fromClass:self];
}

-(void)removeUserStatusListener:(void(^)(UserStatusObject *))onUserStatus {
    [super stopSubscriptionWithRSO:rso event:RSO_USERS onResult:onUserStatus];
}

-(UserStatusObject *)handleUserStatus:(NSDictionary *)jsonResult {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *userStatusData = [self dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    UserStatusObject *userStatus = [UserStatusObject new];
    userStatus.status = [userStatusData valueForKey:@"status"];
    userStatus.data = [userStatusData valueForKey:@"data"];
    return userStatus;
}

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

// commands

-(void)get:(NSString *)key onSuccess:(void(^)(id))onSuccess onError:(void (^)(Fault *))onError {
    NSDictionary *options = @{@"name"   : rso,
                              @"key"    : key};
    [rtMethod sendCommand:RSO_GET options:options onSuccess:onSuccess onError:onError];
}

-(void)set:(NSString *)key data:(id)data onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError {
    NSDictionary *options = @{@"name"   : rso,
                              @"key"    : key};
    if (data) {
        options = @{@"name"   : rso,
                    @"key"    : key,
                    @"data"   : data};
    }
    [rtMethod sendCommand:RSO_SET options:options onSuccess:onSuccess onError:onError];
}

-(void)clear:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError {
    NSDictionary *options = @{@"name"   : rso};
    [rtMethod sendCommand:RSO_CLEAR options:options onSuccess:onSuccess onError:onError];
}

-(void)sendCommand:(NSString *)commandName data:(id)data onSuccess:(void (^)(id))onSuccess onError:(void (^)(Fault *))onError {
    NSDictionary *options = @{@"name"   : rso,
                              @"type"   : commandName};
    if (data) {
        options = @{@"name" : rso,
                    @"type" : commandName,
                    @"data" : data};
    }
    [rtMethod sendCommand:RSO_COMMAND options:options onSuccess:onSuccess onError:onError];
}

@end
