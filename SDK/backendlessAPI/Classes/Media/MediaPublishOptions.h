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
    LOW_RESOLUTION,     // 144x192px (landscape) & 192x144px (portrait)
    CIF_RESOLUTION,     // 288x352px (landscape) & 352x288px (portrait)
    MEDIUM_RESOLUTION,  // 360x480px (landscape) & 480x368px (portrait)
    VGA_RESOLUTION,     // 480x640px (landscape) & 640x480px (portrait)
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
-(NSString *)getServerURL;
@end
#else
@interface MediaPublishOptions : NSObject
@end
#endif

