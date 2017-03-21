//
//  AudioData.h
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 8/15/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseEvent.h"
#import "IStreamPacket.h"
#import "BinaryStream.h"

@protocol IAudioStreamCodec;

@interface AudioData : BaseEvent <IStreamPacket> {
    BinaryStream            *data;    
    id <IAudioStreamCodec>  codec;
}
@property (nonatomic, retain, getter = getData, setter = setData:) BinaryStream *data;
@property (nonatomic, retain, getter = getCodec, setter = setCodec:) id <IAudioStreamCodec> codec;

-(id)initWithBinaryStream:(BinaryStream *)stream;
-(id)initWithCodec:(id <IAudioStreamCodec>)audioCodec;
-(id)initWithBinaryStream:(BinaryStream *)stream audioCodec:(id <IAudioStreamCodec>)audioCodec;
@end
