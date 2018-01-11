//
//  RTRSO.m
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

#import "RTRSO.h"
#import "RTMethod.h"
#import "JSONHelper.h"
#import <objc/runtime.h>

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@interface RTRSO() {
    NSString *rso;
    NSMapTable *onConnectCallbacks;
}
@end

@implementation RTRSO

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

-(void)addChangesListener:(void(^)(SharedObjectChanges *))onChange {
    NSDictionary *options = @{@"name" : rso};
    [super addSubscription:RSO_CHANGES options:options onResult:onChange handleResultSelector:@selector(handleRSOChanges:) fromClass:self];
}

-(void)removeChangesListener:(void(^)(SharedObjectChanges *))onChange {
    [super stopSubscriptionWithRSO:rso event:RSO_CHANGES onResult:onChange];
}

-(SharedObjectChanges *)handleRSOChanges:(NSDictionary *)jsonResult {    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *rsoChangesData = [jsonHelper dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    SharedObjectChanges *rsoChangesObject = [SharedObjectChanges new];
    rsoChangesObject.key = [rsoChangesData valueForKey:@"key"];
    rsoChangesObject.data = [jsonHelper parseBackObjectForJSON:[rsoChangesData valueForKey:@"data"]];
    rsoChangesObject.connectionId = [rsoChangesData valueForKey:@"connectionId"];
    rsoChangesObject.userId = [rsoChangesData valueForKey:@"userId"];
    return rsoChangesObject;
}

-(void)addClearListener:(void(^)(RSOClearedObject *))onClear {
    NSDictionary *options = @{@"name" : rso};
    [super addSubscription:RSO_CLEARED options:options onResult:onClear handleResultSelector:@selector(handleRSOCleared:) fromClass:self];
}

-(void)removeClearListener:(void(^)(RSOClearedObject *))onClear {
    [super stopSubscriptionWithRSO:rso event:RSO_CLEARED onResult:onClear];
}

-(RSOClearedObject *)handleRSOCleared:(NSDictionary *)jsonResult {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *rsoClearedData = [jsonHelper dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    RSOClearedObject *rsoClearedObject = [RSOClearedObject new];
    rsoClearedObject.connectionId = [rsoClearedData valueForKey:@"connectionId"];
    rsoClearedObject.userId = [rsoClearedData valueForKey:@"userId"];
    return rsoClearedObject;
}

-(void)addCommandListener:(void(^)(CommandObject *))onCommand {
    NSDictionary *options = @{@"name" : rso};
    [super addSubscription:RSO_COMMANDS options:options onResult:onCommand handleResultSelector:@selector(handleCommand:) fromClass:self];
}

-(void)removeCommandListener:(void(^)(CommandObject *))onCommand {
    [super stopSubscriptionWithRSO:rso event:RSO_COMMANDS onResult:onCommand];
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
    NSDictionary *options = @{@"name" : rso};
    [super addSubscription:RSO_USERS options:options onResult:onUserStatus handleResultSelector:@selector(handleUserStatus:) fromClass:self];
}

-(void)removeUserStatusListener:(void(^)(UserStatusObject *))onUserStatus {
    [super stopSubscriptionWithRSO:rso event:RSO_USERS onResult:onUserStatus];
}

-(UserStatusObject *)handleUserStatus:(NSDictionary *)jsonResult {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *userStatusData = [jsonHelper dictionaryFromJson:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    UserStatusObject *userStatus = [UserStatusObject new];
    userStatus.status = [userStatusData valueForKey:@"status"];
    userStatus.data = [userStatusData valueForKey:@"data"];
    return userStatus;
}

-(void)addInvokeListener:(void(^)(InvokeObject *))onInvoke {
    NSDictionary *options = @{@"name" : rso};
    [super addSubscription:RSO_INVOKE options:options onResult:onInvoke handleResultSelector:@selector(handleInvoke:) fromClass:self];
}

-(void)removeInvokeListener:(void(^)(InvokeObject *))onInvoke {
    [super stopSubscriptionWithRSO:rso event:RSO_INVOKE onResult:onInvoke];
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
    NSDictionary *options = @{@"name"   : rso};
    if (key) {
        options = @{@"name"   : rso,
                    @"key"    : key};
    }
    [rtMethod sendCommand:RSO_GET options:options onSuccess:onSuccess onError:onError];
}

-(void)set:(NSString *)key data:(id)data onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError {
    NSDictionary *options = @{@"name"   : rso,
                              @"key"    : key};
    if (data) {
        options = @{@"name" : rso,
                    @"key"  : key,
                    @"data" : [jsonHelper parseObjectForJSON:data]};
    }
    [rtMethod sendCommand:RSO_SET options:options onSuccess:onSuccess onError:onError];
}

-(void)clear:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError {
    NSDictionary *options = @{@"name"   : rso};
    [rtMethod sendCommand:RSO_CLEAR options:options onSuccess:onSuccess onError:onError];
}

-(void)sendCommand:(NSString *)commandName data:(id)data onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError {
    NSDictionary *options = @{@"name"   : rso,
                              @"type"   : commandName};
    if (data) {
        options = @{@"name" : rso,
                    @"type" : commandName,
                    @"data" : [jsonHelper parseObjectForJSON:data]};
    }
    [rtMethod sendCommand:RSO_COMMAND options:options onSuccess:onSuccess onError:onError];
}

-(void)invoke:(NSString *)method targets:(NSArray *)targets args:(NSArray *)args onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError {
    NSDictionary *options = @{@"name"       : rso,
                              @"method"     : method};
    if (targets) {
        options = @{@"name"     : rso,
                    @"method"   : method,
                    @"targets"  : targets};
    }
    if (args) {
        options = @{@"name"     : rso,
                    @"method"   : method,
                    @"args"     : args};
    }
    if (targets && args) {
        options = @{@"name"     : rso,
                    @"method"   : method,
                    @"targets"  : targets,
                    @"args"     :args};
    }
    [rtMethod sendCommand:RSO_INVOKE options:options onSuccess:onSuccess onError:onError];
}

@end
