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
#import "Backendless.h"

@interface RTListener() {
    NSMutableDictionary<NSString *, NSMutableArray<RTSubscription *> *> *subscriptions;
    NSMutableDictionary<NSString *, NSMutableArray *> *simpleListeners;
    void(^onError)(Fault *);
    void(^onStop)(RTSubscription *);
    void(^onReady)(void);
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

-(void)addSubscription:(NSString *)type options:(NSDictionary *)options onResult:(void(^)(id))onResult handleResultSelector:(SEL)handleResultSelector fromClass:(id)subscriptionClassInstance {
    
    NSString *subscriptionId = [[NSUUID UUID] UUIDString];
    NSDictionary *data = @{@"id"        : subscriptionId,
                           @"name"      : type,
                           @"options"   : options};
    
    __weak NSMutableDictionary<NSString *, NSMutableArray<RTSubscription *> *> *weakSubscriptions = subscriptions;
    __weak NSMutableDictionary<NSString *, NSMutableArray *> *weakSimpleListeners = simpleListeners;
    
    onError = ^(Fault *error) {
        NSArray *errorCallbacks = [NSArray arrayWithArray:[weakSimpleListeners valueForKey:ERROR]];
        for (int i = 0; i < [errorCallbacks count]; i++) {
            void(^errorBlock)(Fault *) = [errorCallbacks objectAtIndex:i];
            errorBlock(error);
        }
    };
    
    onStop = ^(RTSubscription *subscription) {
        NSMutableArray *subscriptionStack = [NSMutableArray arrayWithArray:[weakSubscriptions valueForKey:subscription.type]] ? [NSMutableArray arrayWithArray:[weakSubscriptions valueForKey:type]] : [NSMutableArray new];
        [subscriptionStack removeObject:subscription];
    };
    
    onReady = ^{
        NSArray *readyCallbacks = [NSArray arrayWithArray:[weakSimpleListeners valueForKey:type]];
        for (int i = 0; i < [readyCallbacks count]; i++) {
            void(^readyBlock)(id) = [readyCallbacks objectAtIndex:i];
            readyBlock(nil);
        }
    };
    
    RTSubscription *subscription = [RTSubscription new];
    subscription.subscriptionId = subscriptionId;
    subscription.type = type;
    subscription.options = [NSDictionary dictionaryWithDictionary:options];
    subscription.onResult = onResult;
    subscription.onError = onError;
    subscription.onStop = onStop;
    subscription.onReady = onReady;
    subscription.ready = NO;
    subscription.handleResult = handleResultSelector;
    subscription.classInstance = subscriptionClassInstance;
        
    [rtClient subscribe:data subscription:subscription];
    
    NSString *typeName = [data valueForKey:@"name"];
    if ([typeName isEqualToString:OBJECTS_CHANGES]) {
        typeName = [[data valueForKey:@"options"] valueForKey:@"event"];
    }
    NSMutableArray *subscriptionStack = [NSMutableArray arrayWithArray:[subscriptions valueForKey:typeName]];
    if (!subscriptionStack) {
        subscriptionStack = [NSMutableArray new];
    }
    [subscriptionStack addObject:subscription];
    [subscriptions setObject:subscriptionStack forKey:typeName];
}

-(void)stopSubscription:(NSString *)event whereClause:(NSString *)whereClause onResult:(void(^)(id))onResult {
    NSMutableArray *subscriptionStack = [NSMutableArray arrayWithArray:[subscriptions valueForKey:event]];
    if (event && subscriptionStack) {
        if (whereClause && onResult) {
            for (RTSubscription *subscription in subscriptionStack) {
                if ([subscription.options valueForKey:@"whereClause"] && [[subscription.options valueForKey:@"whereClause"] isEqualToString:whereClause] && subscription.onResult == onResult) {
                    [subscription stop];
                }
            }
        }
        else if (whereClause && !onResult) {
            for (RTSubscription *subscription in subscriptionStack) {
                if ([subscription.options valueForKey:@"whereClause"] && [[subscription.options valueForKey:@"whereClause"] isEqualToString:whereClause]) {
                    [subscription stop];
                }
            }
        }
        else if (!whereClause && onResult) {
            for (RTSubscription *subscription in subscriptionStack) {
                if (![subscription.options valueForKey:@"whereClause"] && subscription.onResult == onResult) {
                    [subscription stop];
                }
            }
        }
        else if (!whereClause && !onResult) {
            for (RTSubscription *subscription in subscriptionStack) {
                [subscription stop];
            }
        }
    }
    else if (!event) {
        for (NSString *eventName in [subscriptions allKeys]) {
            NSMutableArray *subscriptionStack = [NSMutableArray arrayWithArray:[subscriptions valueForKey:eventName]];
            if (subscriptionStack) {
                for (RTSubscription *subscription in subscriptionStack) {
                    [subscription stop];
                }
            }
        }
    }
}

-(void)stopSubscriptionWithChannel:(NSString *)channel event:(NSString *)event whereClause:(NSString *)whereClause onResult:(void(^)(id))onResult {
    NSMutableArray *subscriptionStack = [NSMutableArray arrayWithArray:[subscriptions valueForKey:event]];
    if (channel && event && subscriptionStack) {
        if (whereClause && onResult) {
            for (RTSubscription *subscription in subscriptionStack) {
                if ([subscription.options valueForKey:@"channel"] && [[subscription.options valueForKey:@"channel"] isEqualToString:channel] && [subscription.options valueForKey:@"selector"] && [[subscription.options valueForKey:@"selector"] isEqualToString:whereClause] && subscription.onResult == onResult) {
                    [subscription stop];
                }
            }
        }
        else if (whereClause && !onResult) {
            for (RTSubscription *subscription in subscriptionStack) {
                if ([subscription.options valueForKey:@"channel"] && [[subscription.options valueForKey:@"channel"] isEqualToString:channel] && [subscription.options valueForKey:@"selector"] && [[subscription.options valueForKey:@"selector"] isEqualToString:whereClause]) {
                    [subscription stop];
                }
            }
        }
        else if (!whereClause && onResult) {
            for (RTSubscription *subscription in subscriptionStack) {
                if ([subscription.options valueForKey:@"channel"] && [[subscription.options valueForKey:@"channel"] isEqualToString:channel] && subscription.onResult == onResult) {
                    [subscription stop];
                }
            }
        }
        else if (!whereClause && !onResult) {
            for (RTSubscription *subscription in subscriptionStack) {
                [subscription stop];
            }
        }
    }
    else if (!event) {
        for (NSString *eventName in [subscriptions allKeys]) {
            NSMutableArray *subscriptionStack = [NSMutableArray arrayWithArray:[subscriptions valueForKey:eventName]];
            if (subscriptionStack) {
                for (RTSubscription *subscription in subscriptionStack) {
                    [subscription stop];
                }
            }
        }
    }
}

-(void)stopSubscriptionWithRSO:(NSString *)rso event:(NSString *)event onResult:(void(^)(id))onResult {
    NSMutableArray *subscriptionStack = [NSMutableArray arrayWithArray:[subscriptions valueForKey:event]];
    if (rso && event && subscriptionStack) {        
        if (onResult) {
            for (RTSubscription *subscription in subscriptionStack) {
                if ([subscription.options valueForKey:@"name"] && [[subscription.options valueForKey:@"name"] isEqualToString:rso] && subscription.onResult == onResult) {
                    [subscription stop];
                }
            }
        }
        else if (!onResult) {
            for (RTSubscription *subscription in subscriptionStack) {
                [subscription stop];
            }
        }
    }
    else if (!event) {
        for (NSString *eventName in [subscriptions allKeys]) {
            NSMutableArray *subscriptionStack = [NSMutableArray arrayWithArray:[subscriptions valueForKey:eventName]];
            if (subscriptionStack) {
                for (RTSubscription *subscription in subscriptionStack) {
                    [subscription stop];
                }
            }
        }
    }
}

-(void)addSimpleListener:(NSString *)type callBack:(void(^)(id))callback {
    NSMutableArray *listenersStack = [NSMutableArray arrayWithArray:[simpleListeners valueForKey:type]] ? [NSMutableArray arrayWithArray:[simpleListeners valueForKey:type]] : [NSMutableArray new];
    [listenersStack addObject:callback];
    [simpleListeners setObject:listenersStack forKey:type];
}

-(void)removeSimpleListener:(NSString *)type callBack:(void(^)(id))callback {
    if ([simpleListeners valueForKey:type]) {
        NSMutableArray *listenersStack = [simpleListeners valueForKey:type];
        if (listenersStack) {
            if (callback) {
                [listenersStack removeObject:callback];
            }
            else {
                [self removeSimpleListener:type];
            }
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
