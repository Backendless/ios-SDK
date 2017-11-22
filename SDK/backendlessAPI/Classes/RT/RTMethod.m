//
//  RTMethod.m
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

#import "RTMethod.h"
#import "RTClient.h"
#import "RTMethodRequest.h"

@interface RTMethod() {
    NSMutableDictionary<NSString *, NSMutableArray<RTMethodRequest *> *> *methods;
    NSMutableDictionary<NSString *, NSMutableArray *> *simpleListeners;
    void(^onResult)(id);
    void(^onError)(Fault *);
    void(^onStop)(RTMethodRequest *);
}
@end

@implementation RTMethod

+(RTMethod *)sharedInstance {
    static RTMethod *sharedRTMethod;
    @synchronized(self) {
        if (!sharedRTMethod)
            sharedRTMethod = [[RTMethod alloc] init];
    }
    return sharedRTMethod;
}

-(RTMethod *)init {
    if (self = [super init]) {
        methods = [NSMutableDictionary<NSString *, NSMutableArray<RTMethodRequest *> *> new];
        simpleListeners = [NSMutableDictionary<NSString *, NSMutableArray *> new];
    }
    return self;
}

-(void)sendCommand:(NSString *)type options:(NSDictionary *)options onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError {
    
    NSDictionary *callbacks = @{type        : onSuccess,
                                ERROR_TYPE  : onError};
    
    for (NSString *callbackType in [callbacks allKeys]) {
        NSMutableArray *callbackStack = [NSMutableArray arrayWithArray:[simpleListeners valueForKey:callbackType]];
        if (!callbackStack) {
            callbackStack = [NSMutableArray new];
        }
        [callbackStack addObject:[callbacks valueForKey:callbackType]];
        [simpleListeners setObject:callbackStack forKey:callbackType];
    }
    
    NSString *methodId = [[NSUUID UUID] UUIDString];
    NSDictionary *data = @{@"id"        : methodId,
                           @"name"      : PUB_SUB_COMMAND_TYPE,
                           @"options"   : options};
    
    __weak NSMutableDictionary<NSString *, NSMutableArray<RTMethodRequest *> *> *weakMethods = methods;
    __weak NSMutableDictionary<NSString *, NSMutableArray *> *weakSimpleListeners = simpleListeners;
    
    onError = ^(Fault *error) {
        NSArray *errorCallbacks = [NSArray arrayWithArray:[weakSimpleListeners valueForKey:ERROR_TYPE]];
        for (int i = 0; i < [errorCallbacks count]; i++) {
            void(^errorBlock)(Fault *) = [errorCallbacks objectAtIndex:i];
            errorBlock(error);
        }
    };
    
    onResult = ^(id result) {
        NSArray *resultCallbacks = [NSArray arrayWithArray:[weakSimpleListeners valueForKey:type]];
        for (int i = 0; i < [resultCallbacks count]; i++) {
            void(^resultBlock)(id) = [resultCallbacks objectAtIndex:i];
            resultBlock(result);
        }
    };
    
    onStop = ^(RTMethodRequest *method) {
        NSMutableArray *methodStack = [NSMutableArray arrayWithArray:[weakMethods valueForKey:type]] ? [NSMutableArray arrayWithArray:[weakMethods valueForKey:type]] : [NSMutableArray new];
        [methodStack removeObject:method];
    };
    
    RTMethodRequest *method = [RTMethodRequest new];
    method.methodId = methodId;
    method.type = type;
    method.options = options;
    method.onResult = onResult;
    method.onError = onError;
    method.onStop = onStop;
    
    [rtClient sendCommand:data method:method];
    
    NSMutableArray *methodStack = [NSMutableArray arrayWithArray:[methods valueForKey:type]];
    if (!methodStack) {
        methodStack = [NSMutableArray new];
    }
    [methodStack addObject:method];
    [methods setObject:methodStack forKey:type];
}

@end
