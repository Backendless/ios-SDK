//
//  MediaPublishOptions.m
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

#import "MediaPublishOptions.h"
#import "DEBUG.h"
#import "Backendless.h"

@implementation MediaPublishOptions
#if TARGET_OS_IPHONE
-(id)init {
	
    if ( (self=[super init]) ) {
#if IS_MEDIA_ENCODER
        _videoCodecId = MP_VIDEO_CODEC_H264;
        _audioCodecId = MP_AUDIO_CODEC_AAC;
#endif
        _previewPanel = nil;
        _publishType = PUBLISH_LIVE;
        _orientation = AVCaptureVideoOrientationLandscapeRight;
        _content = AUDIO_AND_VIDEO;
        _resolution = RESOLUTION_LOW;
        _videoBitrate = 0;
        _audioBitrate = 0;
        _fps = 15;
        _width = 192;
        _height = 144;
        
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC MediaPublishOptions"];
    
	[super dealloc];
}

+(id)liveStream:(UIView *)view {
    
    MediaPublishOptions *instance = [MediaPublishOptions new];
    instance.previewPanel = view;
    
    return [instance autorelease];
}

+(id)recordStream:(UIView *)view {
    
    MediaPublishOptions *instance = [MediaPublishOptions new];
    instance.previewPanel = view;
    instance.publishType = PUBLISH_RECORD;
    
    return [instance autorelease];    
}

+(id)appendStream:(UIView *)view {
    
    MediaPublishOptions *instance = [MediaPublishOptions new];
    instance.previewPanel = view;
    instance.publishType = PUBLISH_APPEND;
    
    return [instance autorelease];    
}

+(id)options:(MPMediaPublishType)type orientation:(AVCaptureVideoOrientation)orientation resolution:(MPVideoResolution)resolution view:(UIView *)view {
    
    MediaPublishOptions *instance = [MediaPublishOptions new];
    instance.previewPanel = view;
    instance.publishType = type;
    instance.orientation = orientation;
    instance.resolution = resolution;
    
    return [instance autorelease];
}

-(void)setCustomVideo:(uint)fps width:(uint)width height:(uint)height {
    
    _audioCodecId = MP_AUDIO_CODEC_NONE;
    _content = CUSTOM_VIDEO;
    _resolution = RESOLUTION_CUSTOM;
    _fps = fps;
    _width = width;
    _height = height;
}

-(void)setAudioAndCustomVideo:(uint)fps width:(uint)width height:(uint)height {
    
    _content = AUDIO_AND_CUSTOM_VIDEO;
    _resolution = RESOLUTION_CUSTOM;
    _fps = fps;
    _width = width;
    _height = height;
}

-(NSString *)getServerURL {
#if TEST_MEDIA_INSTANCE
    return [NSString stringWithFormat:@"%@/%@/%@", [backendless mediaServerUrl], backendless.appID, backendless.versionNum];
#else
    return [NSString stringWithFormat:@"%@Live", [backendless mediaServerUrl]];
#endif
}
#endif
@end

