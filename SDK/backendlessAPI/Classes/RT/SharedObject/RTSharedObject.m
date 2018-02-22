//
//  RTSharedObject.m
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

#import "RTSharedObject.h"
#import "RTMethod.h"
#import "JSONHelper.h"
#import <objc/runtime.h>

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@interface RTSharedObject() {
    NSString *sharedObjectName;
    NSMapTable *onConnectCallbacks;
}
@end

@implementation RTSharedObject

-(instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        sharedObjectName = name;
        onConnectCallbacks = [NSMapTable new];
    }
    return self;
}

-(void)connect:(void(^)(id))onSuccessfulConnect onError:(void (^)(Fault *))onError {    
    NSDictionary *options = @{@"name"  : sharedObjectName};
    [super addSubscription:RSO_CONNECT options:options onResult:onSuccessfulConnect onError:nil handleResultSelector:nil fromClass:nil];
}

-(void)addConnectListener:(BOOL)isConnected response:(void (^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    void(^wrappedBlock)(id) = ^(id result) { responseBlock(); };
    [onConnectCallbacks setObject:wrappedBlock forKey:responseBlock];
    NSDictionary *options = @{@"name"  : sharedObjectName};
    [super addSubscription:RSO_CONNECT options:options onResult:wrappedBlock onError:errorBlock handleResultSelector:nil fromClass:nil];
}

-(void)removeConnectListener:(void(^)(void))responseBlock {
    [super stopSubscriptionWithSharedObject:sharedObjectName event:RSO_CONNECT onResult:[onConnectCallbacks objectForKey:responseBlock]];
}

-(void)addChangesListener:(void(^)(SharedObjectChanges *))responseBlock error:(void(^)(Fault *))errorBlock {
    NSDictionary *options = @{@"name" : sharedObjectName};
    [super addSubscription:RSO_CHANGES options:options onResult:responseBlock onError:errorBlock handleResultSelector:@selector(handleSharedObjectChanges:) fromClass:self];
}

-(void)removeChangesListener:(void(^)(SharedObjectChanges *))responseBlock {
    [super stopSubscriptionWithSharedObject:sharedObjectName event:RSO_CHANGES onResult:responseBlock];
}

-(SharedObjectChanges *)handleSharedObjectChanges:(NSDictionary *)jsonResult {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *sharedObjectChangesData = [jsonHelper dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    SharedObjectChanges *sharedObjectChanges = [SharedObjectChanges new];
    sharedObjectChanges.key = [sharedObjectChangesData valueForKey:@"key"];
    sharedObjectChanges.data = [jsonHelper parseBackObjectForJSON:[sharedObjectChangesData valueForKey:@"data"]];
    sharedObjectChanges.connectionId = [sharedObjectChangesData valueForKey:@"connectionId"];
    sharedObjectChanges.userId = [sharedObjectChangesData valueForKey:@"userId"];
    return sharedObjectChanges;
}

-(void)addClearListener:(void(^)(UserInfo *))responseBlock error:(void(^)(Fault *))errorBlock {
    NSDictionary *options = @{@"name" : sharedObjectName};
    [super addSubscription:RSO_CLEARED options:options onResult:responseBlock onError:errorBlock handleResultSelector:@selector(handleUserInfo:) fromClass:self];
}

-(void)removeClearListener:(void(^)(UserInfo *))responseBlock {
    [super stopSubscriptionWithSharedObject:sharedObjectName event:RSO_CLEARED onResult:responseBlock];
}

-(UserInfo *)handleUserInfo:(NSDictionary *)jsonResult {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *userInfoData = [jsonHelper dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    UserInfo *userInfo = [UserInfo new];
    userInfo.connectionId = [userInfoData valueForKey:@"connectionId"];
    userInfo.userId = [userInfoData valueForKey:@"userId"];
    return userInfo;
}

-(void)addCommandListener:(void(^)(CommandObject *))responseBlock error:(void(^)(Fault *))errorBlock {
    NSDictionary *options = @{@"name" : sharedObjectName};
    [super addSubscription:RSO_COMMANDS options:options onResult:responseBlock onError:errorBlock handleResultSelector:@selector(handleCommand:) fromClass:self];
}

-(void)removeCommandListener:(void(^)(CommandObject *))responseBlock {
    [super stopSubscriptionWithSharedObject:sharedObjectName event:RSO_COMMANDS onResult:responseBlock];
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

-(void)addUserStatusListener:(void(^)(UserStatusObject *))responseBlock error:(void(^)(Fault *))errorBlock {
    NSDictionary *options = @{@"name" : sharedObjectName};
    [super addSubscription:RSO_USERS options:options onResult:responseBlock onError:errorBlock handleResultSelector:@selector(handleUserStatus:) fromClass:self];
}

-(void)removeUserStatusListener:(void(^)(UserStatusObject *))responseBlock {
    [super stopSubscriptionWithSharedObject:sharedObjectName event:RSO_USERS onResult:responseBlock];
}

-(UserStatusObject *)handleUserStatus:(NSDictionary *)jsonResult {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *userStatusData = [jsonHelper dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    UserStatusObject *userStatus = [UserStatusObject new];
    userStatus.status = [userStatusData valueForKey:@"status"];
    userStatus.data = [userStatusData valueForKey:@"data"];
    return userStatus;
}

-(void)addInvokeListener:(void(^)(InvokeObject *))responseBlock error:(void(^)(Fault *))errorBlock {
    NSDictionary *options = @{@"name" : sharedObjectName};
    [super addSubscription:RSO_INVOKE options:options onResult:responseBlock onError:errorBlock handleResultSelector:@selector(handleInvoke:) fromClass:self];
}

-(void)removeInvokeListener:(void(^)(InvokeObject *))responseBlock {
    [super stopSubscriptionWithSharedObject:sharedObjectName event:RSO_INVOKE onResult:responseBlock];
}

-(InvokeObject *)handleInvoke:(NSDictionary *)jsonResult {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *invokeData = [jsonHelper dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    InvokeObject *invokeObject = [InvokeObject new];
    invokeObject.method = [invokeData valueForKey:@"method"];
    invokeObject.args = [invokeData valueForKey:@"args"];
    invokeObject.connectionId = [invokeData valueForKey:@"connectionId"];
    invokeObject.userId = [invokeData valueForKey:@"userId"];
    [self invokeMethod:invokeObject.method ags:invokeObject.args invocationTarget:self.invocationTarget];
    return invokeObject;
}

-(void)invokeMethod:(NSString *)methodName ags:(NSArray *)args invocationTarget:(id)invocationTarget {
    NSArray *classMethods = [NSArray arrayWithArray:[self getMethodsListOfInvocationTarget:object_getClass([invocationTarget class])]];
    NSArray *instanceMethods = [NSArray arrayWithArray:[self getMethodsListOfInvocationTarget:[invocationTarget class]]];
    if ([classMethods count] > 0) {
        [self prepareToCallInvoke:methodName from:classMethods args:args invocationTarget:[invocationTarget class]];
    }
    if ([instanceMethods count] > 0) {
        [self prepareToCallInvoke:methodName from:instanceMethods args:args invocationTarget:invocationTarget];
    }
}

-(NSArray *)getMethodsListOfInvocationTarget:(id)invocationTarget {
    NSMutableArray *methodsArray = [NSMutableArray new];
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(invocationTarget, &methodCount);
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        NSString *methodName = [NSString stringWithUTF8String:sel_getName(method_getName(method))];
        [methodsArray addObject:methodName];
    }
    free(methods);
    return methodsArray;
}

-(void)prepareToCallInvoke:(NSString *)methodName from:(NSArray *)methodsArray args:(NSArray *)args invocationTarget:(id)invocationTarget {
    for (NSString *method in methodsArray) {
        NSArray *methodComponents = [method componentsSeparatedByString:@":"];
        NSString *name = [methodComponents firstObject];
        if ([name isEqualToString:methodName] && ([methodComponents count] - 1) == [args count]) {
            if ([invocationTarget respondsToSelector:NSSelectorFromString(method)]) {
                [self invokeMethodWithSelector:NSSelectorFromString(method) args:args invocationTarget:invocationTarget];
            }
        }
    }
}

-(void)invokeMethodWithSelector:(SEL)methodSelector args:(NSArray *)args invocationTarget:(id)invocationTarget {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[invocationTarget methodSignatureForSelector:methodSelector]];
    [invocation setTarget:invocationTarget];
    [invocation setSelector:methodSelector];
    for (int i = 0; i < [args count]; i++) {
        id arg = [args objectAtIndex:i];
        [invocation setArgument:&arg atIndex:i+2]; // index 0 reserved for self, index 1 reserved for _cmd
    }
    [invocation invoke];
}

-(void)get:(NSString *)key onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError {
    NSDictionary *options = @{@"name"   : sharedObjectName};
    if (key) {
        options = @{@"name"   : sharedObjectName,
                    @"key"    : key};
    }
    [rtMethod sendCommand:RSO_GET options:options onSuccess:onSuccess onError:onError];
}

-(void)set:(NSString *)key data:(id)data onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError {
    NSDictionary *options = @{@"name"   : sharedObjectName,
                              @"key"    : key};
    if (data) {
        options = @{@"name" : sharedObjectName,
                    @"key"  : key,
                    @"data" : [jsonHelper parseObjectForJSON:data]};
    }
    [rtMethod sendCommand:RSO_SET options:options onSuccess:onSuccess onError:onError];
}

-(void)clear:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError {
    NSDictionary *options = @{@"name"   : sharedObjectName};
    [rtMethod sendCommand:RSO_CLEAR options:options onSuccess:onSuccess onError:onError];
}

-(void)sendCommand:(NSString *)commandName data:(id)data onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError {
    NSDictionary *options = @{@"name"   : sharedObjectName,
                              @"type"   : commandName};
    if (data) {
        options = @{@"name" : sharedObjectName,
                    @"type" : commandName,
                    @"data" : [jsonHelper parseObjectForJSON:data]};
    }
    [rtMethod sendCommand:RSO_COMMAND options:options onSuccess:onSuccess onError:onError];
}

-(void)invoke:(NSString *)method targets:(NSArray *)targets args:(NSArray *)args onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError {
    NSDictionary *options = @{@"name"       : sharedObjectName,
                              @"method"     : method};
    if (targets) {
        options = @{@"name"     : sharedObjectName,
                    @"method"   : method,
                    @"targets"  : targets};
    }
    if (args) {
        options = @{@"name"     : sharedObjectName,
                    @"method"   : method,
                    @"args"     : args};
    }
    if (targets && args) {
        options = @{@"name"     : sharedObjectName,
                    @"method"   : method,
                    @"targets"  : targets,
                    @"args"     :args};
    }
    [rtMethod sendCommand:RSO_INVOKE options:options onSuccess:onSuccess onError:onError];
}

@end
