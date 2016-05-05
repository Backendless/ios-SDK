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
@property (strong, nonatomic) NSMutableArray<NSString *> *pushSinglecast;
@property (strong, nonatomic) NSDate *publishAt;
@property (strong, nonatomic) NSDate *repeatExpiresAt;

+(id)deliveryOptionsForNotification:(PushPolicyEnum)pushPolice;

-(PushPolicyEnum)valPushPolicy;
-(void)pushPolicy:(PushPolicyEnum)pushPolicy;
-(UInt32)valPushBroadcast;
-(void)pushBroadcast:(UInt32)pushBroadcast;
-(long)valRepeatEvery;
-(BOOL)repeatEvery:(long)repeatEvery;
-(void)addSinglecast:(NSString *)device;
-(void)delSinglecast:(NSString *)device;
-(void)assignSinglecast:(NSArray<NSString *> *)devices;
@end
