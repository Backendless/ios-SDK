//
//  MediaPlayer.m
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

#import "MediaPlayer.h"
#if TARGET_OS_IPHONE
#import "DEBUG.h"
#if IS_MEDIA_ENCODER
#import "MPMediaDecoder.h"
#else
#import "MediaStreamPlayer.h"
#endif
#import "VideoPlayer.h"
#import "MediaPlaybackOptions.h"
#import "IMediaStreamer.h"
#import "Backendless.h"

static NSString *OPTIONS_IS_ABSENT = @"Options is absent. You shpuld set 'options' property";
static NSString *STREAM_IS_ABSENT = @"Stream is absent. You should invoke 'connect' method";

@interface MediaPlayer () <MPIMediaStreamEvent, IMediaStreamerDelegate> {

#if IS_MEDIA_ENCODER
    MPMediaDecoder *_decoder;
#else
    MediaStreamPlayer *_stream;
#endif
}
@end


@implementation MediaPlayer

-(id)init {
	
    if ( (self=[super init]) ) {
        
#if IS_MEDIA_ENCODER
        _decoder = nil;
#else
        _stream = nil;
#endif
        
        _options = nil;
        _streamPath = nil;
        _tubeName = nil;
        _streamName = nil;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC MediaPlayer"];
    
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

#if IS_MEDIA_ENCODER
    if (!_decoder) {
        [self streamConnectFailed:self code:-2 description:STREAM_IS_ABSENT];
        return YES;
    }
#else
    if (!_stream) {
        [self streamConnectFailed:self code:-2 description:STREAM_IS_ABSENT];
        return YES;
    }
#endif
    
    return NO;
}

-(NSString *)operationType {
    return _options.isLive ? @"playLive" : @"playRecorded";
}

-(NSString *)streamType {
    return _options.isLive ? @"live" : nil;//@"record";
}

-(NSArray *)parameters {

#if TEST_MEDIA_INSTANCE
    return nil;
#else
    
    id identity = backendless.userService.currentUser ? backendless.userService.currentUser.getUserToken : nil;
    if (!identity) identity = [NSNull null];
    
    id tube = _tubeName;
    if (!tube) tube = [NSNull null];
    
    NSArray *param = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, identity, tube, [self operationType], [self streamType], nil];
    
    [DebLog log:@"MediaPlayer -> parameters:%@", param];
    
    return param;
#endif
}

#pragma mark -
#pragma mark IMediaStream Methods

-(void)connect {
    
    if (!_options) {
        [self streamConnectFailed:self code:-1 description:OPTIONS_IS_ABSENT];
        return;
    }
    
#if IS_MEDIA_ENCODER
    
    [_decoder cleanupStream];
    
    _decoder = [[MPMediaDecoder alloc] initWithView:_options.previewPanel];
    _decoder.parameters = [self parameters];
    _decoder.orientation = _options.orientation;
    _decoder.isRealTime = _options.isRealTime;
    _decoder.clientBufferMs = _options.clientBufferMs;
    _decoder.delegate = self;
    
    [_decoder setupStream:[NSString stringWithFormat:@"%@/%@", _streamPath, _streamName]];

#else
    
    [_stream disconnect];
    
    FramesPlayer *_player = [[FramesPlayer alloc] initWithView:_options.previewPanel];
    _player.orientation = _options.orientation;
    
    _stream = [[MediaStreamPlayer alloc] init:_streamPath];
    _stream.parameters = [self parameters];
    _stream.delegate = self;
    _stream.player = _player;
    [_stream stream:_streamName];

#endif
}

-(MPMediaStreamState)currentState {
#if IS_MEDIA_ENCODER
    return [self wrongOptions] ? CONN_DISCONNECTED : (MPMediaStreamState)_decoder.state;
#else
    return [self wrongOptions] ? CONN_DISCONNECTED : (MPMediaStreamState)_stream.state;
#endif
}

-(void)start {
    
    if ([self wrongOptions])
        return;

#if IS_MEDIA_ENCODER
    [_decoder resume];
#else
    [_stream start];
#endif
}

-(void)pause {
    
    if ([self wrongOptions])
        return;

#if IS_MEDIA_ENCODER
    [_decoder pause];
#else
    [_stream pause];
#endif
}

-(void)resume {
    
    if ([self wrongOptions])
        return;
    
#if IS_MEDIA_ENCODER
    [_decoder resume];
#else
    [_stream resume];
#endif
}

-(void)stop {
    
    if ([self wrongOptions])
        return;
    
#if IS_MEDIA_ENCODER
    [_decoder pause];
#else
    [_stream stop];
#endif
}

-(void)disconnect {
    
    _delegate = nil;

#if IS_MEDIA_ENCODER
    [_decoder cleanupStream];
    _decoder = nil;
#else
    [_stream disconnect];
    _stream = nil;
#endif
}

#pragma mark -
#pragma mark IMediaStreamerDelegate Methods

-(void)streamStateChanged:(id)sender state:(int)state description:(NSString *)description {
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
    
    [DebLog log:@"MediaPlayer <IMediaStreamEvent> stateChangedEvent: %d = %@", (int)state, description];

#if !IS_MEDIA_ENCODER
    switch (state) {
            
        case CONN_DISCONNECTED: {
            
            _stream = nil;
            
            break;
        }
            
        case STREAM_CREATED: {
            
            [self start];

            break;
        }
            
        case STREAM_PAUSED: {
            
            break;
        }
            
        case STREAM_PLAYING: {
            
            if ([description isEqualToString:MP_NETSTREAM_PLAY_STREAM_NOT_FOUND]) {
                
                [self stop];
                
                break;
            }
            
            break;
        }
            
        default:
            break;
    }
#endif
    
    [self streamStateChanged:self state:(int)state description:description];
}

-(void)connectFailed:(id)sender code:(int)code description:(NSString *)description {
    
    [DebLog log:@"MediaPlayer <IMediaStreamEvent> connectFailedEvent: %d = %@\n", code, description];

#if IS_MEDIA_ENCODER
    
    if (!_decoder)
        return;
#else
    
    if (!_stream)
        return;
    
    _stream = nil;
#endif
    
    [self streamConnectFailed:self code:code description:description];
}

@end
#else
@implementation MediaPlayer
@end
#endif

