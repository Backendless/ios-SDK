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
    void(^onResult)(id);
    void(^onError)(Fault *);
    void(^onStop)(RTMethodRequest *);
}
@end

@implementation RTMethod

+(instancetype)sharedInstance {
    static RTMethod *sharedRTMethod;
    @synchronized(self) {
        if (!sharedRTMethod)
            sharedRTMethod = [[RTMethod alloc] init];
    }
    return sharedRTMethod;
}

-(instancetype)init {
    if (self = [super init]) {
        methods = [NSMutableDictionary<NSString *, NSMutableArray<RTMethodRequest *> *> new];
    }
    return self;
}

-(void)sendCommand:(NSString *)type options:(NSDictionary *)options onSuccess:(void(^)(id))onSuccess onError:(void(^)(Fault *))onError {
    NSString *methodId = [[NSUUID UUID] UUIDString];
    NSDictionary *data = @{@"id"        : methodId,
                           @"name"      : type,
                           @"options"   : options};
    
    __weak NSMutableDictionary<NSString *, NSMutableArray<RTMethodRequest *> *> *weakMethods = methods;
    
    onStop = ^(RTMethodRequest *method) {
        NSMutableArray *methodStack = [NSMutableArray arrayWithArray:[weakMethods valueForKey:type]] ? [NSMutableArray arrayWithArray:[weakMethods valueForKey:type]] : [NSMutableArray new];
        [methodStack removeObject:method];
    };
    
    RTMethodRequest *method = [RTMethodRequest new];
    method.methodId = methodId;
    method.type = type;
    method.options = options;
    method.onResult = onSuccess;
    method.onError = onError;
    method.onStop = onStop;
    
    NSMutableArray *methodStack = [NSMutableArray arrayWithArray:[methods valueForKey:type]] ? [NSMutableArray arrayWithArray:[methods valueForKey:type]] : [NSMutableArray new];
    [methodStack addObject:method];
    [methods setObject:methodStack forKey:type];
    
    [rtClient sendCommand:data method:method];
}

@end
