//
//  MPAudioUnitEngine.h
//  MediaLibiOS
//
//  Created by Vyacheslav Vdovichenko on 10/9/13.
//  Copyright (c) 2013 themidnightcoders.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import "IAudioPlayer.h"
#import "MPMediaData.h"

#define DROP_BUFFER_SIZE_MIN 4000
#define DROP_BUFFER_SIZE_MAX 32000
#define DROP_TIME_DELAY 500

/*******************************************************************************************************************************
 * MPAudioUnitEngine singleton accessor: this is how you should ALWAYS get a reference to the MPAudioUnitEngine class instance *
 ******************************************************************************************************************************/
#define singltonAUEngine [MPAudioUnitEngine sharedInstance]

@protocol MPIAudioUnitDelegate
-(void)recieveAudioUnitData:(uint8_t *)data size:(UInt32)size timestamp:(const AudioTimeStamp *)timestamp;
@end

@interface MPAudioUnitEngine : NSObject <IAudioPlayer>

+(MPAudioUnitEngine *)sharedInstance;

@property (nonatomic, assign) id <NSObject, MPIAudioUnitDelegate> delegate;
@property uint recordBuffers;
@property (readonly) BOOL isPlaying;
@property (readonly) BOOL isRecording;

-(AudioUnit)getAudioUnit;
-(AudioStreamBasicDescription *)getStreamDescription;
-(void)setInputPCM:(MPAudioPCMType)pcmType;
#if __SETTING_SAMPLERATE__
-(void)setInputPCM:(MPAudioPCMType)pcmType sampleRate:(int)sampleRate;
#endif
-(void)getAudioBuffer:(AudioBufferList *)buffers numFrames:(UInt32)numFrames timestamp:(const AudioTimeStamp *)timestamp;
-(void)renderCallback:(AudioBufferList *)buffers flags:(AudioUnitRenderActionFlags *)actionFlags timestamp:(const AudioTimeStamp *)audioTimeStamp;
-(BOOL)record;
-(BOOL)play;
-(BOOL)pauseRecord;
@end
