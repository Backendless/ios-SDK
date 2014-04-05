//
//  MediaPlayer.h
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
#import "IMediaStreamer.h"

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
@class MediaPlaybackOptions;

@interface MediaPlayer : NSObject <IMediaStreamer>

@property (assign, nonatomic) id <IMediaStreamerDelegate> delegate;
@property (strong, nonatomic) MediaPlaybackOptions *options;
@property (strong, nonatomic) NSString *streamPath;
@property (strong, nonatomic) NSString *tubeName;
@property (strong, nonatomic) NSString *streamName;
#else
@interface MediaPlayer : NSObject
#endif
@end

