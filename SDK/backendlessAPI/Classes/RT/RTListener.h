//
//  RTListener.h
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

#import <Foundation/Foundation.h>
#import "Responder.h"

#define ERROR @"ERROR"
#define OBJECTS_CHANGES @"OBJECTS_CHANGES"
#define PUB_SUB_CONNECT @"PUB_SUB_CONNECT"
#define PUB_SUB_MESSAGES @"PUB_SUB_MESSAGES"
#define SET_USER_TOKEN @"SET_USER_TOKEN"
#define PUB_SUB_COMMAND @"PUB_SUB_COMMAND"
#define PUB_SUB_COMMANDS @"PUB_SUB_COMMANDS"
#define PUB_SUB_USERS @"PUB_SUB_USERS"
#define RSO_CONNECT @"RSO_CONNECT"
#define RSO_CHANGES @"RSO_CHANGES"
#define RSO_CLEAR @"RSO_CLEAR"
#define RSO_CLEARED @"RSO_CLEARED"
#define RSO_COMMAND @"RSO_COMMAND"
#define RSO_COMMANDS @"RSO_COMMANDS"
#define RSO_USERS @"RSO_USERS"
#define RSO_GET @"RSO_GET"
#define RSO_SET @"RSO_SET"
#define RSO_INVOKE @"RSO_INVOKE"

@interface RTListener : NSObject

-(void)addSubscription:(NSString *)type options:(NSDictionary *)options onResult:(void(^)(id))onResult onError:(void(^)(Fault *))onError handleResultSelector:(SEL)handleResultSelector fromClass:(id)subscriptionClassInstance;
-(void)stopSubscription:(NSString *)event whereClause:(NSString *)whereClause onResult:(void(^)(id))onResult;
-(void)stopSubscriptionWithChannel:(NSString *)channel event:(NSString *)event whereClause:(NSString *)whereClause onResult:(void(^)(id))onResult;
-(void)stopSubscriptionWithSharedObject:(NSString *)sharedObjectName event:(NSString *)event onResult:(void(^)(id))onResult;

@end
