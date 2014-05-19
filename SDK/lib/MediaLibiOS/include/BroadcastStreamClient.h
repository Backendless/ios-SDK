//
//  BroadcastStreamClient.h
//  MediaLibiOS
//
//  Created by Vyacheslav Vdovichenko on 8/15/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#define UIImage NSImage
#endif
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import "MPMediaData.h"
#import "RTMPClient.h"

typedef enum video_mode VideoMode;
enum video_mode
{
    VIDEO_CAPTURE,
    VIDEO_CUSTOM,
};

typedef enum audio_mode AudioMode;
enum audio_mode
{
    AUDIO_ON,
    AUDIO_OFF,
};

@protocol IVideoPlayer;
@class SysTimer, MPMediaEncoder, VideoCodec, AudioCodec;

@interface BroadcastStreamClient : NSObject 

@property (nonatomic, assign) id <MPIMediaStreamEvent> delegate;
@property (nonatomic, retain) id <MPIMediaEncoder> encoder;
@property (nonatomic, retain) id <IVideoPlayer> player;
@property (nonatomic, retain) NSArray *parameters;
@property (nonatomic, retain) NSString *customType;
@property MPMediaStreamState state;
@property BOOL isAudioRunning;
@property BOOL isUsingFrontFacingCamera;

-(id)init:(NSString *)url;
-(id)initWithClient:(RTMPClient *)client;
-(id)init:(NSString *)url resolution:(MPVideoResolution)resolution;
-(id)initWithClient:(RTMPClient *)client resolution:(MPVideoResolution)resolution;
-(id)initOnlyAudio:(NSString *)url;
-(id)initOnlyAudioWithClient:(RTMPClient *)client;
-(id)initOnlyVideo:(NSString *)url resolution:(MPVideoResolution)resolution;
-(id)initOnlyVideoWithClient:(RTMPClient *)client resolution:(MPVideoResolution)resolution;

-(BOOL)setVideoMode:(VideoMode)mode;
-(void)setVideoBitrate:(uint)bitRate;
-(void)setVideoOrientation:(AVCaptureVideoOrientation)orientation;
-(void)setPreviewLayer:(UIView *)preview;
-(void)teardownPreviewLayer;
-(void)switchCameras;
-(AVCaptureSession *)getCaptureSession;

-(BOOL)setAudioMode:(AudioMode)mode;
-(void)setAudioPickingSeconds:(float)seconds;
-(void)setAudioBitrate:(uint)bitRate;

-(BOOL)connect:(NSString *)url name:(NSString *)name publishType:(MPMediaPublishType)type;
-(BOOL)attach:(RTMPClient *)client name:(NSString *)name publishType:(MPMediaPublishType)type;
-(BOOL)stream:(NSString *)name publishType:(MPMediaPublishType)type;
-(BOOL)sendFrame:(CVPixelBufferRef)pixelBuffer timestamp:(int)timestamp;
-(BOOL)sendSampleBuffer:(CMSampleBufferRef)sampleBuffer;
-(void)sendMetadata:(NSDictionary *)data;
-(void)sendMetadata:(NSDictionary *)data event:(NSString *)event;
-(void)start;
-(void)pause;
-(void)resume;
-(void)stop;
-(void)disconnect;

// for internal usage 
-(void)sendAudioQueueSample:(AudioQueueBufferRef)sampleBuffer timestamp:(int)timestamp;
@end
