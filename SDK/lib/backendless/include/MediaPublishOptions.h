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

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
	VIDEO_RECORD,
	VIDEO_APPEND,
	VIDEO_LIVE,
} MediaPublishType;


typedef enum {
    LOW_RESOLUTION,     // 192x144px
    CIF_RESOLUTION,     // 352x288px
    MEDIUM_RESOLUTION,  // 480x360px
    VGA_RESOLUTION,     // 640x480px
    HIGH_RESOLUTION,    // 1280x720px
} VideoResolution;

typedef enum {
    AUDIO_AND_VIDEO,
    ONLY_VIDEO,
    ONLY_AUDIO,
    CUSTOM_VIDEO,
    AUDIO_AND_CUSTOM_VIDEO,
} MediaStreamContent;

@interface MediaPublishOptions : NSObject

@property MediaPublishType publishType;
@property AVCaptureVideoOrientation orientation;
@property VideoResolution resolution;
@property MediaStreamContent content;
@property uint videoBitrate;
@property uint audioBitrate;
@property (assign, nonatomic) UIView *previewPanel;

+(id)liveStream:(UIView *)view;
+(id)recordStream:(UIView *)view;
+(id)appendStream:(UIView *)view;
+(id)options:(MediaPublishType)type orientation:(AVCaptureVideoOrientation)orientation resolution:(VideoResolution)resolution view:(UIView *)view;
@end
#else
@interface MediaPublishOptions : NSObject
@end
#endif

