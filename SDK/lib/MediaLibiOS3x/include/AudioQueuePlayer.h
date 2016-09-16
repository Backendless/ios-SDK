//
//  AudioQueuePlayer.h
//  MediaLibiOS
//
//  Created by Vyacheslav Vdovichenko on 09.11.12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import "IAudioPlayer.h"

@interface AudioQueuePlayer : NSObject <IAudioPlayer>

-(id)initWithSampleRate:(float)sampleRate channels:(uint)channels;
+(id)player;
+(id)player:(float)sampleRate channels:(uint)channels;

-(int)nextFrame:(void *)frame;
@end
