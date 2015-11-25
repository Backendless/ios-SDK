//
//  DeliveryOptions.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
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

#define _OLD_POLICY_IMPL 0

typedef enum {
    PUSH_ONLY,
    PUSH_ALSO,
    PUSH_PUBSUB
} PushPolicyEnum;

typedef enum {
    FOR_NONE = 0,
    FOR_IOS = 1,
    FOR_ANDROID = 2,
    FOR_WP = 4,
    FOR_OSX = 8,
    FOR_ALL = 15
} PushBroadcastEnum;


@interface DeliveryOptions : NSObject
#if _OLD_POLICY_IMPL
@property (strong, nonatomic) NSNumber *pushPolicy;
#else
@property (strong, nonatomic) NSString *pushPolicy;
#endif
@property (strong, nonatomic) NSNumber *pushBroadcast;
@property (strong, nonatomic) NSMutableArray *pushSinglecast;
@property (strong, nonatomic) NSDate *publishAt;
@property (strong, nonatomic) NSNumber *repeatEvery;
@property (strong, nonatomic) NSDate *repeatExpiresAt;

+(id)deliveryOptionsForNotification:(PushPolicyEnum)pushPolice;

-(PushPolicyEnum)valPushPolicy;
-(BOOL)pushPolicy:(PushPolicyEnum)pushPolicy;
-(PushBroadcastEnum)valPushBroadcast;
-(BOOL)pushBroadcast:(PushBroadcastEnum)pushBroadcast;
-(long)valRepeatEvery;
-(BOOL)repeatEvery:(long)repeatEvery;
-(BOOL)addSinglecast:(NSString *)device;

@end
