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
#import "MediaStreamPlayer.h"
#if IS_MEDIA_ENCODER
#import "MPMediaDecoder.h"
#endif
#import "VideoPlayer.h"
#import "MediaPlaybackOptions.h"
#import "IMediaStreamer.h"
#import "Backendless.h"

static NSString *OPTIONS_IS_ABSENT = @"Options is absent. You shpuld set 'options' property";
static NSString *STREAM_IS_ABSENT = @"Stream is absent. You should invoke 'connect' method";

@interface MediaPlayer () <MPIMediaStreamEvent, IMediaStreamerDelegate> {

    MediaStreamPlayer *_stream;
#if IS_MEDIA_ENCODER
    MPMediaDecoder *_decoder;
#endif
}
@end


@implementation MediaPlayer

-(id)init {
	
    if ( (self=[super init]) ) {
        
#if IS_MEDIA_ENCODER
        _decoder = nil;
#endif
        _stream = nil;
        
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
    
    if (!_stream) {
        [self streamConnectFailed:self code:-2 description:STREAM_IS_ABSENT];
        return YES;
    }
    
    return NO;
}

-(NSString *)operationType {
    return _options.isLive ? @"playLive" : @"playRecorded";
}

-(NSString *)streamType {
    return _options.isLive ? @"live" : nil;//@"record";
}

-(NSArray *)parameters {
    
    id identity = backendless.userService.currentUser ? backendless.userService.currentUser.userToken : nil;
    if (!identity) identity = [NSNull null];
    
    id tube = _tubeName;
    if (!tube) tube = [NSNull null];
    
    NSArray *param = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, identity, tube, [self operationType], [self streamType], nil];
    
    [DebLog log:@"MediaPlayer -> parameters:%@", param];
    
    return param;
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
    return [self wrongOptions] ? CONN_DISCONNECTED : (MPMediaStreamState)_stream.state;
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

#if IS_MEDIA_ENCODER
    [_decoder cleanupStream];
    _decoder = nil;
#endif
    
    [_stream disconnect];
    _stream = nil;
}

#pragma mark -
#pragma mark IMediaStreamerDelegate Methods

#if SWIFT_ENUM_OFF
-(void)streamStateChanged:(id)sender state:(MPMediaStreamState)state description:(NSString *)description {
    if ([_delegate respondsToSelector:@selector(streamStateChanged:state:description:)])
        [_delegate streamStateChanged:sender state:state description:description];
}
#else
-(void)streamStateChanged:(id)sender state:(int)state description:(NSString *)description {
    if ([_delegate respondsToSelector:@selector(streamStateChanged:state:description:)])
        [_delegate streamStateChanged:sender state:state description:description];
}
#endif

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
            
            if ([description isEqualToString:@"NetStream.Play.StreamNotFound"]) {
                
                [self stop];
                
                break;
            }
            
            break;
        }
            
        default:
            break;
    }
#endif
    
    [self streamStateChanged:sender state:(MPMediaStreamState)state description:description];
}

-(void)connectFailed:(id)sender code:(int)code description:(NSString *)description {
    
    [DebLog log:@"MediaPlayer <IMediaStreamEvent> connectFailedEvent: %d = %@\n", code, description];

#if IS_MEDIA_ENCODER
    
    if (!_decoder)
        return;
    
    //_decoder = nil;
#else
    
    if (!_stream)
        return;
    
    _stream = nil;
#endif
    
    [self streamConnectFailed:sender code:code description:description];
}

@end
#else
@implementation MediaPlayer
@end
#endif

