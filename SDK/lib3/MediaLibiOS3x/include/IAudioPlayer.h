//
//  IAudioPlayer.h
//  MediaLibiOS
//
//  Created by Vyacheslav Vdovichenko on 09.11.12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPMediaData.h"
// !!!
#include "libavformat/avformat.h"

@protocol IAudioPlayer <NSObject>
-(void)setRealTime:(BOOL)value;
-(BOOL)isRealTime;
-(BOOL)pause;
-(BOOL)resume;
-(BOOL)stop;
-(BOOL)dispose;
-(BOOL)isPlaying;
-(int)getCurrentTime; //ms
-(int)getSupplyTime;  //ms
@optional
-(BOOL)hold:(MPAudioPCMType)pcmType channels:(int)channels sampleRate:(int)sampleRate isRealTime:(BOOL)isRealTime;
-(BOOL)play:(AVFrame *)frame context:(AVCodecContext *)context timestamp:(int64_t)timestamp;
-(BOOL)play:(void *)frame size:(size_t)size timestamp:(int64_t)timestamp;
@end
