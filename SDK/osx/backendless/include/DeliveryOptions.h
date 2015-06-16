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
    PUSHONLY,
    PUSHALSO
} PushPolicyEnum;

typedef enum {
    NONE = 0,
    IOS = 1,
    ANDROID = 2,
    WP = 4,
    OSX = 7,
    ALL = 15
} PushBroadcastEnum;


@interface DeliveryOptions : NSObject

@property (strong, nonatomic) NSNumber *pushPolicy;
@property (strong, nonatomic) NSNumber *pushBroadcast;
@property (strong, nonatomic) NSMutableArray *pushSinglecast;
@property (strong, nonatomic) NSDate *publishAt;
@property (strong, nonatomic) NSNumber *repeatEvery;
@property (strong, nonatomic) NSDate *repeatExpiresAt;

-(PushPolicyEnum)valPushPolicy;
-(BOOL)pushPolicy:(PushPolicyEnum)pushPolicy;
-(PushBroadcastEnum)valPushBroadcast;
-(BOOL)pushBroadcast:(PushBroadcastEnum)pushBroadcast;
-(long)valRepeatEvery;
-(BOOL)repeatEvery:(long)repeatEvery;
-(BOOL)addSinglecast:(NSString *)device;
+(id)deliveryOptionsForNotification:(PushPolicyEnum)pushPolice;

@end
