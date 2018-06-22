//
//  RTMProtocol.h
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
#import "IRTMProtocol.h"

@class Packet, Header, BinaryStream;

@interface RTMProtocol : NSObject

@property (nonatomic, assign) id <IRTMProtocol> delegate;
@property int readChunkSize;
@property int writeChunkSize;

-(void)clearContext;
-(BinaryStream *)sendingChunk;
-(void)sentChunk;
-(void)receivedChunk:(BinaryStream *)chunk;
-(BOOL)shouldSendMessage;
-(BOOL)sendMessage:(Packet *)message;
-(Header *)lastHeader:(uint)channelId;
-(NSArray *)writingQueue;
-(int)pendingTypedPackets:(int)type streamId:(int)streamId;
@end
