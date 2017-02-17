//
//  MediaPublishOptions.h
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

#if TARGET_OS_IPHONE 
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MPMediaData.h"

typedef enum {
    AUDIO_AND_VIDEO,
    ONLY_VIDEO,
    ONLY_AUDIO,
    CUSTOM_VIDEO,
    AUDIO_AND_CUSTOM_VIDEO,
} MediaStreamContent;

@interface MediaPublishOptions : NSObject
@property (assign, nonatomic) UIView *previewPanel;
#if IS_MEDIA_ENCODER
@property MPVideoCodec videoCodecId;
@property MPAudioCodec audioCodecId;
#endif
@property MPMediaPublishType publishType;
@property AVCaptureVideoOrientation orientation;
@property MPVideoResolution resolution;
@property MediaStreamContent content;
@property uint videoBitrate;
@property uint audioBitrate;
// custom mode options
@property uint fps;
@property uint width;
@property uint height;

+(id)liveStream:(UIView *)view;
+(id)recordStream:(UIView *)view;
+(id)appendStream:(UIView *)view;
+(id)options:(MPMediaPublishType)type orientation:(AVCaptureVideoOrientation)orientation resolution:(MPVideoResolution)resolution view:(UIView *)view;
-(NSString *)getServerURL;
-(void)setCustomVideo:(uint)fps width:(uint)width height:(uint)height;
-(void)setAudioAndCustomVideo:(uint)fps width:(uint)width height:(uint)height;
@end
#else
@interface MediaPublishOptions : NSObject
@end
#endif

