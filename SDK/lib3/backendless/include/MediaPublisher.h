//
//  MediaPublisher.h
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
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import "IMediaStreamer.h"

@class MediaPublishOptions;

@interface MediaPublisher : NSObject <IMediaStreamer>

@property (assign, nonatomic) id <IMediaStreamerDelegate> delegate;
@property (strong, nonatomic) MediaPublishOptions *options;
@property (strong, nonatomic) NSString *streamPath;
@property (strong, nonatomic) NSString *tubeName;
@property (strong, nonatomic) NSString *streamName;

-(void)switchCameras;
-(void)setVideoBitrate:(uint)bitRate;
-(void)setAudioBitrate:(uint)bitRate;
-(AVCaptureSession *)getCaptureSession;
-(BOOL)sendImage:(CGImageRef)image timestamp:(int64_t)timestamp;
-(BOOL)sendFrame:(CVPixelBufferRef)pixelBuffer timestamp:(int)timestamp;
-(BOOL)sendSampleBuffer:(CMSampleBufferRef)sampleBuffer;
-(void)sendMetadata:(NSDictionary *)data;
-(void)sendMetadata:(NSDictionary *)data event:(NSString *)event;
@end

#else

@interface MediaPublisher : NSObject
@end
#endif

