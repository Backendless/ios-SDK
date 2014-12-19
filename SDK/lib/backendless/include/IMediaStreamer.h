//
//  IMediaStreamer.h
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
#if TARGET_OS_IPHONE
#import "MPMediaData.h"

@protocol IMediaStreamer <NSObject>
-(MPMediaStreamState)currentState;
-(void)connect;
-(void)start;
-(void)pause;
-(void)resume;
-(void)stop;
-(void)disconnect;
@end

@protocol IMediaStreamerDelegate <NSObject>
-(void)streamStateChanged:(id)sender state:(int)state description:(NSString *)description;
-(void)streamConnectFailed:(id)sender code:(int)code description:(NSString *)description;
@end
#endif
