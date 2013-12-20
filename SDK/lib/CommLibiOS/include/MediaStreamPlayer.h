//
//  MediaStreamPlayer.h
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 9/18/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaConstants.h"
#import "RTMPClient.h"

#define isEchoCancellation [MediaStreamPlayer getEchoCancellationOn]
#define echoCancellationOn [MediaStreamPlayer setEchoCancellationOn:YES]
#define echoCancellationOff [MediaStreamPlayer setEchoCancellationOn:NO]

@protocol IVideoPlayer;
@class VideoStream, SysTimer, NellyMoserDecoder;

@interface MediaStreamPlayer : NSObject
@property (nonatomic, assign) id <IMediaStreamEvent> delegate;
@property (nonatomic, retain) id <IVideoPlayer> player;
@property (nonatomic, retain) NSArray *parameters;
@property (readonly) MediaStreamState state;

-(id)init:(NSString *)url;
-(id)initWithClient:(RTMPClient *)client;

+(void)setEchoCancellationOn:(BOOL)isOn;
+(BOOL)getEchoCancellationOn;

-(BOOL)connect:(NSString *)url name:(NSString *)name;
-(BOOL)attach:(RTMPClient *)client name:(NSString *)name;
-(BOOL)stream:(NSString *)name;
-(BOOL)isPlaying;
-(BOOL)start;
-(void)pause;
-(void)resume;
-(BOOL)stop;
-(void)disconnect;
@end
