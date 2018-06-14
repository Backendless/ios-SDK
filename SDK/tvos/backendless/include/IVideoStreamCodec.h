//
//  IVideoStreamCodec.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */


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
