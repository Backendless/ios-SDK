//
//  RTListener.m
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

#import "RTListener.h"
#import "RTClient.h"
#import "RTSubscription.h"
#import "RTError.h"

@interface RTListener() {
    NSMutableDictionary<NSString *, NSMutableArray<RTSubscription *> *> *subscriptions;
    NSMutableDictionary<NSString *, NSMutableArray *> *simpleListeners;
    void(^onError)(RTError *);
    void(^onStop)(RTSubscription *);
}
@end

@implementation RTListener

-(instancetype)init {
    if (self = [super init]) {
        subscriptions = [NSMutableDictionary<NSString *, NSMutableArray<RTSubscription *> *> new];
        simpleListeners = [NSMutableDictionary<NSString *, NSMutableArray *> new];
    }
    return self;
}

-(void)addSubscription:(NSString *)type options:(NSDictionary *)options onResult:(void(^)(id))onResult {
    
    NSString *subscriptionId = [[NSUUID UUID] UUIDString];
    NSDictionary *data = @{@"id"        : subscriptionId,
                           @"name"      : type,
                           @"options"   : options};
    
    __weak NSMutableDictionary<NSString *, NSMutableArray<RTSubscription *> *> *weakSubscriptions = subscriptions;
    __weak NSMutableDictionary<NSString *, NSMutableArray *> *weakSimpleListeners = simpleListeners;
    
    onError = ^(RTError *error) {
        NSArray *errorCallbacks = [NSArray arrayWithArray:[weakSimpleListeners valueForKey:ERROR_TYPE]];
        for (int i = 0; i < [errorCallbacks count]; i++) {
            void(^errorBlock)(RTError *) = [errorCallbacks objectAtIndex:i];
            errorBlock(error);
        }
    };
    
    onStop = ^(RTSubscription *subscription) {
        NSMutableArray *subscriptionStack = [NSMutableArray arrayWithArray:[weakSubscriptions valueForKey:subscription.type]] ? [NSMutableArray arrayWithArray:[weakSubscriptions valueForKey:type]] : [NSMutableArray new];
        [subscriptionStack removeObject:subscription];
    };
    
    RTSubscription *subscription = [RTSubscription new];
    subscription.subscriptionId = subscriptionId;
    subscription.type = type;
    subscription.options = [NSDictionary dictionaryWithDictionary:options];
    subscription.onResult = onResult;
    subscription.onError = onError;
    subscription.onStop = onStop;
    
    [rtClient subscribe:data subscription:subscription];
    
    NSString *event = [[data valueForKey:@"options"] valueForKey:@"event"];
    NSMutableArray *subscriptionStack = [NSMutableArray arrayWithArray:[subscriptions valueForKey:event]];
    [subscriptionStack addObject:subscription];
    [subscriptions setObject:subscriptionStack forKey:event];
    
    for (RTSubscription *sub in subscriptionStack) {
        NSLog(@"%@", sub.subscriptionId);
        NSLog(@"%@", sub.type);
        NSLog(@"%@", sub.options);
    }
}

-(void)stopSubscription:(NSString *)event whereClause:(NSString *)whereClause onResult:(void(^)(id))onResult {
    //    NSMutableArray *subscriptionStack = [NSMutableArray arrayWithObject:[subscriptions valueForKey:event]];
    //    if (subscriptionStack) {
    //        if (whereClause && onResult) {
    //            for (RTSubscription *subscription in subscriptionStack) {
    //                if ([subscription.options valueForKey:@"whereClause"]) {
    //                    if ([[subscription.options valueForKey:@"whereClause"] isEqualToString:whereClause] && subscription.onResult == onResult) {
    //                        onStop(subscription);
    //                    }
    //                }
    //            }
    //        }
    //        else if (!whereClause && onResult) {
    //            for (RTSubscription *subscription in subscriptionStack) {
    //                if (![subscription.options valueForKey:@"whereClause"] && subscription.onResult == onResult) {
    //                    [subscription stop];
    //                }
    //            }
    //        }
    //        else if (whereClause && !onResult) {
    //            for (RTSubscription *subscription in subscriptionStack) {
    //                if ([[subscription.options valueForKey:@"whereClause"] isEqualToString:whereClause]) {
    //                    [subscription stop];
    //                }
    //            }
    //        }
    //        else {
    //            for (RTSubscription *subscription in subscriptionStack) {
    //                [subscription stop];
    //            }
    //        }
    //    }
}

-(void)addSimpleListener:(NSString *)type callBack:(void(^)(id))callback {
    NSMutableArray *listenersStack = [NSMutableArray arrayWithArray:[simpleListeners valueForKey:type]] ? [NSMutableArray arrayWithArray:[simpleListeners valueForKey:type]] : [NSMutableArray new];
    [listenersStack addObject:[callback copy]];
    [simpleListeners setObject:listenersStack forKey:type];
}

-(void)removeSimpleListener:(NSString *)type callBack:(void(^)(id))callback {
    if ([simpleListeners valueForKey:type]) {
        NSMutableArray *listenersStack = [simpleListeners valueForKey:type];
        if (listenersStack) {
            [listenersStack removeObject:callback];
        }
    }
}

-(void)removeSimpleListener:(NSString *)type {
    if ([simpleListeners valueForKey:type]) {
        NSMutableArray *listenersStack = [simpleListeners valueForKey:type];
        if (listenersStack) {
            [listenersStack removeAllObjects];
        }
    }
}

-(void)removeAllListeners {
    [subscriptions removeAllObjects];
    [simpleListeners removeAllObjects];
}

@end
