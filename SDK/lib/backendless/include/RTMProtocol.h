//
//  RTMProtocol.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 05.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

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
