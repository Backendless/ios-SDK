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
#ifndef __arm64__
@implementation MediaPublishOptions
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
-(id)init {
	
    if ( (self=[super init]) ) {
        _publishType = VIDEO_LIVE;
        _orientation = AVCaptureVideoOrientationLandscapeRight;
        _content = AUDIO_AND_VIDEO;
        _resolution = LOW_RESOLUTION;
        _previewView = nil;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC MediaPublishOptions"];
    
	[super dealloc];
}

+(id)liveStream:(UIView *)view {
    
    MediaPublishOptions *instance = [MediaPublishOptions new];
    instance.previewView = view;
    
    return [instance autorelease];
}

+(id)recordStream:(UIView *)view {
    
    MediaPublishOptions *instance = [MediaPublishOptions new];
    instance.previewView = view;
    instance.publishType = VIDEO_RECORD;
    
    return [instance autorelease];    
}

+(id)appendStream:(UIView *)view {
    
    MediaPublishOptions *instance = [MediaPublishOptions new];
    instance.previewView = view;
    instance.publishType = VIDEO_APPEND;
    
    return [instance autorelease];    
}

+(id)options:(MediaPublishType)type orientation:(AVCaptureVideoOrientation)orientation resolution:(VideoResolution)resolution view:(UIView *)view {
    
    MediaPublishOptions *instance = [MediaPublishOptions new];
    instance.previewView = view;
    instance.publishType = type;
    instance.orientation = orientation;
    instance.resolution = resolution;
    
    return [instance autorelease];
}
#else
#endif
@end
#endif