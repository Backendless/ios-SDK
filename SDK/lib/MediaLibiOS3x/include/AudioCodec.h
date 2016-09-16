//
//  AudioCodec.h
//  MediaLibiOS
//
//  Created by Vyacheslav Vdovichenko on 9/18/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BinaryStream;

@interface AudioCodec : NSObject 
-(id)initWithBitrate:(uint)_bitRate;
-(BinaryStream *)encodePCMSample:(uint8_t *)soundBuffer soundBufferSize:(int)soundBufferSize;
@end
