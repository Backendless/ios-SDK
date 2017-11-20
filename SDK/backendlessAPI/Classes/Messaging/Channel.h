//
//  Channel.h
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
#import "Message.h"

@interface Channel : NSObject

@property (strong, nonatomic, readonly) NSString *channelName;
@property (nonatomic, readonly) BOOL isConnected;

-(instancetype)initWithChannelName:(NSString *)channelName;
-(void)connect;
-(void)disconnect;

-(void)addErrorListener:(void(^)(Fault *))errorBlock;
-(void)removeErrorListener:(void(^)(Fault *))errorBlock;
-(void)removeErrorListener;

-(void)addConnectListener:(void(^)(void))onConnect;
-(void)removeConnectListener:(void(^)(void))onConnect;
-(void)removeConnectListener;

-(void)addMessageListener:(void(^)(Message *))onMessage;
-(void)addMessageListener:(NSString *)selector onMessage:(void(^)(Message *))onMessage;
-(void)removeMessageListener:(NSString *)selector onMessage:(void(^)(Message *))onMessage;
-(void)removeMessageListenerWithCallback:(void(^)(Message *))onMessage;
-(void)removeMessageListenerWithSelector:(NSString *)selector;
-(void)removeMessageListener;

-(void)removeAllListeners;

@end
