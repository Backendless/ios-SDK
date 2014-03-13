//
//  MediaPublisher.m
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

#import "MediaPublisher.h"
#import "DEBUG.h"
#import "MediaPublishOptions.h"
#import "Backendless.h"
//#ifndef __arm64__
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import "BroadcastStreamClient.h"
static NSString *OPTIONS_IS_ABSENT = @"Options is absent. You shpuld set 'options' property";
static NSString *STREAM_IS_ABSENT = @"Stream is absent. You should invoke 'connect' method";

@interface MediaPublisher () <MPIMediaStreamEvent, IMediaStreamerDelegate> {
    
    BroadcastStreamClient *_stream;
}

@end

@implementation MediaPublisher

-(id)init {
	
    if ( (self=[super init]) ) {
        _stream = nil;
        _options = nil;
        _streamPath = nil;
        _tubeName = nil;
        _streamName = nil;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC MediaPublisher"];
    
    [self disconnect];
    
    [_options release];
    [_streamPath release];
    [_tubeName release];
    [_streamName release];
 	
	[super dealloc];
}

#pragma mark -
#pragma mark Private Methods

-(BOOL)wrongOptions {
    
    if (!_options) {
        [self streamConnectFailed:self code:-1 description:OPTIONS_IS_ABSENT];
        return YES;
    }
    
    if (!_stream) {
        [self streamConnectFailed:self code:-2 description:STREAM_IS_ABSENT];
        return YES;
    }
        
    return NO;
}

#pragma mark -
#pragma mark Public Methods

-(void)switchCameras {
    
    if ([self wrongOptions])
        return;
    
    [_stream switchCameras];    
}

-(AVCaptureSession *)getCaptureSession {
    return [_stream getCaptureSession];
}

-(BOOL)sendFrame:(CVPixelBufferRef)pixelBuffer timestamp:(int)timestamp {
    return [_stream sendFrame:pixelBuffer timestamp:timestamp];
}

-(BOOL)sendSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    return [_stream sendSampleBuffer:sampleBuffer];
}

-(void)sendMetadata:(NSDictionary *)data {
    [_stream sendMetadata:data];
}

-(void)sendMetadata:(NSDictionary *)data event:(NSString *)event {
    [_stream sendMetadata:data event:event];
}

-(NSString *)operationType {
    
    switch (_options.publishType) {
        case PUBLISH_LIVE:
            return @"publishLive";
        default:
            return @"publishRecorded";
    }
}

-(NSString *)streamType {
     
    switch (_options.publishType) {
        case PUBLISH_RECORD:
            return @"live-record";
        case PUBLISH_APPEND:
            return @"append";
        default:
            return @"live";
    }
}

-(NSArray *)parameters {
    
    id identity = backendless.userService.currentUser ? backendless.userService.currentUser.userToken : nil;
    if (!identity) identity = [NSNull null];
    
    id tube = _tubeName;
    if (!tube) tube = [NSNull null];
    
    NSArray *param = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, identity, tube, [self operationType], [self streamType], nil];
    
    [DebLog log:@"MediaPublisher -> parameters:%@", param];
    
    return param;
}

#pragma mark -
#pragma mark IMediaStream Methods

-(StateMediaStream)currentState {
    return [self wrongOptions] ? MEDIASTREAM_DISCONNECTED : (StateMediaStream)_stream.state;
}

