//
//  VideoData.h
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 8/12/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#define UIImage NSImage
#endif
#import <Foundation/Foundation.h>
#import "BaseEvent.h"
#import "IStreamPacket.h"
#import "BinaryStream.h"

@protocol IVideoStreamCodec;

@interface VideoData : BaseEvent <IStreamPacket> {
    BinaryStream            *data;
    id <IVideoStreamCodec>  codec;
    UIImage                 *image;
}
@property (nonatomic, retain, getter = getData, setter = setData:) BinaryStream *data;
@property (nonatomic, retain, getter = getCodec, setter = setCodec:) id <IVideoStreamCodec> codec;
@property (nonatomic, retain) UIImage *image;

-(id)initWithBinaryStream:(BinaryStream *)stream;
-(id)initWithCodec:(id <IVideoStreamCodec>)videoCodec;
-(id)initWithBinaryStream:(BinaryStream *)stream videoCodec:(id <IVideoStreamCodec>)videoCodec;
@end
