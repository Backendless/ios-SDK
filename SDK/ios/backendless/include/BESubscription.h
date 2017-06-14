//
//  Subscription.h
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
#import "SubscriptionOptions.h"

@class Fault;
@protocol IResponder;

@interface BESubscription : NSObject

@property (strong, nonatomic) NSString *subscriptionId;
@property (strong, nonatomic) NSString *channelName;
@property (strong, nonatomic) id <IResponder> responder;
@property DeliveryMethodEnum deliveryMethod;

-(id)initWithChannelName:(NSString *)channelName responder:(id <IResponder>)subscriptionResponder;
-(id)initWithChannelName:(NSString *)channelName response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
+(id)subscription:(NSString *)channelName responder:(id <IResponder>)subscriptionResponder;
+(id)subscription:(NSString *)channelName response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(uint)getPollingInterval;
-(void)cancel;
-(void)startPolling;

@end