-(void)connect {

    if (!_options) {
        [self streamConnectFailed:self code:-1 description:OPTIONS_IS_ABSENT];
        return;
    }
    
    if (_stream)
        [_stream disconnect];
    
    [DebLog log:@"MediaPublisher -> connect: content = %d", _options.content];
    
    switch (_options.content) {
        
        case AUDIO_AND_VIDEO: {
            _stream = [[BroadcastStreamClient alloc] init:_streamPath resolution:(MPVideoResolution)_options.resolution];
            [_stream switchCameras];
            [_stream setPreviewLayer:_options.previewPanel];
            break;
        }
            
        case ONLY_VIDEO: {
            _stream = [[BroadcastStreamClient alloc] initOnlyVideo:_streamPath resolution:(MPVideoResolution)_options.resolution];
            [_stream switchCameras];
            [_stream setPreviewLayer:_options.previewPanel];
            break;
        }
            
        case ONLY_AUDIO: {
            _stream = [[BroadcastStreamClient alloc] initOnlyAudio:_streamPath];
            break;
        }
            
        case CUSTOM_VIDEO: {
            _stream = [[BroadcastStreamClient alloc] init:_streamPath resolution:(MPVideoResolution)_options.resolution];
            [_stream setVideoMode:VIDEO_CUSTOM];
            [_stream setAudioMode:AUDIO_OFF];
            [_stream setPreviewLayer:_options.previewPanel];
            break;
        }
            
        case AUDIO_AND_CUSTOM_VIDEO: {
            _stream = [[BroadcastStreamClient alloc] init:_streamPath resolution:(MPVideoResolution)_options.resolution];
            [_stream setVideoMode:VIDEO_CUSTOM];
            [_stream setAudioMode:AUDIO_ON];
            [_stream setPreviewLayer:_options.previewPanel];
            break;
        }
           
        default:
            return;
    }
    
    _stream.parameters = [self parameters];
    
    //
    
    _stream.delegate = self;
    [_stream stream:_streamName publishType:(MPMediaPublishType)_options.publishType];
}

-(void)start {
    
    if ([self wrongOptions])
        return;
    
    [_stream start];
}

-(void)pause {
    
    if ([self wrongOptions])
        return;
    
    [_stream pause];
}

-(void)resume {
    
    if ([self wrongOptions])
        return;
    
    [_stream resume];
}

-(void)stop {
    
    if ([self wrongOptions])
        return;
    
    [_stream stop];
}

-(void)disconnect {
    
//    if ([self wrongOptions])
//        return;
    
    [_stream disconnect];
    _stream = nil;
}

#pragma mark -
#pragma mark IMediaStreamerDelegate Methods

-(void)streamStateChanged:(id)sender state:(StateMediaStream)state description:(NSString *)description {
    if ([_delegate respondsToSelector:@selector(streamStateChanged:state:description:)])
        [_delegate streamStateChanged:sender state:state description:description];
}

-(void)streamConnectFailed:(id)sender code:(int)code description:(NSString *)description {
    if ([_delegate respondsToSelector:@selector(streamConnectFailed:code:description:)])
        [_delegate streamConnectFailed:sender code:code description:description];
}

#pragma mark -
#pragma mark IMediaStreamEvent Methods

-(void)stateChanged:(id)sender state:(MPMediaStreamState)state description:(NSString *)description {
    
    [DebLog log:@"MediaPublisher <IMediaStreamEvent> stateChangedEvent: %d = %@", (int)state, description];
    
    switch (state) {
            
        case CONN_DISCONNECTED: {
            
            //[self disconnect];
            _stream = nil;
            
            break;
        }
            
        case CONN_CONNECTED: {
            
            if (![description isEqualToString:@"RTMP.Client.isConnected"])
                break;
            
            [self start];
            
            break;
        }
            
        case STREAM_PAUSED: {
            
            break;
        }
            
        case STREAM_PLAYING: {
            
            break;
        }
            
        default:
            break;
    }
    
    [self streamStateChanged:sender state:(StateMediaStream)state description:description];
}

-(void)connectFailed:(id)sender code:(int)code description:(NSString *)description {
    
   [DebLog log:@"MediaPublisher <IMediaStreamEvent> connectFailedEvent: %d = %@\n", code, description];
    
    //[self disconnect];
    _stream = nil;
    
    [self streamConnectFailed:sender code:code description:description];
}
#else
@implementation MediaPublisher
#endif

@end
//#endif

