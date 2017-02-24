//
//  VideoStream.h
//  MediaLibiOS
//
//  Created by Vyacheslav Vdovichenko on 4/28/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

@protocol IVideoPlayer, IStreamPacket;

@interface VideoStream : NSObject
@property (nonatomic, assign) id <IVideoPlayer> player;
@property (readonly) UInt64 timestamp;

-(id)initWithPlayer:(id <IVideoPlayer>)_player;
-(void)dispatchEvent:(id <IStreamPacket>)evt;
@end
