//
//  VideoCodec.h
//  MediaLibiOS
//
//  Created by Vyacheslav Vdovichenko on 9/18/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPMediaData.h"
#import "CodecConstants.h"
#import "BinaryStream.h"

#define VIDEO_FPS 15

@interface VideoCodec : NSObject 

-(id)initWithResolution:(MPVideoResolution)_resolution;
-(id)initWithBitrate:(uint)_bitRate;
-(id)initWithResolution:(MPVideoResolution)_resolution andBitrate:(uint)_bitRate;

-(BinaryStream *)frameRGBImage:(uint8_t *)pixels size:(size_t)size width:(size_t)width height:(size_t)height timestamp:(int)timestamp;
@end
