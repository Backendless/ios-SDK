//
//  IVideoStreamCodec.h
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 8/18/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BinaryStream;

@protocol IVideoStreamCodec <NSObject>

/**
 * Return the name of the video codec.
 * @return
 */
-(NSString *)getName;

/**
 * Reset the codec to its initial state.
 */
-(void)reset;

/**
 * Check if the codec supports frame dropping.
 * @return
 */
-(BOOL)canDropFrames;

/**
 * Returns true if the codec knows how to handle the passed
 * stream data.
 * @return
 * @param data
 */
-(BOOL)canHandleData:(BinaryStream *)data;

/**
 * Update the state of the codec with the passed data.
 * @param data
 * @return
 */
-(BOOL)addBuffer:(BinaryStream *)data;

/**
 * Return the data for a frame.
 * @return
 */
-(BinaryStream *)getFrame;

-(BinaryStream *)getDecoderConfiguration;

@end
