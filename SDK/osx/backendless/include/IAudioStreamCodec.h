//
//  IAudioStreamCodec.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 14.09.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BinaryStream;

@protocol IAudioStreamCodec <NSObject>

/**
 * Return the name of the audio codec.
 * @return
 */
-(NSString *)getName;

/**
 * Reset the codec to its initial state.
 */
-(void)reset;

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
 * Return the data for an audio frame.
 * @return
 */
-(BinaryStream *)getFrame;

-(BinaryStream *)getDecoderConfiguration;


@end
