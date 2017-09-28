//
//  RTClient.m
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

#import "RTClient.h"
@import SocketIO;

@interface RTClient() {
    NSURL *url;
    SocketIOClient *socket;
}
@end

@implementation RTClient

-(void)connectSocket {
    url = [[NSURL alloc] initWithString:@"http://localhost:5000"];
    socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"path": @"/appId/token"}];
    [socket connect];
}

-(void)disconnectSocket {
    [socket disconnect];
}

@end
