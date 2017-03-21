//
//  IStreamDispatcher.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 14.09.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IStreamPacket;

@protocol IStreamDispatcher <NSObject>
-(void)dispatchEvent:(id <IStreamPacket>)event;
-(void)setStreamName:(NSString *)nameStream;
-(NSString *)getStreamName;
-(void)setTimestamp:(int)timeMs;
-(int)getTimestamp;
-(void)setStart:(int)timeMs;
-(int)getStart;
-(void)setDuration:(int)timeMs;
-(int)getDuration;
-(void)setReset:(BOOL)needReset;
-(BOOL)getReset;
@end
