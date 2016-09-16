//
//  NellyMoserDecoder.h
//  MediaLibiOS
//
//  Created by Vyacheslav Vdovichenko on 09.11.12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol IAudioPlayer, IStreamPacket;

@interface NellyMoserDecoder : NSObject

@property (readonly) UInt64 timestamp;

-(id)initWithPlayer:(id <IAudioPlayer>)_player;
//
-(uint)channels;
-(uint)sampleRate;
-(uint)getCurrentTime;
-(uint)getSupplyTime;
//
-(BOOL)reset;
-(BOOL)pause;
-(BOOL)resume;
-(BOOL)paying;
-(BOOL)stop;
-(void)dispatchEvent:(id <IStreamPacket>)evt;
@end
