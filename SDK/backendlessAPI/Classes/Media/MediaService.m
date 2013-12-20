//
//  MediaService.m
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

#import "MediaService.h"
#import "Backendless.h"

@implementation MediaService
#ifndef __arm64__
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
-(MediaPublisher *)publishStream:(NSString *)name tube:(NSString *)tube options:(MediaPublishOptions *)options responder:(id <IMediaStreamerDelegate>)delegate {
    
    MediaPublisher *stream = [MediaPublisher new];
    stream.delegate = delegate;
    stream.options = options;
    stream.streamPath = [backendless mediaServerUrl];
    stream.tubeName = tube;
    stream.streamName = name;
    
    [stream connect];
    
    return stream;
}

-(MediaPlayer *)playbackStream:(NSString *)name tube:(NSString *)tube options:(MediaPlaybackOptions *)options responder:(id <IMediaStreamerDelegate>)delegate {
    
    // setup the simultaneous record and playback
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    MediaPlayer *stream = [MediaPlayer new];
    stream.delegate = delegate;
    stream.options = options;
    stream.streamPath = [backendless mediaServerUrl];
    stream.tubeName = tube;
    stream.streamName = name;
    
    [stream connect];
    
    return stream;
}
#else
#endif
#endif
@end
